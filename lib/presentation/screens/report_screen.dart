import '../../core/formatting/rupiah.dart';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/spenva_brand.dart';

import '../../application/reports/report_pdf_service.dart';
import '../../application/reports/report_service.dart';
import '../../data/local/finchat_database.dart';
import '../../data/repositories/sqlite_category_repository.dart';
import '../../data/repositories/sqlite_transaction_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/reports/report_models.dart';
import '../../domain/reports/daily_expenses.dart';
import '../../domain/reports/selected_period.dart';
import '../../domain/reports/report_insights.dart';
import '../widgets/period_filter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.userId, this.savePdf, this.sharePdf});
  final String userId;
  final Future<Uri?> Function(Uint8List bytes, String filename)? savePdf;
  final Future<void> Function(Uint8List bytes, String filename)? sharePdf;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final FinChatDatabase _database;
  late final ReportService _reportService;
  late final ReportPdfService _reportPdfService;
  SelectedPeriod _period = SelectedPeriod.day(DateTime.now());
  Future<({ReportSummary report, List<DailyExpense> points})>? _reportFuture;

  @override
  void initState() {
    super.initState();
    _database = FinChatDatabase();
    _reportPdfService = ReportPdfService();
    _reportService = ReportService(
      transactions: SqliteTransactionRepository(_database),
      categories: SqliteCategoryRepository(_database),
    );
    _refreshReport();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  void _refreshReport() {
    final future = _loadReport(_period);
    if (mounted) {
      setState(() {
        _reportFuture = future;
      });
    }
  }

  Future<({ReportSummary report, List<DailyExpense> points})> _loadReport(SelectedPeriod period) async {
    final report = await _reportService.forRange(userId: widget.userId, start: period.start!, end: period.end!);
    double? previousDayExpense;
    if (period.kind == PeriodKind.day) {
      final day = period.start!;
      final previous = DateTime(day.year, day.month, day.day - 1);
      final prior = await _reportService.forRange(userId: widget.userId, start: previous, end: previous);
      previousDayExpense = prior.expenseTotal;
    }
    return (report: report, points: expenseChartPoints(report, previousDayExpense: previousDayExpense));
  }

  bool _exporting = false;

  Future<void> _exportPdf(ReportSummary report) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final title = switch (_period.kind) { PeriodKind.day => 'Laporan Harian', PeriodKind.month => 'Laporan Bulanan', PeriodKind.year => 'Laporan Tahunan', _ => 'Laporan Rentang' };
      final destination = await showDialog<bool>(context: context, builder: (context) => SimpleDialog(
        title: const Text('Ekspor laporan PDF'), children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(context, true), child: const ListTile(leading: Icon(Icons.save_alt), title: Text('Simpan ke perangkat'), subtitle: Text('Pilih folder dan nama file PDF.'))),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, false), child: const ListTile(leading: Icon(Icons.share_outlined), title: Text('Bagikan PDF'))),
        ],
      ));
      if (destination == null) return;
      final bytes = await _reportPdfService.generate(report: report, reportTitle: title);
      if (!mounted) return;
      final filename = reportPdfFileName(title, report.start);
      if (destination) {
        final saved = widget.savePdf != null ? await widget.savePdf!(bytes, filename)
            : await FilePicker.saveFile(fileName: filename, bytes: bytes, mimeType: 'application/pdf', dialogTitle: 'Simpan laporan Spenva');
        if (saved != null && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF tersimpan di lokasi pilihan Anda.')));
      } else {
        if (widget.sharePdf != null) { await widget.sharePdf!(bytes, filename); }
        else { await Printing.sharePdf(bytes: bytes, filename: filename); }
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $error')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Row(children: [SizedBox(width: 34, height: 34, child: SpenvaLogo(markOnly: true)), SizedBox(width: 10), Text('Laporan', style: TextStyle(fontWeight: FontWeight.bold))]),
          actions: [IconButton(tooltip: 'Ekspor PDF', onPressed: _exporting ? null : () async {
            final future = _reportFuture;
            if (future == null) return;
            try { final data = await future; if (mounted) await _exportPdf(data.report); }
            catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan belum siap. Coba lagi.'))); }
          }, icon: const Icon(Icons.download_outlined))],
        ),
        body: Column(
          children: [
            PeriodFilter(period: _period, onChanged: (value) {
              setState(() => _period = value);
              _refreshReport();
            }),
            Expanded(
              child: FutureBuilder<({ReportSummary report, List<DailyExpense> points})>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return _ErrorState(message: 'Gagal memuat laporan: ${snapshot.error}', onRetry: _refreshReport);
                  final data = snapshot.data;
                  final report = data?.report;
                  if (report == null) return const _ErrorState(message: 'Data laporan tidak tersedia.');
                  return _ReportBody(report: report, points: data!.points, onExport: () => _exportPdf(report));
                },
              ),
            ),
          ],
        ),
      );

}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.points, required this.onExport});
  final List<DailyExpense> points;
  final ReportSummary report;
  final VoidCallback onExport;
  @override
  Widget build(BuildContext context) {
    if (report.transactionCount == 0) {
      return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [_SummaryCard(report: report), const SizedBox(height: 12), _DailyExpenseChart(report: report, points: points), const SizedBox(height: 12), const Card(child: Padding(padding: EdgeInsets.all(24), child: Column(children: [Icon(Icons.receipt_long_outlined, size: 44), SizedBox(height: 10), Text('Belum ada transaksi', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Tidak ada transaksi pada periode yang dipilih.', textAlign: TextAlign.center)]))), const SizedBox(height: 12), OutlinedButton.icon(onPressed: onExport, icon: const Icon(Icons.picture_as_pdf), label: const Text('Ekspor PDF'))]);
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      _SummaryCard(report: report),
      const SizedBox(height: 12),
      _InsightCard(report: report, points: points),
      const SizedBox(height: 12),
      _CategoryChart(report: report),
      const SizedBox(height: 12),
      _DailyExpenseChart(report: report, points: points),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: onExport, icon: const Icon(Icons.picture_as_pdf), label: const Text('Ekspor PDF')),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});
  final ReportSummary? report;
  @override
  Widget build(BuildContext context) {
    final r = report;
    final income = _Metric('Pemasukan', _money(r?.incomeTotal ?? 0), Icons.south_west, color: Colors.teal,
      onTap: r == null ? null : () => _showTypeDetails(context, TransactionType.income, r.transactions));
    final expense = _Metric('Pengeluaran', _money(r?.expenseTotal ?? 0), Icons.north_east, color: Colors.red,
      onTap: r == null ? null : () => _showTypeDetails(context, TransactionType.expense, r.transactions));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Ringkasan periode', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
      LayoutBuilder(builder: (context, constraints) => constraints.maxWidth < 340 || MediaQuery.textScalerOf(context).scale(16) > 20
        ? Column(children: [income, const SizedBox(height: 10), expense])
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: income), const SizedBox(width: 12), Expanded(child: expense)])),
      const SizedBox(height: 12),
      _Metric('Selisih periode', _money(r?.balance ?? 0), Icons.account_balance_wallet_outlined, color: spenvaPurple, balance: true),
    ]);
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, {this.onTap, required this.color, this.balance = false});
  final String label, value;
  final IconData icon;
  final Color color;
  final bool balance;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(button: onTap != null, label: '$label $value', child: Card(
    margin: EdgeInsets.zero, color: balance ? const Color(0xffeeebf8) : Colors.white,
    child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: Padding(
      padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: .1), child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 8), Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xff606077)))),
          if (onTap != null) const Icon(Icons.chevron_right, size: 16, color: Color(0xff9494a5))]),
        const SizedBox(height: 10),
        Text(value, key: ValueKey('metric_$label'), style: TextStyle(fontSize: balance ? 22 : 19, fontWeight: FontWeight.bold), softWrap: true),
      ]),
    )),
  ));
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.report, required this.points});
  final ReportSummary report;
  final List<DailyExpense> points;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Cerita keuanganmu', style: TextStyle(fontWeight: FontWeight.bold)),
      for (final insight in reportInsights(report, points))
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.lightbulb_outline),
          title: Text(insight.title), subtitle: Text(insight.text)),
    ]),
  ));
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.report});
  final ReportSummary report;
  @override
  Widget build(BuildContext context) {
    final items = report.expenseCategories;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengeluaran per kategori', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('Tidak ada data kategori.')
            else ...[
              Center(
                child: SizedBox.square(
                  dimension: 190,
                  child: CustomPaint(painter: _ExpensePiePainter(items)),
                ),
              ),
              const SizedBox(height: 12),
              ...items.asMap().entries.map((entry) {
                final item = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 7, backgroundColor: _pieColor(entry.key)),
                  title: Text(item.categoryName),
                  isThreeLine: true,
                  subtitle: Text('${item.transactionCount} transaksi • ${_percent(item.totalAmount, report.expenseTotal)}\n${_money(item.totalAmount)}'),
                  onTap: () => _showCategoryDetails(context, item, report.transactions),
                );
              }),
            ],
            const SizedBox(height: 12),
            Text(categoryChartCaption(report), key: const ValueKey('category_chart_caption')),
          ],
        ),
      ),
    );
  }
}

class _ExpensePiePainter extends CustomPainter {
  const _ExpensePiePainter(this.items);
  final List<ReportCategorySummary> items;

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.totalAmount);
    if (total <= 0) return;
    final rect = Offset.zero & size;
    var start = -math.pi / 2;
    for (var index = 0; index < items.length; index++) {
      final sweep = items[index].totalAmount / total * math.pi * 2;
      canvas.drawArc(rect.deflate(18), start, sweep, true, Paint()..color = _pieColor(index));
      start += sweep;
    }
    canvas.drawCircle(size.center(Offset.zero), size.shortestSide * .22, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ExpensePiePainter oldDelegate) => oldDelegate.items != items;
}

Color _pieColor(int index) {
  const colors = <Color>[Colors.indigo, Colors.teal, Colors.orange, Colors.pink, Colors.blue, Colors.green, Colors.deepPurple, Colors.brown];
  return colors[index % colors.length];
}

class _DailyExpenseChart extends StatelessWidget {
  const _DailyExpenseChart({required this.report, required this.points});
  final List<DailyExpense> points;
  final ReportSummary report;

  @override
  Widget build(BuildContext context) {
    final maxAmount = points.fold<double>(0, (max, point) => math.max(max, point.amount));
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Grafik pengeluaran harian', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(height: MediaQuery.textScalerOf(context).scale(40) + 175, child: LayoutBuilder(builder: (context, constraints) {
          final width = math.max(constraints.maxWidth, points.length * MediaQuery.textScalerOf(context).scale(100.0));
          return SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: width, child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: points.map((point) => Expanded(child: Tooltip(
              message: '${_date(point.date)}: ${_money(point.amount)}',
              child: Semantics(label: '${_date(point.date)}: ${_money(point.amount)}', child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_money(point.amount), style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Container(width: 24, height: maxAmount == 0 ? 2 : math.max(2, point.amount / maxAmount * 150), decoration: BoxDecoration(color: spenvaPurple, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Text('${point.date.day}/${point.date.month}', style: const TextStyle(fontSize: 11)),
                ],
              )),
            ))).toList(),
          )));
        })),
        const SizedBox(height: 12),
        Text(dailyChartCaption(report, points), key: const ValueKey('daily_chart_caption')),
      ],
    )));
  }
}

void _showTypeDetails(BuildContext context, TransactionType type, List<TransactionEntity> transactions) {
  final items = transactions.where((item) => item.type == type).toList();
  _showTransactionDetails(context, type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran', items);
}

void _showCategoryDetails(BuildContext context, ReportCategorySummary category, List<TransactionEntity> transactions) {
  final items = transactions.where((item) => item.type == category.type && item.categoryId == category.categoryId).toList();
  _showTransactionDetails(context, category.categoryName, items);
}

void _showTransactionDetails(BuildContext context, String title, List<TransactionEntity> items) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text('${items.length} transaksi'),
          const Divider(),
          ...items.map((item) => ListTile(
                title: Text(item.description),
                subtitle: Text('${_date(item.transactionDate)} • ${item.categoryId}\n${_money(item.amount)}'),
                isThreeLine: true,
              )),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _percent(double value, double total) => total == 0 ? '0%' : '${(value / total * 100).toStringAsFixed(1)}%';
String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String _money(double value) => formatRupiah(value);
