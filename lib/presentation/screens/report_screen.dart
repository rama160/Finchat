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
    _tabController = TabController(length: 3, vsync: this);
    _database = FinChatDatabase();
    _reportPdfService = ReportPdfService();
    _reportService = ReportService(
      transactions: SqliteTransactionRepository(_database),
      categories: SqliteCategoryRepository(_database),
    );
    _tabController.addListener(_refreshReport);
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
      1 => _reportService.forRange(
          userId: widget.userId,
          start: _selectedRange.start,
          end: _selectedRange.end,
        ),
      _ => _reportService.forMonth(
          userId: widget.userId,
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
    };
    if (mounted) setState(() => _reportFuture = future);
  }

  Future<void> _exportPdf(ReportSummary report) async {
    final title = switch (_tabController.index) {
      0 => 'Laporan Harian',
      1 => 'Laporan Rentang',
      _ => 'Laporan Bulanan',
    };
    final bytes = await _reportPdfService.generate(
      report: report,
      reportTitle: title,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: reportPdfFileName(title, report.start),
    );
  }

  Future<void> _pickDay() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value == null) return;
    setState(() => _selectedDay = value);
    _refreshReport();
  }

  Future<void> _pickRange() async {
    final value = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
    );
    if (value == null) return;
    setState(() => _selectedRange = value);
    _refreshReport();
  }

  Future<void> _pickMonth() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih bulan dan tahun',
    );
    if (value == null) return;
    setState(() => _selectedMonth = DateTime(value.year, value.month));
    _refreshReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hari'),
            Tab(text: 'Rentang'),
            Tab(text: 'Bulan'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _PeriodSelector(
              tabIndex: _tabController.index,
              selectedDay: _selectedDay,
              selectedRange: _selectedRange,
              selectedMonth: _selectedMonth,
              onDay: _pickDay,
              onRange: _pickRange,
              onMonth: _pickMonth,
            ),
          ),
          Expanded(
            child: FutureBuilder<ReportSummary>(
              future: _reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat laporan: ${snapshot.error}'));
                }
                final report = snapshot.data;
                if (report == null) return const SizedBox.shrink();
                return _ReportBody(report: report, onExport: () => _exportPdf(report));
              },
            ),
          ),
        ],
      ),
    );
  }

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  static DateTimeRange _currentWeek(DateTime value) {
    final day = _day(value);
    final start = day.subtract(Duration(days: day.weekday - DateTime.monday));
    return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.tabIndex,
    required this.selectedDay,
    required this.selectedRange,
    required this.selectedMonth,
    required this.onDay,
    required this.onRange,
    required this.onMonth,
  });

  final int tabIndex;
  final DateTime selectedDay;
  final DateTimeRange selectedRange;
  final DateTime selectedMonth;
  final VoidCallback onDay;
  final VoidCallback onRange;
  final VoidCallback onMonth;

  @override
  Widget build(BuildContext context) {
    final label = switch (tabIndex) {
      0 => _date(selectedDay),
      1 => '${_date(selectedRange.start)} - ${_date(selectedRange.end)}',
      _ => '${_monthName(selectedMonth.month)} ${selectedMonth.year}',
    };
    final action = switch (tabIndex) {
      0 => onDay,
      1 => onRange,
      _ => onMonth,
    };
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_month),
        title: Text(label),
        subtitle: const Text('Ketuk untuk mengubah periode'),
        trailing: FilledButton(onPressed: action, child: const Text('Pilih')),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.onExport});

  final ReportSummary report;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: _SummaryCard(label: 'Pemasukan', value: report.incomeTotal, count: report.incomeCount)),
            const SizedBox(width: 8),
            Expanded(child: _SummaryCard(label: 'Pengeluaran', value: report.expenseTotal, count: report.expenseCount)),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: const Text('Saldo'),
            subtitle: Text('${report.transactionCount} transaksi'),
            trailing: Text(_money(report.balance), style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text('Detail transaksi', style: Theme.of(context).textTheme.titleLarge),
            ),
            FilledButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (report.groups.isEmpty)
          const Card(child: ListTile(title: Text('Belum ada transaksi pada periode ini.')))
        else
          ...report.groups.map((group) => _TransactionGroupTile(group: group)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.count});

  final String label;
  final double value;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 4),
            Text(_money(value), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text('$count transaksi'),
          ],
        ),
      ),
    );
  }
}

class _TransactionGroupTile extends StatelessWidget {
  const _TransactionGroupTile({required this.group});

  final ReportTransactionGroup group;

  @override
  Widget build(BuildContext context) {
    final countText = group.transactionCount == 1 ? '1 transaksi' : '${group.transactionCount} transaksi';
    return Card(
      child: ListTile(
        leading: Icon(group.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward),
        title: Text(group.description),
        subtitle: Text('${group.categoryName} • $countText'),
        trailing: Text(_money(group.totalAmount)),
      ),
    );
  }
}

String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String _money(double value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write('.');
    buffer.write(rounded[i]);
  }
  return 'Rp ${buffer.toString()}';
}

String _monthName(int month) => const [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ][month - 1];
