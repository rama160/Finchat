import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/billing/plan_catalog.dart';
import 'package:finchat/application/billing/play_billing_service.dart';
import 'package:finchat/application/billing/quota_service.dart';
import 'package:finchat/domain/billing/subscription_models.dart';
import 'package:finchat/core/release/play_release_config.dart';
import 'package:finchat/core/errors/input_failure_message.dart';
import 'package:finchat/application/session/session_manager.dart';

class FakeBilling implements PlayBillingService {
  bool cleared = false;
  bool failClear = false;
  @override Future<void> clearLocalPurchase() async { cleared = true; if (failClear) throw StateError('storage unavailable'); }
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  final calls = <Map<String, Object?>>[];
  @override Future<Map<String, dynamic>> quotaRequest(String action, {String? resource, String? operationId, bool? success, String? event, int? count, bool backgroundOnly = false}) async {
    calls.add({'action': action, 'resource': resource, 'id': operationId, 'success': success});
    return {};
  }
}
class FakeSessionManager implements SessionManager {
  bool loggedOut = false;
  @override Future<void> logout() async { loggedOut = true; }
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('logout clears only the Play purchase cache and still signs out after storage failure', () async {
    for (final fail in [false, true]) {
      final billing = FakeBilling()..failClear = fail;
      final manager = FakeSessionManager();
      await logoutWithBilling(manager, billing: billing);
      expect(manager.loggedOut, true);
      expect(billing.cleared, PlayReleaseConfig.isPlay);
      expect(billing.calls, isEmpty);
    }
  });
  test('offline Play profile cannot start account authentication from a quota gate', () async {
    final billing = FakeBilling();
    await expectLater(SubscriptionQuotaService(billing: billing).reserve('voice', accountLinked: false), throwsA(isA<UserFacingException>()));
    expect(billing.calls, isEmpty);
  }, skip: !PlayReleaseConfig.isPlay);
  test('pilot quota layer does not initialize billing or change the existing flow', () async {
    final lease = await SubscriptionQuotaService().reserve('voice');
    expect(lease.enforced, false);
    expect(lease.billing, isNull);
    await lease.finish(true);
  }, skip: PlayReleaseConfig.isPlay);
  test('final catalog exposes correct prices, six products and independent resource limits', () {
    expect(planCatalog.map((p) => p.tier.displayName), ['Free','Plus','Pro','Max']);
    expect(planCatalog.map((p) => p.suggestedRupiah), [0,15000,39000,89000]);
    expect(planCatalog.map((p) => p.yearlyRupiah), [0,149000,349000,799000]);
    expect(planCatalog.map((p) => p.voiceRequests), [10,100,500,1500]);
    expect(planCatalog.map((p) => p.ocrRequests), [5,100,500,1500]);
    expect(planCatalog.map((p) => p.aiRequests), [5,50,200,500]);
    expect(planCatalog.expand((p) => [p.productId,p.yearlyProductId]).whereType<String>().toSet(), hasLength(6));
    expect(offerFor(SubscriptionTier.pro).badge, 'PALING DIREKOMENDASIKAN');
    expect(offerFor(SubscriptionTier.unlimited).badge, isNot(contains('DIREKOMENDASIKAN')));
  });
  test('successful local voice settlement is idempotent and never touches AI credits', () async {
    final billing = FakeBilling();
    final lease = QuotaLease('voice','operation_voice',billing);
    await lease.finish(true);await lease.finish(false);
    expect(billing.calls, [{'action':'settle','resource':null,'id':'operation_voice','success':true}]);
  });
  test('failed scan releases the shared scan reservation only once', () async {
    final billing = FakeBilling();
    final lease = QuotaLease('ocr','operation_scan',billing);
    await lease.finish(false);await lease.finish(false);
    expect(billing.calls.single['success'], false);
    expect(billing.calls.single['id'], 'operation_scan');
  });
  test('free preserves core reports while paid plans enable automation and comparison', () {
    final free = offerFor(SubscriptionTier.free), plus = offerFor(SubscriptionTier.basic);
    expect(free.advanced, false);expect(free.automaticBackup,false);expect(free.pdfRequests,1);
    expect(plus.advanced,true);expect(plus.automaticBackup,true);expect(plus.pdfRequests,isNull);
  });
}
