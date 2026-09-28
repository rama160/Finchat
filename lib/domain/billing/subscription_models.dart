enum SubscriptionTier {
  free,
  basic,
  pro,
  unlimited,
}

extension SubscriptionTierX on SubscriptionTier {
  String get id => name;

  String get displayName => switch (this) {
        SubscriptionTier.free => 'Free',
        SubscriptionTier.basic => 'Basic',
        SubscriptionTier.pro => 'Pro',
        SubscriptionTier.unlimited => 'Unlimited',
      };
}

enum PaymentMethod {
  qris,
  gopay,
  bankTransfer,
  card,
  otherEwallet,
}

extension PaymentMethodX on PaymentMethod {
  String get id => name;

  String get displayName => switch (this) {
        PaymentMethod.qris => 'QRIS',
        PaymentMethod.gopay => 'GoPay',
        PaymentMethod.bankTransfer => 'Transfer Bank',
        PaymentMethod.card => 'Kartu',
        PaymentMethod.otherEwallet => 'E-Wallet lainnya',
      };
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.tier,
    required this.enabled,
    this.monthlyPriceId,
  });

  final SubscriptionTier tier;
  final bool enabled;
  final String? monthlyPriceId;

  String get name => tier.displayName;
}
