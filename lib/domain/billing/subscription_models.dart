enum SubscriptionTier { free, plus, pro, max }
enum SubscriptionStatus { active, pending, gracePeriod, onHold, paused, canceled, expired, revoked }
enum BillingPeriod { monthly, yearly }

extension SubscriptionTierX on SubscriptionTier {
  String get id => name.toUpperCase();
  String get displayName => switch(this){SubscriptionTier.free=>'Free',SubscriptionTier.plus=>'Plus',SubscriptionTier.pro=>'Pro',SubscriptionTier.max=>'Max'};
}
class SubscriptionPlan {
  const SubscriptionPlan({required this.tier,required this.enabled,this.productId,this.monthlyBasePlanId,this.yearlyBasePlanId,
    required this.voiceLimit,required this.ocrLimit,required this.aiLimit});
  final SubscriptionTier tier; final bool enabled; final String? productId; final String? monthlyBasePlanId; final String? yearlyBasePlanId;
  final int? voiceLimit; final int? ocrLimit; final int? aiLimit;
}
enum PaymentMethod { googlePlay, qris, gopay, bankTransfer, card, otherEwallet }
