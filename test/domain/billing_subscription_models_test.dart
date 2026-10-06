import 'package:flutter_test/flutter_test.dart';

import 'package:finchat/application/billing/monetization_config.dart';
import 'package:finchat/application/billing/subscription_service.dart';
import 'package:finchat/domain/billing/subscription_models.dart';

void main() {
  test('catalog exposes four tiers without granting paid entitlements', () {
    expect(MonetizationConfig.plans, hasLength(4));
    expect(MonetizationConfig.plans.first.tier, SubscriptionTier.free);
    expect(MonetizationConfig.plans.where((plan) => plan.enabled), hasLength(4));
    expect(MonetizationConfig.enabled, isTrue);
    expect(MonetizationConfig.subscriptionsEnabled, isTrue);
    expect(MonetizationConfig.paymentsEnabled, isFalse);
  });

  test('subscription service defaults every new user to Free', () {
    const service = SubscriptionService();
    expect(service.defaultTier, SubscriptionTier.free);
    expect(service.currentPlan.name, 'Free');
    expect(service.canUsePremiumFeatures(), isFalse);
  });

  test('payment methods are defined as a future provider contract', () {
    expect(MonetizationConfig.supportedPaymentMethods, containsAll(<PaymentMethod>[
      PaymentMethod.qris,
      PaymentMethod.gopay,
      PaymentMethod.bankTransfer,
    ]));
  });
}
