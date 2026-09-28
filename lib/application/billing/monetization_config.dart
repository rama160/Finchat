import '../../domain/billing/subscription_models.dart';

/// Monetization is deliberately disabled while the app is in pilot testing.
/// These definitions are the foundation only; no user is charged while the
/// feature flags remain false.
class MonetizationConfig {
  static const enabled = false;
  static const paymentsEnabled = false;
  static const subscriptionsEnabled = false;

  static const plans = <SubscriptionPlan>[
    SubscriptionPlan(tier: SubscriptionTier.free, enabled: true),
    SubscriptionPlan(tier: SubscriptionTier.basic, enabled: false, monthlyPriceId: 'finchat_basic_monthly'),
    SubscriptionPlan(tier: SubscriptionTier.pro, enabled: false, monthlyPriceId: 'finchat_pro_monthly'),
    SubscriptionPlan(tier: SubscriptionTier.unlimited, enabled: false, monthlyPriceId: 'finchat_unlimited_monthly'),
  ];

  static const supportedPaymentMethods = <PaymentMethod>[
    PaymentMethod.qris,
    PaymentMethod.gopay,
    PaymentMethod.bankTransfer,
    PaymentMethod.card,
    PaymentMethod.otherEwallet,
  ];

  static SubscriptionPlan planFor(SubscriptionTier tier) => plans.firstWhere((plan) => plan.tier == tier);
}
