import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/release/play_release_config.dart';
import '../../core/errors/input_failure_message.dart';
import '../auth/google_sign_in_coordinator.dart';
import '../session/session_manager.dart';
import 'plan_catalog.dart';
import '../../domain/billing/subscription_models.dart';

/// Never trust client purchase status to unlock AI. Each token is verified by
/// the backend against Google Play and bound to the signed-in Google account.
class PlayBillingService extends ChangeNotifier {
  PlayBillingService({InAppPurchase? store, http.Client? client, FlutterSecureStorage? storage})
    : store = store ?? InAppPurchase.instance, client = client ?? http.Client(), storage = storage ?? const FlutterSecureStorage();
  static PlayBillingService? _instance;
  static PlayBillingService get instance => _instance ??= PlayBillingService();
  static VerifiedEntitlement? get currentEntitlement => _instance?.entitlement;
  final InAppPurchase store;
  final http.Client client;
  final FlutterSecureStorage storage;
  StreamSubscription<List<PurchaseDetails>>? _listener;
  List<ProductDetails> products = [];
  VerifiedEntitlement? entitlement;
  bool available = false, pending = false;
  String? message;
  String? _token;
  int _purchaseGeneration = 0;
  static const _tokenKey = 'spenva.play.purchase_token';

  Future<void> initialize() async {
    if (!PlayReleaseConfig.isPlay || _listener != null) return;
    _listener = store.purchaseStream.listen((purchases) { unawaited(_handle(purchases)); }, onError: (_) {
      pending = false; message = 'Google Play belum dapat memproses langganan.'; notifyListeners();
    });
    await loadProducts();
  }
  Future<void> loadProducts() async {
    if (!PlayReleaseConfig.isPlay) { message = 'Langganan Google Play tersedia pada versi Play Store.'; return; }
    try {
      available = await store.isAvailable();
      if (available) {
        final result = await store.queryProductDetails(planCatalog.expand((p) => [p.productId, p.yearlyProductId]).whereType<String>().toSet());
        products = result.productDetails;
        message = result.error != null || result.notFoundIDs.isNotEmpty ? 'Sebagian paket belum tersedia di Google Play.' : null;
      } else { message = 'Google Play belum tersedia. Semua fungsi Free tetap dapat digunakan.'; }
    } catch (_) { message = 'Paket belum dapat dimuat. Coba lagi nanti.'; }
    notifyListeners();
  }
  ProductDetails? product(String id) => products.where((p) => p.id == id).firstOrNull;

  Future<Map<String, String>> _headers({bool backgroundOnly = false}) async {
    final token = backgroundOnly ? GoogleSignInCoordinator.instance.cachedIdToken : await GoogleSignInCoordinator.instance.currentIdToken();
    if (token == null) throw const UserFacingException('Masuk dengan Google untuk menghubungkan kuota dan langganan ke akun.');
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
  }
  Future<String> accountId({bool backgroundOnly = false}) async {
    final token = backgroundOnly ? GoogleSignInCoordinator.instance.cachedIdToken : await GoogleSignInCoordinator.instance.currentIdToken();
    if (token == null) throw StateError('Masuk dengan Google sebelum berlangganan.');
    final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1])))) as Map<String, dynamic>;
    final subject = claims['sub'];
    if (subject is! String || subject.isEmpty) throw StateError('Sesi Google belum tersedia.');
    // This hash is only an account-binding identifier. The backend independently
    // validates the signature, issuer, audience and expiry of the same token.
    return sha256.convert(utf8.encode(subject)).toString();
  }
  Future<VerifiedEntitlement?> verifySavedPurchase() async {
    entitlement = null;
    if (!PlayReleaseConfig.billingConfigured) return null;
    _token ??= await storage.read(key: _tokenKey);
    if (_token == null) return null;
    try { entitlement = await _verify(_token!); } catch (_) { entitlement = null; }
    return entitlement;
  }
  Future<VerifiedEntitlement?> _verify(String token) async {
    final response = await client.post(Uri.parse('${PlayReleaseConfig.backend}/v1/purchases/verify'),
      headers: await _headers(), body: jsonEncode({'purchaseToken': token})).timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) throw StateError('Google Play belum berhasil memverifikasi langganan.');
    return VerifiedEntitlement.fromServer(jsonDecode(response.body) as Map<String, dynamic>, await accountId());
  }
  Future<Map<String, dynamic>> quotaRequest(String action, {String? resource, String? operationId, bool? success, String? event, int? count, bool backgroundOnly = false}) async {
    final generation = _purchaseGeneration;
    if (!PlayReleaseConfig.billingConfigured) throw const UserFacingException('Layanan kuota belum diaktifkan. Pencatatan teks tetap tersedia.');
    final token = await purchaseToken;
    final response = await client.post(Uri.parse('${PlayReleaseConfig.backend}/v1/quota/$action'),
      headers: {...await _headers(backgroundOnly: backgroundOnly), if (token != null) 'X-Play-Purchase-Token': token},
      body: jsonEncode({if (resource != null) 'resource': resource, if (operationId != null) 'operationId': operationId, if (success != null) 'success': success, if (event != null) 'event': event, if (count != null) 'count': count})).timeout(const Duration(seconds: 20));
    if (response.statusCode == 429) throw UserFacingException('Kuota ${resource == 'ocr' ? 'Scan' : resource == 'voice' ? 'Voice' : resource == 'pdf' ? 'PDF' : 'fitur'} bulan ini telah digunakan. Lihat Paket Spenva untuk pilihan upgrade. Pencatatan teks tetap tersedia.');
    if (response.statusCode != 200) throw const UserFacingException('Kuota belum dapat diverifikasi. Coba lagi; pencatatan teks tetap tersedia.');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (action == 'state') {
      if (generation != _purchaseGeneration) throw const UserFacingException('Sesi akun berubah. Perbarui pemakaian setelah masuk kembali.');
      final value = data['entitlement'];
      entitlement = value is Map<String, dynamic> ? VerifiedEntitlement.fromServer(value, await accountId(backgroundOnly: backgroundOnly)) : null;
    }
    return data;
  }
  Future<bool> hasFeature(String feature, {bool backgroundOnly = false}) async {
    if (!PlayReleaseConfig.isPlay) return true;
    try {
      final state = await quotaRequest('state', backgroundOnly: backgroundOnly);
      final tier = SubscriptionTier.values.where((t) => t.name == state['tier']).firstOrNull ?? SubscriptionTier.free;
      final offer = offerFor(tier);
      return switch (feature) { 'automaticBackup' => offer.automaticBackup, 'advanced' => offer.advanced, _ => false };
    } catch (_) { return false; }
  }

  Future<void> buy(ProductDetails product) async {
    if (!PlayReleaseConfig.billingConfigured) throw StateError('Paket belum dibuka untuk pembelian.');
    if (pending) return;
    // Prevent purchasing a second simultaneous subscription. Google Play's
    // management page handles cancellation; switch after the old plan expires.
    await quotaRequest('state');
    final current = entitlement;
    if (current?.active == true) throw StateError('Anda sudah berlangganan. Kelola paket di Google Play sebelum mengganti paket.');
    final identity = await accountId();
    pending = true; message = null; notifyListeners();
    try {
      final started = await store.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product, applicationUserName: identity));
      if (!started) pending = false;
    } catch (_) { pending = false; rethrow; }
    finally { notifyListeners(); }
  }
  Future<void> restore() async {
    if (!PlayReleaseConfig.billingConfigured) { message = 'Pemulihan paket tersedia setelah layanan langganan diaktifkan.'; notifyListeners(); return; }
    await store.restorePurchases(applicationUserName: await accountId());
  }
  Future<void> _handle(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) { pending = true; notifyListeners(); continue; }
      pending = false;
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        try {
          final generation = _purchaseGeneration;
          final verified = await _verify(purchase.verificationData.serverVerificationData);
          if (generation != _purchaseGeneration) continue;
          if (verified == null) { message = 'Langganan belum aktif atau tidak sesuai dengan akun ini.'; continue; }
          _token = purchase.verificationData.serverVerificationData;
          await storage.write(key: _tokenKey, value: _token);
          entitlement = verified;
          // The server acknowledges only verified purchases; this completes
          // the plugin transaction. Never acknowledge on a verification error.
          // Acknowledgement is performed by the verification server, not twice by the client.
          message = 'Paket ${offerFor(verified.tier).displayName} aktif hingga ${verified.expiresAt.toLocal().day}/${verified.expiresAt.toLocal().month}/${verified.expiresAt.toLocal().year}.';
        } catch (_) { message = 'Verifikasi belum selesai. Pulihkan pembelian setelah koneksi kembali; akses lokal tetap tersedia.'; }
      } else if (purchase.status == PurchaseStatus.error) { message = 'Pembelian belum berhasil. Tidak ada paket yang dibuka.'; }
      notifyListeners();
    }
  }
  Future<String?> get purchaseToken async => _token ??= await storage.read(key: _tokenKey);
  Future<void> clearLocalPurchase() async { _purchaseGeneration++; _token = null; entitlement = null; message = null; await storage.delete(key: _tokenKey); }
  Future<void> reportAnswer({required String reason, String? question, String? answer}) async {
    if (!PlayReleaseConfig.billingConfigured) throw StateError('Layanan laporan belum diaktifkan pada build persiapan ini.');
    final response = await client.post(Uri.parse('${PlayReleaseConfig.backend}/v1/feedback'), headers: await _headers(),
      body: jsonEncode({'reason': reason, if (question != null) 'question': question, if (answer != null) 'answer': answer})).timeout(const Duration(seconds: 20));
    if (response.statusCode != 201) throw StateError('Laporan belum terkirim. Coba lagi nanti.');
  }
  Future<void> deleteServerData() async {
    if (!PlayReleaseConfig.billingConfigured) return;
    final response = await client.post(Uri.parse('${PlayReleaseConfig.backend}/v1/delete-self'), headers: await _headers()).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw StateError('Penghapusan data server belum berhasil. Data lokal belum dihapus.');
  }
  @override
  void dispose() { _listener?.cancel(); client.close(); super.dispose(); }
}

/// Clear only the device cache. Server association and monthly quota survive logout.
Future<void> logoutWithBilling(SessionManager manager, {PlayBillingService? billing}) async {
  if (PlayReleaseConfig.isPlay) {
    try { await (billing ?? PlayBillingService.instance).clearLocalPurchase(); }
    catch (_) { /* Sign-out still completes if secure storage is unavailable. */ }
  }
  await manager.logout();
}
