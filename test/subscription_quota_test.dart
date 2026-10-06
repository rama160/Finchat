import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/billing/plan_catalog.dart';
import 'package:finchat/application/billing/play_billing_service.dart';
import 'package:finchat/application/billing/quota_service.dart';
import 'package:finchat/domain/billing/subscription_models.dart';

class FakeBilling extends PlayBillingService {
  final calls = <Map<String, Object?>>[];
  @override Future<Map<String, dynamic>> quotaRequest(String action, {String? resource, String? operationId, bool? success, String? event, bool backgroundOnly = false}) async {
    calls.add({'action': action, 'resource': resource, 'id': operationId, 'success': success});
    return {};
  }
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
