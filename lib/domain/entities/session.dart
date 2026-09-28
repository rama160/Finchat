class Session {
  const Session({
    required this.userId,
    required this.email,
    this.authProvider = 'email',
    this.providerUserId,
    this.displayName,
  });

  final String userId;
  final String email;
  final String authProvider;
  final String? providerUserId;
  final String? displayName;
}
