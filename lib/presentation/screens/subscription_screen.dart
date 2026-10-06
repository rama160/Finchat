import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/billing/play_billing_service.dart';
import '../../application/billing/plan_catalog.dart';
import '../../core/formatting/rupiah.dart';
import '../../core/release/play_release_config.dart';
import '../../domain/billing/subscription_models.dart';
import '../../main.dart';
import 'privacy_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}
class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final PlayBillingService billing;
  @override void initState() {
    super.initState(); billing = PlayBillingService.instance;
    billing.addListener(_changed);
    billing.initialize().catchError((Object _) { if (mounted) setState(() {}); });
  }
  void _changed() { if (mounted) setState(() {}); }
  @override void dispose() { billing.removeListener(_changed); super.dispose(); }
  Future<void> _buy(PlanOffer plan) async {
    final session = SessionScope.of(context).session;
    if (session?.authProvider != 'google') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masuk dengan Google untuk menghubungkan langganan.'))); return;
    }
    final product = billing.product(plan.productId!);
    if (product == null) return;
    try { await billing.buy(product); }
    catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', '')))); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Paket Spenva')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Pencatatan yang nyaman tetap gratis.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Langganan menambahkan jawaban AI untuk pertanyaan yang belum bisa dijawab lokal. Tidak mengurangi fungsi Free yang sudah tersedia.'),
      if (!PlayReleaseConfig.billingConfigured) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Paket sudah disiapkan. Pembelian belum dibuka pada build persiapan ini. Harga di bawah adalah rencana harga; belum ada tagihan.')),
      for (final plan in planCatalog) Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(plan.tier == SubscriptionTier.unlimited ? 'Unlimited • fair use' : plan.tier.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(plan.tier == SubscriptionTier.free ? 'Gratis' : '${billing.product(plan.productId!)?.price ?? formatRupiah(plan.suggestedRupiah)} / bulan', style: const TextStyle(fontSize: 20)),
        if (plan.aiRequests > 0) Text('${plan.aiRequests} jawaban AI per periode langganan; tidak diakumulasikan.'),
        const SizedBox(height: 8), Text(plan.description),
        if (plan.tier != SubscriptionTier.free) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: billing.pending || !PlayReleaseConfig.billingConfigured || billing.product(plan.productId!) == null ? null : () => _buy(plan),
            child: Text(billing.pending ? 'Memproses…' : 'Langganan ${plan.tier.displayName}')),
        ],
      ]))),
      const Text('Harga dan biaya akhir mengikuti Google Play. Langganan diperpanjang otomatis sampai dibatalkan. Batalkan melalui Google Play; akses berlangsung sampai akhir periode yang dibayar. Nama Unlimited tidak berarti AI tanpa kuota: 1.000 jawaban AI per periode. Fitur lokal tetap tanpa batas.'),
      if (billing.message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(billing.message!)),
      TextButton(onPressed: () async { try { await billing.restore(); } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemulihan pembelian belum berhasil.'))); } }, child: const Text('Pulihkan pembelian')),
      TextButton(onPressed: () => launchUrl(PlayReleaseConfig.subscriptionsUrl, mode: LaunchMode.externalApplication), child: const Text('Kelola atau batalkan langganan')),
      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())), child: const Text('Privasi dan ketentuan')),
    ]),
  );
}
