import 'play_billing_service.dart';
import '../../domain/billing/subscription_models.dart';
import 'monetization_config.dart';

class SubscriptionService {
  const SubscriptionService();

  SubscriptionTier get defaultTier => SubscriptionTier.free;

  SubscriptionPlan get currentPlan => MonetizationConfig.planFor(PlayBillingService.currentEntitlement?.active == true ? PlayBillingService.currentEntitlement!.tier : defaultTier);

  bool canUsePremiumFeatures() => currentPlan.tier != SubscriptionTier.free && MonetizationConfig.enabled;

  bool canUsePaymentMethod(PaymentMethod method) => MonetizationConfig.paymentsEnabled && MonetizationConfig.supportedPaymentMethods.contains(method);
}
