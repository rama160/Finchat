import 'dart:math';
import '../../core/release/play_release_config.dart';
import '../../core/errors/input_failure_message.dart';
import 'play_billing_service.dart';

/// Server ledger is outside SQLite/Drive backup. No local reset or entitlement grant.
class QuotaLease {
  QuotaLease(this.resource, this.id, this.billing, {this.enforced = true});
  final String resource, id;
  final PlayBillingService? billing;
  final bool enforced;
  bool _finished = false;
  Future<void> finish(bool success) async {
    if (_finished) return;
    _finished = true;
    if (!enforced) return;
    try { await billing!.quotaRequest('settle', operationId: id, success: success); }
    catch (_) { /* Reservation stays counted; never grant credits from local cache. */ }
  }
}
class SubscriptionQuotaService {
  SubscriptionQuotaService({this.billing});
  final PlayBillingService? billing;
  Future<QuotaLease> reserve(String resource, {bool accountLinked = true}) async {
    if (PlayReleaseConfig.isPlay && !accountLinked) throw const UserFacingException('Masuk dengan Google untuk memakai kuota Voice, Scan dan PDF. Teks dan laporan dasar tetap tersedia offline.');
    final id = '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 30)}';
    final service = PlayReleaseConfig.isPlay ? billing ?? PlayBillingService.instance : billing;
    if (PlayReleaseConfig.isPlay) await service!.quotaRequest('reserve', resource: resource, operationId: id);
    return QuotaLease(resource, id, service, enforced: PlayReleaseConfig.isPlay);
  }
}
