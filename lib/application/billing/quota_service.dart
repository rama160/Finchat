import 'dart:math';
import '../../core/release/play_release_config.dart';
import 'play_billing_service.dart';

/// Server ledger is outside SQLite/Drive backup. No local reset or entitlement grant.
class QuotaLease {
  QuotaLease(this.resource, this.id, this.billing, {this.enforced = true});
  final String resource, id;
  final PlayBillingService billing;
  final bool enforced;
  bool _finished = false;
  Future<void> finish(bool success) async {
    if (_finished) return;
    _finished = true;
    if (!enforced) return;
    try { await billing.quotaRequest('settle', operationId: id, success: success); }
    catch (_) { /* Reservation stays counted; never grant credits from local cache. */ }
  }
}
class SubscriptionQuotaService {
  SubscriptionQuotaService({PlayBillingService? billing}) : billing = billing ?? PlayBillingService.instance;
  final PlayBillingService billing;
  Future<QuotaLease> reserve(String resource) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 30)}';
    if (PlayReleaseConfig.isPlay) await billing.quotaRequest('reserve', resource: resource, operationId: id);
    return QuotaLease(resource, id, billing, enforced: PlayReleaseConfig.isPlay);
  }
}
