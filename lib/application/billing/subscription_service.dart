import '../../domain/billing/subscription_models.dart';
import 'monetization_config.dart';

class SubscriptionService {
  const SubscriptionService();
  SubscriptionTier get defaultTier=>SubscriptionTier.free;
  SubscriptionPlan get currentPlan=>MonetizationConfig.planFor(defaultTier);
  bool canUsePremiumFeatures()=>currentPlan.tier!=SubscriptionTier.free&&MonetizationConfig.enabled;
  bool canUseExternalPaymentMethod(PaymentMethod method)=>MonetizationConfig.externalPaymentsEnabled&&method!=PaymentMethod.googlePlay;
}
