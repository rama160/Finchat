import 'package:googleapis/drive/v3.dart' as drive;

import '../../data/backup/google_drive_backup_provider.dart';
import '../../data/local/finchat_database.dart';
import 'backup_preference_service.dart';
import 'backup_service.dart';
import 'google_drive_auth_service.dart';

class AutomaticBackupService {
  AutomaticBackupService(
    this.database, {
    BackupPreferenceService? preferences,
    GoogleDriveAuthService? googleAuth,
  })  : preferences = preferences ?? BackupPreferenceService(database),
        googleAuth = googleAuth ?? GoogleDriveAuthService();

  final FinChatDatabase database;
  final BackupPreferenceService preferences;
  final GoogleDriveAuthService googleAuth;

  Future<bool> runIfEnabled() async {
    if (!await preferences.isAutomaticBackupEnabled()) return false;
    final client = await googleAuth.tryAuthorizeDriveSilently();
    if (client == null) return false;
    final backup = BackupService(
      database,
      cloudProvider: GoogleDriveBackupProvider(drive.DriveApi(client)),
    );
    await backup.backupToCloud();
    return true;
  }
}
