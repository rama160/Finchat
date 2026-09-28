class GoogleAuthResult {
  const GoogleAuthResult({
    required this.googleUserId,
    required this.email,
    this.displayName,
    this.idToken,
  });

  final String googleUserId;
  final String email;
  final String? displayName;
  final String? idToken;
}
