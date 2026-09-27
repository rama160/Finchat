class AppUpdate {
  const AppUpdate({
    required this.version,
    required this.releaseUrl,
    this.apkUrl,
    this.notes,
  });

  final String version;
  final Uri releaseUrl;
  final Uri? apkUrl;
  final String? notes;
}

abstract interface class UpdateProvider {
  Future<AppUpdate?> checkForUpdate({required String currentVersion});
}
