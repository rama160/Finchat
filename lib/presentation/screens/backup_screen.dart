import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../application/backup/backup_preference_service.dart';
import '../../application/backup/backup_service.dart';
import '../../application/backup/google_drive_auth_service.dart';
import '../../data/backup/google_drive_backup_provider.dart';
import '../../data/local/finchat_database.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.userId, required this.email});
  final String userId;
  final String email;
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  late final FinChatDatabase _database;
  late BackupService _backup;
  late final BackupPreferenceService _preferences;
  late final GoogleDriveAuthService _googleAuth;
  bool _busy = false;
  bool _automatic = false;
  String _status = 'Belum ada aktivitas backup.';

  @override
  void initState() {
    super.initState();
    _database = FinChatDatabase();
    _backup = BackupService(_database);
    _preferences = BackupPreferenceService(_database);
    _googleAuth = GoogleDriveAuthService();
    _loadPreference();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  Future<void> _loadPreference() async {
    final value = await _preferences.isAutomaticBackupEnabled();
    if (mounted) setState(() => _automatic = value);
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) setState(() => _status = success);
    } catch (error) {
      if (mounted) setState(() => _status = 'Gagal: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportLocal() async {
    await _run(() async {
      final bytes = await _backup.exportBytes();
      final directory = Directory.systemTemp;
      final file = File('${directory.path}/finchat_backup.json');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/json')], subject: 'Backup FinChat'));
    }, 'Backup lokal dibuat. Simpan file finchat_backup.json di lokasi aman.');
  }

  Future<void> _importLocal() async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
    if (file == null) return;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Pulihkan backup?'), content: const Text('Data lokal yang ada akan diganti oleh isi backup. Tindakan ini tidak dapat dibatalkan.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Pulihkan'))]));
    if (confirmed != true) return;
    await _run(() async {
      final bytes = await file.readAsBytes();
      await _backup.restoreJson(String.fromCharCodes(bytes));
    }, 'Backup lokal berhasil dipulihkan.');
  }

  Future<void> _connectGoogle() async {
    await _run(() async {
      final client = await _googleAuth.authorizeDrive();
      final provider = GoogleDriveBackupProvider(drive.DriveApi(client));
      _backup = BackupService(_database, cloudProvider: provider);
      final account = _googleAuth.currentUser;
      if (account != null && mounted) setState(() => _status = 'Google Drive terhubung sebagai ${account.email}.');
    }, 'Google Drive terhubung.');
  }

  Future<void> _backupGoogle() async {
    await _run(() async {
      final client = await _googleAuth.authorizeDrive();
      _backup = BackupService(_database, cloudProvider: GoogleDriveBackupProvider(drive.DriveApi(client)));
      await _backup.backupToCloud();
    }, 'Backup Google Drive berhasil.');
  }

  Future<void> _restoreGoogle() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Pulihkan dari Google Drive?'), content: const Text('Data lokal akan diganti oleh backup terakhir yang tersedia di Google Drive.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Pulihkan'))]));
    if (confirmed != true) return;
    await _run(() async {
      final client = await _googleAuth.authorizeDrive();
      _backup = BackupService(_database, cloudProvider: GoogleDriveBackupProvider(drive.DriveApi(client)));
      final restored = await _backup.restoreFromCloud();
      if (!restored) throw StateError('Belum ada backup FinChat di Google Drive.');
    }, 'Backup Google Drive berhasil dipulihkan.');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Backup & Pemulihan')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Card(child: Column(children: [
            const ListTile(leading: Icon(Icons.phone_android), title: Text('Backup lokal'), subtitle: Text('Ekspor dan impor JSON tanpa mengubah schema database.')),
            ListTile(leading: const Icon(Icons.upload_file), title: const Text('Ekspor backup'), onTap: _busy ? null : _exportLocal),
            ListTile(leading: const Icon(Icons.file_open), title: const Text('Impor & pulihkan'), onTap: _busy ? null : _importLocal),
          ])),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            const ListTile(leading: Icon(Icons.cloud_outlined), title: Text('Google Drive'), subtitle: Text('Backup disimpan di area appDataFolder aplikasi.')),
            ListTile(leading: const Icon(Icons.login), title: const Text('Hubungkan akun Google'), onTap: _busy ? null : _connectGoogle),
            ListTile(leading: const Icon(Icons.cloud_upload_outlined), title: const Text('Backup sekarang'), onTap: _busy ? null : _backupGoogle),
            ListTile(leading: const Icon(Icons.cloud_download_outlined), title: const Text('Pulihkan dari Google Drive'), onTap: _busy ? null : _restoreGoogle),
            SwitchListTile(title: const Text('Backup otomatis'), subtitle: const Text('Preferensi disimpan lokal; eksekusi otomatis terjadwal akan disempurnakan pada hardening.'), value: _automatic, onChanged: _busy ? null : (value) async { await _preferences.setAutomaticBackupEnabled(value); if (mounted) setState(() => _automatic = value); }),
          ])),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: _busy ? const CircularProgressIndicator() : const Icon(Icons.info_outline), title: const Text('Status'), subtitle: Text(_status))),
          const SizedBox(height: 12),
          const Text('Catatan konfigurasi: Google Drive memerlukan OAuth client Android yang terdaftar pada Google Cloud Console, API Google Drive aktif, dan SHA-1 aplikasi. Detail langkah ada di docs/PHASE_11_5_GOOGLE_DRIVE_SETUP.md.'),
        ]),
      );
}
