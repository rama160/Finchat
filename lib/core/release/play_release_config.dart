/// Play builds never fall back to the pilot AI gateway or external payments.
abstract final class PlayReleaseConfig {
  static const isPlay = String.fromEnvironment('FINCHAT_DISTRIBUTION') == 'play';
  static const backend = String.fromEnvironment('SPENVA_BILLING_ENDPOINT');
  static const privacyUrl = String.fromEnvironment('SPENVA_PRIVACY_URL');
  static const deletionUrl = String.fromEnvironment('SPENVA_DELETION_URL');
  static const supportEmail = String.fromEnvironment('SPENVA_SUPPORT_EMAIL');
  static const publisher = String.fromEnvironment('SPENVA_PUBLISHER');
  static bool get billingConfigured => isPlay && _https(backend);
  static bool _https(String value) => Uri.tryParse(value)?.scheme == 'https' && Uri.tryParse(value)?.host.isNotEmpty == true;
  static Uri get storeUrl => Uri.https('play.google.com', '/store/apps/details', {'id': 'com.finchat.finchat'});
  static Uri get subscriptionsUrl => Uri.https('play.google.com', '/store/account/subscriptions', {'package': 'com.finchat.finchat'});
}
