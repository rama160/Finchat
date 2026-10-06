import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../../domain/billing/subscription_models.dart';
import 'monetization_config.dart';
import 'subscription_backend_client.dart';

class PlayBillingService {
  PlayBillingService({required this.backend,InAppPurchase? store}):_store=store??InAppPurchase.instance;
  final SubscriptionBackendClient backend; final InAppPurchase _store;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final _entitlement=StreamController<BackendEntitlement>.broadcast();
  Stream<BackendEntitlement> get entitlementStream=>_entitlement.stream;

  Future<void> initialize() async {
    if(!await _store.isAvailable()) throw StateError('Google Play Billing tidak tersedia.');
    _purchaseSub=_store.purchaseStream.listen(_handlePurchases,onError:_entitlement.addError);
  }

  Future<List<ProductDetails>> loadProducts() async {
    final response=await _store.queryProductDetails(MonetizationConfig.playProductIds);
    if(response.error!=null) throw StateError(response.error!.message);
    return response.productDetails;
  }

  Future<void> buy({required ProductDetails product,required String obfuscatedAccountId}) async {
    if(product is! GooglePlayProductDetails) throw StateError('Produk Google Play tidak valid.');
    final param=GooglePlayPurchaseParam(productDetails:product,offerToken:product.offerToken,applicationUserName:obfuscatedAccountId);
    final launched=await _store.buyNonConsumable(purchaseParam:param);
    if(!launched) throw StateError('Google Play tidak dapat membuka pembelian.');
  }

  Future<void> restore() async => _store.restorePurchases();

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for(final purchase in purchases){
      if(purchase.status==PurchaseStatus.purchased||purchase.status==PurchaseStatus.restored){
        try{
          final token=purchase.verificationData.serverVerificationData;
          final verified=await backend.verify(token);
          _entitlement.add(verified);
          if(purchase.pendingCompletePurchase) await _store.completePurchase(purchase);
        }catch(error,stack){_entitlement.addError(error,stack);}
      }else if(purchase.status==PurchaseStatus.error){
        _entitlement.addError(StateError(purchase.error?.message??'Pembelian Google Play gagal.'));
      }
    }
  }

  Future<void> dispose() async {await _purchaseSub?.cancel();await _entitlement.close();}
}
