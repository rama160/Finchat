import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/update/update_service.dart';
import '../../application/billing/play_billing_service.dart';
import '../../core/constants/app_constants.dart';
import '../../data/update/github_release_update_provider.dart';
import '../../domain/update/app_update.dart';
import '../../main.dart';
import 'backup_screen.dart';
import 'subscription_screen.dart';
import 'privacy_screen.dart';
import '../../core/release/play_release_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final UpdateService _updateService;
  Future<AppUpdate?>? _updateCheck;

  @override
  void initState() {
    super.initState();
    _updateService = UpdateService(
      GitHubReleaseUpdateProvider(owner: 'rama160', repository: 'Finchat'),
    );
  }

  void _checkForUpdate() {
    setState(() {
      _updateCheck = _updateService.check(currentVersion: AppConstants.appVersion);
    });
  }

  Future<void> _openUpdate(AppUpdate update) async {
    final opened = await launchUrl(update.releaseUrl, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka halaman release.')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context).session;
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.account_circle_outlined),
            title: Text('Akun'),
            subtitle: Text('Session disimpan secara aman di perangkat.'),
          ),
          if (session != null) ...[
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(session.email),
            ),
            ListTile(
              leading: Icon(session.authProvider == 'google' ? Icons.account_circle : Icons.person_outline),
              title: const Text('Metode masuk'),
              subtitle: Text(session.authProvider == 'google' ? 'Google' : 'Email lokal'),
            ),
          ],
          if (session != null) ...[
            const Card(
              child: ListTile(
                leading: Icon(Icons.cloud_done_outlined),
                title: Text('AI melalui Cloudflare Gateway'),
                subtitle: Text(PlayReleaseConfig.isPlay ? 'Free menggunakan fungsi lokal. AI cloud memerlukan paket Google Play aktif dan persetujuan Anda.' : 'AI menggunakan Gateway terpusat. Gemini API key disimpan di server dan tidak perlu dimasukkan ke aplikasi.'),
              ),
            ),
          ],
          const Divider(),
          Card(child: ListTile(leading: const Icon(Icons.workspace_premium_outlined), title: const Text('Paket Spenva'),
            subtitle: const Text('Free, Plus, Pro dan Max.'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())))),
          ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privasi dan data'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()))),
          if (session != null)
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Backup & pemulihan'),
              subtitle: const Text('Backup lokal dan Google Drive.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BackupScreen(userId: session.userId, email: session.email))),
            ),
          ListTile(
            leading: const Icon(Icons.system_update_outlined),
            title: const Text('Versi aplikasi'),
            subtitle: Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Periksa pembaruan'),
            subtitle: Text(PlayReleaseConfig.isPlay ? 'Buka pembaruan di Google Play.' : 'Memeriksa GitHub Releases Spenva.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: PlayReleaseConfig.isPlay ? () => launchUrl(PlayReleaseConfig.storeUrl, mode: LaunchMode.externalApplication) : _checkForUpdate,
          ),
          if (session != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              subtitle: const Text('Hapus sesi Spenva dari perangkat ini.'),
              onTap: () => logoutWithBilling(SessionScope.of(context)),
            ),
          if (_updateCheck != null)
            FutureBuilder<AppUpdate?>(
              future: _updateCheck,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('Memeriksa pembaruan...'),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.error_outline),
                      title: const Text('Pemeriksaan pembaruan gagal'),
                      subtitle: Text(snapshot.error.toString()),
                    ),
                  );
                }
                final update = snapshot.data;
                if (update == null) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Spenva sudah versi terbaru'),
                    ),
                  );
                }
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.new_releases_outlined),
                    title: Text('Versi ${update.version} tersedia'),
                    subtitle: const Text('Buka halaman release untuk mengunduh APK.'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUpdate(update),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
