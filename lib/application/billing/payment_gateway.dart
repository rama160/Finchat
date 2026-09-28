import '../../domain/billing/subscription_models.dart';

class PaymentRequest {
  const PaymentRequest({required this.userId, required this.tier, required this.method});

  final String userId;
  final SubscriptionTier tier;
  final PaymentMethod method;
}

abstract interface class PaymentGateway {
  Future<String> createPayment(PaymentRequest request);
}

/// Placeholder contract for the future server-side payment provider.
/// Payment credentials must never be embedded in the Android application.
class DisabledPaymentGateway implements PaymentGateway {
  @override
  Future<String> createPayment(PaymentRequest request) async {
    throw StateError('Pembayaran belum diaktifkan pada versi pilot FinChat.');
  }
}
