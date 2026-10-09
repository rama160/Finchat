import '../billing/play_billing_service.dart';
import '../../core/release/play_release_config.dart';

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
  }) : preferences = preferences ?? BackupPreferenceService(database),
       googleAuth = googleAuth ?? GoogleDriveAuthService();

  final FinChatDatabase database;
  final BackupPreferenceService preferences;
  final GoogleDriveAuthService googleAuth;

  Future<bool> runIfEnabled() async {
    if (!await preferences.isAutomaticBackupEnabled()) return false;
    if (PlayReleaseConfig.isPlay &&
        !await PlayBillingService.instance.hasFeature(
          'automaticBackup',
          backgroundOnly: true,
        ))
      return false;
    final client = await googleAuth.tryAuthorizeDriveSilently();
    if (client == null) return false;
    final backup = BackupService(
      database,
      cloudProvider: GoogleDriveBackupProvider(drive.DriveApi(client)),
    );
    try {
      await backup.backupToCloud();
      return true;
    } finally {
      client.close();
    }
  }
}
