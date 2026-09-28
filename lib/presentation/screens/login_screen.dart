import 'package:flutter/material.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await SessionScope.of(context).login(email: controller.text);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('FormatException: ', ''))));
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      await SessionScope.of(context).loginWithGoogle();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In gagal: ${error.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionScope.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('FinChat', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('Kelola keuangan Anda dengan aman.'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: sessionManager.isBusy ? null : _loginWithGoogle,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: Text(sessionManager.isBusy ? 'Menghubungkan...' : 'Lanjut dengan Google'),
                ),
                const SizedBox(height: 16),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('atau mode lokal')), Expanded(child: Divider())]),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: sessionManager.isBusy ? null : _login,
                  child: const Text('Masuk tanpa Google'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mode email dipertahankan untuk pengujian lokal. Untuk akun pengguna, gunakan Google.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
