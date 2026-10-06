import 'package:flutter/material.dart';
import '../../main.dart';
import '../widgets/spenva_brand.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = TextEditingController();
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> _login() async {
    final email = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('Gunakan mode offline'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Mulai tanpa akun. Jika pernah menggunakan email lokal, masukkan email yang sama untuk membuka catatan lama.'),
        const SizedBox(height: 14),
        TextField(controller: controller, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email lokal (opsional)', border: OutlineInputBorder())),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim().isEmpty ? 'offline@finchat.local' : controller.text), child: const Text('Mulai'))],
    ));
    if (email == null || !mounted) return;
    try { await SessionScope.of(context).login(email: email); }
    catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('FormatException: ', ''))));
    }
  }

  Future<void> _loginWithGoogle() async {
    try { await SessionScope.of(context).loginWithGoogle(); }
    catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In gagal: ${error.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return Scaffold(body: SpenvaDecoration(child: SafeArea(child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Column(children: [
        const SizedBox(height: 10),
        const SizedBox(height: 158, width: 220, child: SpenvaLogo(signIn: true)),
        const SizedBox(height: 20),
        const Text('Keuangan rapi,', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, height: 1.2)),
        const Text('mulai dari cerita.', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: spenvaPurple, height: 1.2)),
        const SizedBox(height: 14),
        const Text('Catat pemasukan dan pengeluaran\nlewat chat, suara, atau foto struk.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff76768b), height: 1.5)),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .55), borderRadius: BorderRadius.circular(24)), child: Column(children: [
          Align(alignment: Alignment.centerRight, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: spenvaBlue.withValues(alpha: .13), borderRadius: BorderRadius.circular(16)), child: const Text('Tadi beli kopi 18 ribu'))),
          const SizedBox(height: 10),
          const Row(children: [SizedBox(width: 32, height: 32, child: SpenvaLogo(markOnly: true)), SizedBox(width: 10), Expanded(child: Text('Tercatat · Makanan dan minuman · Rp 18.000', style: TextStyle(fontSize: 12))), Icon(Icons.check_circle_outline, color: Colors.teal)]),
        ])),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: session.isBusy ? null : _loginWithGoogle,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
            const CircleAvatar(radius: 17, backgroundColor: Colors.white, child: Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue))),
            const SizedBox(width: 12), Expanded(child: Text(session.isBusy ? 'Menghubungkan…' : 'Lanjut dengan Google')), const Icon(Icons.arrow_forward),
          ])))),
        const SizedBox(height: 18),
        const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('atau', style: TextStyle(color: Color(0xff76768b)))), Expanded(child: Divider())]),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: session.isBusy ? null : _login,
          child: const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(Icons.phone_android_outlined), SizedBox(width: 12), Expanded(child: Text('Gunakan mode offline')), Icon(Icons.arrow_forward)])))),
        const SizedBox(height: 12),
        const Text('Mulai tanpa akun. Data tersimpan di perangkat.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xff76768b))),
        const SizedBox(height: 20),
        const Text('Backup Google Drive dapat diaktifkan setelah masuk.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Color(0xff76768b))),
      ]))),
    )))));
  }
}
