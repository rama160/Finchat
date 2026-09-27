import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../application/reports/report_pdf_service.dart';
import '../../application/reports/report_service.dart';
import '../../data/local/finchat_database.dart';
import '../../data/repositories/sqlite_category_repository.dart';
import '../../data/repositories/sqlite_transaction_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/reports/report_models.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.userId});
  final String userId;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final FinChatDatabase _database;
  late final ReportService _reportService;
  late final ReportPdfService _reportPdfService;
  DateTime _selectedDay = _day(DateTime.now());
  DateTimeRange _selectedRange = _currentWeek(DateTime.now());
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Future<ReportSummary>? _reportFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)..addListener(_refreshReport);
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
    _tabController.removeListener(_refreshReport);
    _tabController.dispose();
    _database.close();
    super.dispose();
  }

  void _refreshReport() {
    final future = switch (_tabController.index) {
      0 => _reportService.forDay(userId: widget.userId, date: _selectedDay),
      1 => _reportService.forRange(userId: widget.userId, start: _selectedRange.start, end: _selectedRange.end),
      _ => _reportService.forMonth(userId: widget.userId, year: _selectedMonth.year, month: _selectedMonth.month),
    };
    if (mounted) setState(() => _reportFuture = future);
  }

  Future<void> _exportPdf(ReportSummary report) async {
    final title = switch (_tabController.index) { 0 => 'Laporan Harian', 1 => 'Laporan Rentang', _ => 'Laporan Bulanan' };
    final bytes = await _reportPdfService.generate(report: report, reportTitle: title);
    await Printing.sharePdf(bytes: bytes, filename: reportPdfFileName(title, report.start));
  }

  Future<void> _pickDay() async {
    final value = await showDatePicker(context: context, initialDate: _selectedDay, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (value == null) return;
    setState(() => _selectedDay = value);
    _refreshReport();
  }

  Future<void> _pickRange() async {
    final value = await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDateRange: _selectedRange);
    if (value == null) return;
    setState(() => _selectedRange = value);
    _refreshReport();
  }

  Future<void> _pickMonth() async {
    final value = await showDatePicker(context: context, initialDate: _selectedMonth, firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: 'Pilih bulan dan tahun');
    if (value == null) return;
    setState(() => _selectedMonth = DateTime(value.year, value.month));
    _refreshReport();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Hari'), Tab(text: 'Rentang'), Tab(text: 'Bulan')]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _PeriodSelector(tabIndex: _tabController.index, selectedDay: _selectedDay, selectedRange: _selectedRange, selectedMonth: _selectedMonth, onDay: _pickDay, onRange: _pickRange, onMonth: _pickMonth),
            ),
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

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
  static DateTimeRange _currentWeek(DateTime value) {
    final day = _day(value);
    final start = day.subtract(Duration(days: day.weekday - DateTime.monday));
    return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.tabIndex, required this.selectedDay, required this.selectedRange, required this.selectedMonth, required this.onDay, required this.onRange, required this.onMonth});
  final int tabIndex;
  final DateTime selectedDay;
  final DateTimeRange selectedRange;
  final DateTime selectedMonth;
  final VoidCallback onDay;
  final VoidCallback onRange;
  final VoidCallback onMonth;
  @override
  Widget build(BuildContext context) {
    final label = switch (tabIndex) { 0 => _date(selectedDay), 1 => '${_date(selectedRange.start)} - ${_date(selectedRange.end)}', _ => '${_monthName(selectedMonth.month)} ${selectedMonth.year}' };
    final action = switch (tabIndex) { 0 => onDay, 1 => onRange, _ => onMonth };
    return Card(child: ListTile(leading: const Icon(Icons.calendar_month), title: Text(label), subtitle: const Text('Ketuk untuk mengubah periode'), trailing: FilledButton(onPressed: action, child: const Text('Pilih'))));
  }
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
      _Metric('Pemasukan', _money(r?.incomeTotal ?? 0), Icons.south_west),
      _Metric('Pengeluaran', _money(r?.expenseTotal ?? 0), Icons.north_east),
      _Metric('Saldo', _money(r?.balance ?? 0), Icons.account_balance_wallet_outlined),
      _Metric('Transaksi', '${r?.transactionCount ?? 0}', Icons.receipt_long_outlined),
    ])));
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            ],
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
    final items = report.expenseCategories.take(6).toList();
    final max = items.isEmpty ? 1.0 : items.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b);
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pengeluaran per kategori', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), if (items.isEmpty) const Text('Tidak ada data kategori.') else ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(item.categoryName)), Text(_money(item.totalAmount))]), const SizedBox(height: 4), LinearProgressIndicator(value: item.totalAmount / max)])))])));
  }
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
  Widget build(BuildContext context) => Card(child: Column(children: [const ListTile(title: Text('Detail transaksi', style: TextStyle(fontWeight: FontWeight.bold))), ...report.groups.take(30).map((group) => ListTile(leading: Icon(group.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward), title: Text(group.description), subtitle: Text('${group.categoryName} • ${group.transactionCount} transaksi'), trailing: Text(_money(group.totalAmount)), onTap: () => _showGroupDetails(context, group, report.transactions)))]));
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
String _monthName(int month) => const ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'][month - 1];
