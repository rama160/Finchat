import '../../domain/update/app_update.dart';

class UpdateService {
  const UpdateService(this.provider);

  final UpdateProvider provider;

  Future<AppUpdate?> check({required String currentVersion}) {
    return provider.checkForUpdate(currentVersion: currentVersion);
  }
}
