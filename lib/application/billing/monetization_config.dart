import 'plan_catalog.dart';
import '../../domain/billing/subscription_models.dart';

/// The four-tier catalog is enabled. Legacy external payments remain off.
/// PlayBillingService requires Play products and server verification before
/// it can start a payment or grant a paid entitlement.
class MonetizationConfig {
  static const enabled = true;
  static const paymentsEnabled = false;
  static const subscriptionsEnabled = true;

  static final plans = planCatalog.map((p) => SubscriptionPlan(tier: p.tier, enabled: true, monthlyPriceId: p.productId)).toList();

  static const supportedPaymentMethods = <PaymentMethod>[
    PaymentMethod.qris,
    PaymentMethod.gopay,
    PaymentMethod.bankTransfer,
    PaymentMethod.card,
    PaymentMethod.otherEwallet,
  ];

  static SubscriptionPlan planFor(SubscriptionTier tier) => plans.firstWhere((plan) => plan.tier == tier);
}
