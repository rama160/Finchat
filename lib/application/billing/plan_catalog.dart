import '../../domain/billing/subscription_models.dart';

class PlanOffer {
  const PlanOffer(this.tier, this.productId, this.suggestedRupiah, this.aiRequests, this.description);
  final SubscriptionTier tier;
  final String? productId;
  /// Planning price only. The purchase UI must use Google Play's live price.
  final int suggestedRupiah, aiRequests;
  final String description;
}

const planCatalog = <PlanOffer>[
  PlanOffer(SubscriptionTier.free, null, 0, 0, 'Catat tanpa batas dengan teks, suara perangkat dan struk. Laporan, PDF dan backup Drive tetap tersedia.'),
  PlanOffer(SubscriptionTier.basic, 'finchat_basic_monthly', 19000, 100, 'Untuk mulai memahami kebiasaan belanja lewat pertanyaan AI.'),
  PlanOffer(SubscriptionTier.pro, 'finchat_pro_monthly', 39000, 300, 'Untuk mengevaluasi keuangan lebih rutin dengan bantuan AI.'),
  PlanOffer(SubscriptionTier.unlimited, 'finchat_unlimited_monthly', 79000, 1000, 'Untuk penggunaan AI lebih sering. Fitur lokal tanpa batas; AI tetap memiliki kuota yang ditampilkan.'),
];

class VerifiedEntitlement {
  const VerifiedEntitlement({required this.tier, required this.expiresAt, required this.accountId});
  final SubscriptionTier tier;
  final DateTime expiresAt;
  final String accountId;
  bool get active => tier != SubscriptionTier.free && expiresAt.isAfter(DateTime.now());
  static VerifiedEntitlement? fromServer(Map<String, dynamic> json, String expectedAccountId) {
    if (json['active'] != true || json['accountId'] != expectedAccountId) return null;
    final tier = SubscriptionTier.values.where((t) => t.name == json['tier'] && t != SubscriptionTier.free).firstOrNull;
    final expiry = DateTime.tryParse(json['expiresAt']?.toString() ?? '');
    if (tier == null || expiry == null || !expiry.isAfter(DateTime.now())) return null;
    return VerifiedEntitlement(tier: tier, expiresAt: expiry, accountId: expectedAccountId);
  }
}
