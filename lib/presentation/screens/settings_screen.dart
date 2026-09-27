import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/ai/ai_secure_config_service.dart';
import '../../application/update/update_service.dart';
import '../../core/constants/app_constants.dart';
import '../../data/update/github_release_update_provider.dart';
import '../../domain/update/app_update.dart';
import '../../main.dart';
import 'backup_screen.dart';
import 'financial_qa_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final UpdateService _updateService;
  Future<AppUpdate?>? _updateCheck;
  bool _aiEnabled = false;
  final _aiKey = TextEditingController();
  final _aiEndpoint = TextEditingController(text: 'https://api.openai.com/v1/chat/completions');
  final _aiModel = TextEditingController();
  final _aiConfig = AiSecureConfigService();

  @override
  void initState() {
    super.initState();
    _updateService = UpdateService(
      GitHubReleaseUpdateProvider(owner: 'rama160', repository: 'Finchat'),
    );
    _loadAiConfig();
  }

  Future<void> _loadAiConfig() async {
    final enabled = await _aiConfig.readEnabled();
    final endpoint = await _aiConfig.readEndpoint();
    final model = await _aiConfig.readModel();
    if (!mounted) return;
    setState(() {
      _aiEnabled = enabled;
      if (endpoint != null && endpoint.isNotEmpty) _aiEndpoint.text = endpoint;
      if (model != null) _aiModel.text = model;
    });
  }

  Future<void> _saveAiConfig() async {
    final existingKey = await _aiConfig.readApiKey();
    final apiKey = _aiKey.text.trim().isEmpty ? (existingKey ?? '') : _aiKey.text;
    await _aiConfig.save(apiKey: apiKey, endpoint: _aiEndpoint.text, model: _aiModel.text, enabled: _aiEnabled);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfigurasi AI disimpan aman di secure storage.')));
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
    _aiKey.dispose();
    _aiEndpoint.dispose();
    _aiModel.dispose();
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
          if (session != null)
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(session.email),
            ),
          if (session != null) ...[
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Tanya Keuangan dengan AI'),
              subtitle: const Text('Jawaban memakai data transaksi yang dihitung FinChat.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FinancialQaScreen(userId: session.userId))),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('AI Fallback', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Aktifkan AI fallback'), value: _aiEnabled, onChanged: (value) => setState(() => _aiEnabled = value)),
                  TextField(controller: _aiKey, obscureText: true, decoration: const InputDecoration(labelText: 'API key', helperText: 'Tidak ditampilkan kembali dan disimpan di secure storage.')),
                  const SizedBox(height: 8),
                  TextField(controller: _aiEndpoint, decoration: const InputDecoration(labelText: 'Endpoint OpenAI-compatible')),
                  const SizedBox(height: 8),
                  TextField(controller: _aiModel, decoration: const InputDecoration(labelText: 'Model')),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: _saveAiConfig, child: const Text('Simpan AI'))),
                ]),
              ),
            ),
          ],
          const Divider(),
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
            subtitle: const Text('Memeriksa GitHub Releases FinChat.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _checkForUpdate,
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
                      title: Text('FinChat sudah versi terbaru'),
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
