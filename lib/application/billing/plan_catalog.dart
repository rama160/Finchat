import '../../domain/billing/subscription_models.dart';

import 'generated_plans.dart';

/// Source is assets/config/subscription_plans.json; generated values are checked in CI.
class PlanOffer {
  const PlanOffer(this.tier, this.productId, this.suggestedRupiah, this.aiRequests, this.description,
    {this.yearlyProductId, this.yearlyRupiah = 0, this.voiceRequests = 0, this.ocrRequests = 0,
     this.pdfRequests, this.advanced = false, this.automaticBackup = false, this.priority = false, this.name = '', this.aiLevel = 'trial', this.badge = ''});
  final SubscriptionTier tier;
  final String? productId, yearlyProductId;
  final int suggestedRupiah, yearlyRupiah, aiRequests, voiceRequests, ocrRequests;
  final int? pdfRequests;
  final bool advanced, automaticBackup, priority;
  final String description, badge, name, aiLevel;
  String get displayName => name.isEmpty ? tier.displayName : name;
  String? productIdFor(bool yearly) => yearly ? yearlyProductId : productId;
}
const planCatalog = generatedPlans;
PlanOffer offerFor(SubscriptionTier tier) => planCatalog.firstWhere((p) => p.tier == tier);

class VerifiedEntitlement {
  const VerifiedEntitlement({required this.tier, required this.expiresAt, required this.accountId, this.status = 'ACTIVE', this.basePlan = 'monthly', this.startsAt});
  final SubscriptionTier tier;
  final DateTime expiresAt;
  final String accountId;
  final String status, basePlan;
  final DateTime? startsAt;
  bool get active => tier != SubscriptionTier.free && expiresAt.isAfter(DateTime.now());
  static VerifiedEntitlement? fromServer(Map<String, dynamic> json, String expectedAccountId) {
    if (json['active'] != true || json['accountId'] != expectedAccountId) return null;
    final tier = SubscriptionTier.values.where((t) => t.name == json['tier'] && t != SubscriptionTier.free).firstOrNull;
    final expiry = DateTime.tryParse(json['expiresAt']?.toString() ?? '');
    if (tier == null || expiry == null || !expiry.isAfter(DateTime.now())) return null;
    return VerifiedEntitlement(tier: tier, expiresAt: expiry, accountId: expectedAccountId, status: json['status']?.toString() ?? 'ACTIVE', basePlan: json['basePlan']?.toString() ?? 'monthly', startsAt: DateTime.tryParse(json['startsAt']?.toString() ?? ''));
  }
}
