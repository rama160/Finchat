import '../../domain/billing/subscription_models.dart';

/// The four-tier catalog is enabled. Legacy external payments remain off.
/// PlayBillingService requires Play products and server verification before
/// it can start a payment or grant a paid entitlement.
class MonetizationConfig {
  static const enabled = true;
  static const paymentsEnabled = false;
  static const subscriptionsEnabled = true;

  static const plans = <SubscriptionPlan>[
    SubscriptionPlan(tier: SubscriptionTier.free, enabled: true),
    SubscriptionPlan(tier: SubscriptionTier.basic, enabled: true, monthlyPriceId: 'finchat_basic_monthly'),
    SubscriptionPlan(tier: SubscriptionTier.pro, enabled: true, monthlyPriceId: 'finchat_pro_monthly'),
    SubscriptionPlan(tier: SubscriptionTier.unlimited, enabled: true, monthlyPriceId: 'finchat_unlimited_monthly'),
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
