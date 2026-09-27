import 'package:flutter/material.dart';

import '../../application/ai/financial_qa_service.dart';
import '../../application/reports/report_service.dart';
import '../../data/ai/openai_compatible_ai_provider.dart';
import '../../data/local/finchat_database.dart';
import '../../data/repositories/sqlite_category_repository.dart';
import '../../data/repositories/sqlite_transaction_repository.dart';

class FinancialQaScreen extends StatefulWidget {
  const FinancialQaScreen({super.key, required this.userId});
  final String userId;
  @override
  State<FinancialQaScreen> createState() => _FinancialQaScreenState();
}

class _FinancialQaScreenState extends State<FinancialQaScreen> {
  final _question = TextEditingController();
  late final FinChatDatabase _database;
  late final FinancialQaService _service;
  DateTimeRange _range = DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, 1), end: DateTime.now());
  String? _answer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _database = FinChatDatabase();
    _service = FinancialQaService(reports: ReportService(transactions: SqliteTransactionRepository(_database), categories: SqliteCategoryRepository(_database)), provider: OpenAiCompatibleAiProvider());
  }

  @override
  void dispose() { _question.dispose(); _database.close(); super.dispose(); }

  Future<void> _ask() async {
    if (_busy || _question.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final answer = await _service.ask(userId: widget.userId, question: _question.text, start: _range.start, end: _range.end);
      if (mounted) setState(() => _answer = answer);
    } catch (error) {
      if (mounted) setState(() => _answer = 'Gagal memproses pertanyaan: $error');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _pickRange() async {
    final value = await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDateRange: _range);
    if (value != null && mounted) setState(() => _range = value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Tanya Keuangan')), body: ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(leading: const Icon(Icons.date_range), title: Text('${_date(_range.start)} - ${_date(_range.end)}'), subtitle: const Text('Periode data yang dihitung aplikasi'), trailing: const Icon(Icons.chevron_right), onTap: _pickRange)),
    const SizedBox(height: 12),
    TextField(controller: _question, minLines: 2, maxLines: 5, decoration: const InputDecoration(labelText: 'Pertanyaan', hintText: 'Contoh: kategori pengeluaran terbesar apa?', border: OutlineInputBorder())),
    const SizedBox(height: 12),
    FilledButton.icon(onPressed: _busy ? null : _ask, icon: _busy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: const Text('Tanya AI')),
    if (_answer != null) ...[const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_answer!)))]
  ]));
}

String _date(DateTime v) => '${v.day.toString().padLeft(2,'0')}/${v.month.toString().padLeft(2,'0')}/${v.year}';
