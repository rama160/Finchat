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
  bool yearly = false;
  Map<String, dynamic>? usage;
  String? quotaMessage;
  @override void initState() {
    super.initState(); billing = PlayBillingService.instance;
    billing.addListener(_changed);
    billing.initialize().catchError((Object _) { if (mounted) setState(() {}); });
    _loadUsage();
  }
  Future<void> _loadUsage() async {
    try {final value = await billing.quotaRequest('state'); if (mounted) setState(() { usage = value; quotaMessage = null; });}
    catch (_) {if (mounted) setState(() => quotaMessage = 'Masuk dengan Google dan hubungkan layanan kuota untuk melihat pemakaian.');}
  }
  void _changed() { if (mounted) setState(() {}); }
  @override void dispose() { billing.removeListener(_changed); super.dispose(); }
  Future<void> _buy(PlanOffer plan) async {
    final session = SessionScope.of(context).session;
    if (session?.authProvider != 'google') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masuk dengan Google untuk menghubungkan langganan.'))); return;
    }
    final product = billing.product(plan.productIdFor(yearly)!);
    if (product == null) return;
    try { await billing.buy(product); }
    catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', '')))); }
  }
  String _price(PlanOffer plan) {
    final product = billing.product(plan.productIdFor(yearly)!);
    if (product == null) return formatRupiah(yearly ? plan.yearlyRupiah : plan.suggestedRupiah);
    return product.currencyCode == 'IDR' ? formatRupiah(product.rawPrice) : product.price;
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Paket Spenva')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Catat dengan nyaman, pilih sesuai kebutuhan.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Teks, transaksi, kategori dan laporan dasar tetap gratis. Voice, Scan dan AI memiliki kuota terpisah setiap bulan.'),
      const SizedBox(height: 12),
      SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('Bulanan')), ButtonSegment(value: true, label: Text('Tahunan'))], selected: {yearly}, onSelectionChanged: (value) => setState(() => yearly = value.single)),
      if (usage != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pemakaian bulan ini', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final entry in {'voice':'Voice','ocr':'Scan','ai':'AI'}.entries) Text('${entry.value}: ${usage!['used'][entry.key]} / ${usage!['limits'][entry.key]}'),
        Text('Pembaruan kuota: ${DateTime.tryParse(usage!['billing_period_end']?.toString() ?? '')?.toLocal().toString().split(' ').first ?? ''}'),
      ]))),
      if (quotaMessage != null) Text(quotaMessage!),
      TextButton(onPressed: _loadUsage, child: const Text('Perbarui pemakaian')),
      if (!PlayReleaseConfig.billingConfigured) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Pembelian belum dibuka pada build persiapan ini. Harga adalah rencana; belum ada tagihan.')),
      for (final plan in planCatalog) Card(color: plan.tier == SubscriptionTier.pro ? const Color(0xffeeebfa) : null, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(plan.tier.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (plan.badge.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(plan.badge, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff555d91)))),
        Text(plan.tier == SubscriptionTier.free ? 'Gratis' : '${_price(plan)} / ${yearly ? 'tahun' : 'bulan'}', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8), Text(plan.description),
        Text('Voice: ${plan.voiceRequests}/bulan\nScan kamera + lampiran: ${plan.ocrRequests}/bulan\nAI: ${plan.aiRequests}/bulan'),
        Text(plan.pdfRequests == null ? 'PDF tanpa batas • Backup otomatis' : 'PDF: ${plan.pdfRequests}/bulan • Backup manual'),
        if (plan.advanced) const Text('Grafik perbandingan dan analisis periode'),
        if (plan.priority) const Text('Prioritas kapasitas AI dan antrean laporan dukungan'),
        if (plan.tier != SubscriptionTier.free) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: billing.pending || !PlayReleaseConfig.billingConfigured || billing.product(plan.productIdFor(yearly)!) == null ? null : () => _buy(plan), child: Text(billing.pending ? 'Memproses…' : 'Pilih ${plan.tier.displayName}')),
        ],
      ]))),
      const Text('Harga akhir mengikuti Google Play. Paket tahunan dibayar sekaligus; kuota tetap diperbarui setiap bulan dan tidak diakumulasikan. Langganan diperpanjang otomatis sampai dibatalkan. Akses berlanjut sampai masa berlaku berakhir. Pergantian paket dilakukan setelah paket lama berakhir. AI pribadi belum tersedia sebelum konfigurasi provider yang sesuai; kuota bukan jaminan ketersediaan layanan.'),
      if (billing.message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(billing.message!)),
      TextButton(onPressed: () async { try { await billing.restore(); await _loadUsage(); } catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemulihan pembelian belum berhasil.'))); } }, child: const Text('Pulihkan pembelian')),
      TextButton(onPressed: () => launchUrl(PlayReleaseConfig.subscriptionsUrl, mode: LaunchMode.externalApplication), child: const Text('Kelola atau batalkan langganan')),
      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())), child: const Text('Privasi dan ketentuan')),
    ]),
  );
}
