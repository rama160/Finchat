import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../application/reports/report_pdf_service.dart';
import '../../application/reports/report_service.dart';
import '../../data/local/finchat_database.dart';
import '../../data/repositories/sqlite_category_repository.dart';
import '../../data/repositories/sqlite_transaction_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/reports/report_models.dart';
import '../../domain/reports/selected_period.dart';
import '../widgets/period_filter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.userId});
  final String userId;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final FinChatDatabase _database;
  late final ReportService _reportService;
  late final ReportPdfService _reportPdfService;
  SelectedPeriod _period = SelectedPeriod.day(DateTime.now());
  Future<ReportSummary>? _reportFuture;

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
    final future = _reportService.forRange(userId: widget.userId, start: _period.start!, end: _period.end!);
    if (mounted) {
      setState(() {
        _reportFuture = future;
      });
    }
  }

  bool _exporting = false;

  Future<void> _exportPdf(ReportSummary report) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final title = switch (_period.kind) { PeriodKind.day => 'Laporan Harian', PeriodKind.month => 'Laporan Bulanan', _ => 'Laporan Rentang' };
      final bytes = await _reportPdfService.generate(report: report, reportTitle: title);
      if (!mounted) return;
      await Printing.sharePdf(bytes: bytes, filename: reportPdfFileName(title, report.start));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $error')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
        ),
        body: Column(
          children: [
            PeriodFilter(period: _period, onChanged: (value) {
              setState(() => _period = value);
              _refreshReport();
            }),
            Expanded(
              child: FutureBuilder<ReportSummary>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return _ErrorState(message: 'Gagal memuat laporan: ${snapshot.error}', onRetry: _refreshReport);
                  final report = snapshot.data;
                  if (report == null) return const _ErrorState(message: 'Data laporan tidak tersedia.');
                  return _ReportBody(report: report, onExport: () => _exportPdf(report));
                },
              ),
            ),
          ],
        ),
      );

}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.onExport});
  final ReportSummary report;
  final VoidCallback onExport;
  @override
  Widget build(BuildContext context) {
    if (report.transactionCount == 0) {
      return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [const _SummaryCard(report: null), const SizedBox(height: 12), const Card(child: Padding(padding: EdgeInsets.all(24), child: Column(children: [Icon(Icons.receipt_long_outlined, size: 44), SizedBox(height: 10), Text('Belum ada transaksi', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Tidak ada transaksi pada periode yang dipilih.', textAlign: TextAlign.center)]))), const SizedBox(height: 12), OutlinedButton.icon(onPressed: onExport, icon: const Icon(Icons.picture_as_pdf), label: const Text('Bagikan PDF'))]);
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      _SummaryCard(report: report),
      const SizedBox(height: 12),
      _InsightCard(report: report),
      const SizedBox(height: 12),
      _CategoryChart(report: report),
      const SizedBox(height: 12),
      _CountChart(report: report),
      const SizedBox(height: 12),
      _GroupList(report: report),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: onExport, icon: const Icon(Icons.picture_as_pdf), label: const Text('Bagikan PDF')),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});
  final ReportSummary? report;
  @override
  Widget build(BuildContext context) {
    final r = report;
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Wrap(spacing: 10, runSpacing: 10, children: [
      _Metric('Pemasukan', _money(r?.incomeTotal ?? 0), Icons.south_west, onTap: r == null ? null : () => _showTypeDetails(context, TransactionType.income, r.transactions)),
      _Metric('Pengeluaran', _money(r?.expenseTotal ?? 0), Icons.north_east, onTap: r == null ? null : () => _showTypeDetails(context, TransactionType.expense, r.transactions)),
      _Metric('Saldo', _money(r?.balance ?? 0), Icons.account_balance_wallet_outlined),
      _Metric('Transaksi', '${r?.transactionCount ?? 0}', Icons.receipt_long_outlined),
    ])));
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, {this.onTap});
  final String label, value;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: Theme.of(context).textTheme.labelMedium),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (onTap != null) const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.report});
  final ReportSummary report;
  @override
  Widget build(BuildContext context) {
    final expenses = report.expenseCategories;
    final top = expenses.isEmpty ? null : expenses.first;
    final text = top == null ? 'Belum ada kategori pengeluaran untuk dianalisis.' : 'Kategori pengeluaran terbesar adalah ${top.categoryName} sebesar ${_money(top.totalAmount)} (${_percent(top.totalAmount, report.expenseTotal)}).';
    return Card(child: ListTile(leading: const Icon(Icons.lightbulb_outline), title: const Text('Insight'), subtitle: Text(text)));
  }
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
            const SizedBox(height: 4),
            const Text('Diagram lingkaran berdasarkan nominal; legenda menampilkan jumlah transaksi per kategori.'),
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
                  subtitle: Text('${item.transactionCount} transaksi • ${_percent(item.totalAmount, report.expenseTotal)}'),
                  trailing: Text(_money(item.totalAmount)),
                  onTap: () => _showCategoryDetails(context, item, report.transactions),
                );
              }),
            ],
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

class _CountChart extends StatelessWidget {
  const _CountChart({required this.report});
  final ReportSummary report;
  @override
  Widget build(BuildContext context) {
    final max = report.incomeCount > report.expenseCount ? report.incomeCount : report.expenseCount;
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Jumlah transaksi', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), _CountBar(label: 'Pemasukan', count: report.incomeCount, max: max), const SizedBox(height: 10), _CountBar(label: 'Pengeluaran', count: report.expenseCount, max: max)])));
  }
}

class _CountBar extends StatelessWidget {
  const _CountBar({required this.label, required this.count, required this.max});
  final String label;
  final int count, max;
  @override
  Widget build(BuildContext context) => Row(children: [SizedBox(width: 90, child: Text(label)), Expanded(child: LinearProgressIndicator(value: max == 0 ? 0 : count / max)), const SizedBox(width: 8), Text('$count')]);
}

class _GroupList extends StatelessWidget {
  const _GroupList({required this.report});
  final ReportSummary report;
  @override
  Widget build(BuildContext context) => Card(child: Column(children: [const ListTile(title: Text('Detail transaksi', style: TextStyle(fontWeight: FontWeight.bold))), ...report.groups.map((group) => ListTile(leading: Icon(group.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward), title: Text(group.description), subtitle: Text('${group.categoryName} • ${group.transactionCount} transaksi'), trailing: Text(_money(group.totalAmount)), onTap: () => _showGroupDetails(context, group, report.transactions)))]));
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
                subtitle: Text('${_date(item.transactionDate)} • ${item.categoryId}'),
                trailing: Text(_money(item.amount)),
              )),
        ],
      ),
    ),
  );
}

void _showGroupDetails(
  BuildContext context,
  ReportTransactionGroup group,
  List<TransactionEntity> transactions,
) {
  final normalizedGroupDescription = group.description
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');
  final items = transactions
      .where(
        (item) =>
            item.type == group.type &&
            item.categoryId == group.categoryId &&
            item.description.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ==
                normalizedGroupDescription,
      )
      .toList();

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            group.description,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text('${group.categoryName} • ${_money(group.totalAmount)}'),
          const Divider(),
          ...items.map(
            (item) => ListTile(
              title: Text(_money(item.amount)),
              subtitle: Text(_date(item.transactionDate)),
            ),
          ),
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
String _money(double value) => 'Rp ${value.round().toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (m) => '.')}';
