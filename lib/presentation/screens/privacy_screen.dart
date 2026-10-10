import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:url_launcher/url_launcher.dart';
import '../../application/backup/google_drive_auth_service.dart';
import '../../application/billing/play_billing_service.dart';
import '../../application/privacy/account_data_service.dart';
import '../../application/privacy/data_operation_gate.dart';
import '../../application/privacy/drive_data_deletion.dart';
import '../../core/release/play_release_config.dart';
import '../../data/local/finchat_database.dart';
import '../../main.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override State<PrivacyScreen> createState() => _PrivacyScreenState();
}
class _PrivacyScreenState extends State<PrivacyScreen> {
  bool deleting = false;
  late final Future<String> text = rootBundle.loadString('assets/legal/privacy_id.txt');
  Future<void> _delete() async {
    final manager = SessionScope.of(context);
    final session = manager.session;
    if (session == null) return;
    var removeCloud = session.authProvider == 'google';
    final confirmed = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, update) => AlertDialog(
      title: const Text('Hapus akun dan data Spenva?'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Transaksi, pembelajaran kategori dan profil akun ini di perangkat akan dihapus permanen. Profil lain dipertahankan. PDF/backup yang Anda ekspor sendiri dan data di perangkat lain tidak dapat dihapus dari sini. Penghapusan akun tidak membatalkan langganan Google Play.'),
        if (session.authProvider == 'google') CheckboxListTile(value: removeCloud, onChanged: (value) => update(() => removeCloud = value ?? false),
          title: const Text('Hapus data akun ini dari backup Google Drive'), subtitle: const Text('Google mungkin meminta izin. Jika gagal, data lokal belum dihapus.')),
        if (session.authProvider == 'google' && !removeCloud) const Text('Backup Drive tetap ada dan dapat memulihkan data yang dihapus lokal.'),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus permanen'))],
    )));
    if (confirmed != true || !mounted) return;
    setState(() => deleting = true);
    try {
      await DataOperationGate.deletion(() async {
        if (session.authProvider == 'google') await PlayBillingService.instance.deleteServerData();
        if (removeCloud) {
          final auth = GoogleDriveAuthService();
          final client = await auth.authorizeDrive();
          try {
            if (auth.currentUser?.email.toLowerCase() != session.email.toLowerCase()) throw StateError('Gunakan akun Google yang sama untuk menghapus backup.');
            await DriveDataDeletion(drive.DriveApi(client)).deleteUser(session.userId);
          } finally { client.close(); }
        }
        await AccountDataService(FinChatDatabase()).deleteLocalUser(session.userId);
        await PlayBillingService.instance.clearLocalPurchase();
        await manager.logout();
      });
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penghapusan belum selesai. Coba lagi; data lokal belum dihapus jika penghapusan cloud gagal.')));
    } finally { if (mounted) setState(() => deleting = false); }
  }
  @override Widget build(BuildContext context) => PopScope(canPop: !deleting, child: Scaffold(
    appBar: AppBar(title: const Text('Privasi dan data')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Kebijakan Privasi Spenva', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      if (PlayReleaseConfig.publisher.isNotEmpty) Text('Penerbit: ${PlayReleaseConfig.publisher}'),
      if (PlayReleaseConfig.supportEmail.isEmpty) const Text('Build persiapan: identitas penerbit dan kontak dukungan harus dilengkapi sebelum publikasi.'),
      FutureBuilder<String>(future: text, builder: (context, snapshot) => snapshot.hasError ? const Text('Dokumen belum dapat dimuat.') : SelectableText(snapshot.data ?? 'Memuat dokumen…')),
      if (PlayReleaseConfig.supportEmail.isNotEmpty) TextButton(onPressed: () => launchUrl(Uri(scheme: 'mailto', path: PlayReleaseConfig.supportEmail)), child: const Text('Hubungi dukungan')),
      if (PlayReleaseConfig.privacyUrl.isNotEmpty) TextButton(onPressed: () => launchUrl(Uri.parse(PlayReleaseConfig.privacyUrl), mode: LaunchMode.externalApplication), child: const Text('Kebijakan privasi di web')),
      if (SessionScope.of(context).session != null) ...[
        const Divider(),
        OutlinedButton.icon(onPressed: deleting ? null : _delete, icon: const Icon(Icons.delete_forever_outlined), label: Text(deleting ? 'Menghapus…' : 'Hapus akun dan data')),
        TextButton(onPressed: () => launchUrl(PlayReleaseConfig.subscriptionsUrl, mode: LaunchMode.externalApplication), child: const Text('Batalkan langganan di Google Play')),
      ],
    ]),
  ));
}
