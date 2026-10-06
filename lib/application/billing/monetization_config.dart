import '../../domain/billing/subscription_models.dart';

class MonetizationConfig {
  static const enabled = false;
  static const subscriptionsEnabled = false;
  static const externalPaymentsEnabled = false;
  static const plans=<SubscriptionPlan>[
    SubscriptionPlan(tier:SubscriptionTier.free,enabled:true,voiceLimit:10,ocrLimit:5,aiLimit:5),
    SubscriptionPlan(tier:SubscriptionTier.plus,enabled:true,productId:'spenva_plus',monthlyBasePlanId:'monthly',yearlyBasePlanId:'yearly',voiceLimit:100,ocrLimit:100,aiLimit:50),
    SubscriptionPlan(tier:SubscriptionTier.pro,enabled:true,productId:'spenva_pro',monthlyBasePlanId:'monthly',yearlyBasePlanId:'yearly',voiceLimit:500,ocrLimit:500,aiLimit:200),
    SubscriptionPlan(tier:SubscriptionTier.max,enabled:true,productId:'spenva_max',monthlyBasePlanId:'monthly',yearlyBasePlanId:'yearly',voiceLimit:1500,ocrLimit:1500,aiLimit:500),
  ];
  static const playProductIds={'spenva_plus','spenva_pro','spenva_max'};
  static SubscriptionPlan planFor(SubscriptionTier tier)=>plans.firstWhere((p)=>p.tier==tier);
}
