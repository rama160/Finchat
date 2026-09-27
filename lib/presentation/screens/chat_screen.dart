import 'package:flutter/material.dart';

import '../../application/transactions/transaction_intelligence_service.dart';
import '../../data/local/finchat_database.dart';
import '../../data/repositories/sqlite_category_repository.dart';
import '../../data/repositories/sqlite_transaction_repository.dart';
import '../../domain/ai/ai_category_fallback.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/services/category_learning_service.dart';
import '../../main.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  late final FinChatDatabase _database;
  late final SqliteTransactionRepository _transactions;
  late final SqliteCategoryRepository _categories;
  late final CategoryLearningService _learning;
  late final TransactionIntelligenceService _intelligence;

  List<TransactionEntity> _items = const [];
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _database = FinChatDatabase();
    _transactions = SqliteTransactionRepository(_database);
    _categories = SqliteCategoryRepository(_database);
    _learning = CategoryLearningService(_categories);
    _intelligence = TransactionIntelligenceService(
      categoryLearning: _learning,
      aiFallback: AiCategoryFallback(
        provider: _NoOpAiCategoryProvider(),
        categoryExists: (id) => _categories.getById(id).then((value) => value != null),
      ),
    );
    _loadTransactions();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final session = SessionScope.of(context).session;
    if (session == null) return;
    await _database.ensureUser(userId: session.userId, email: session.email);
    final items = await _transactions.getByUser(session.userId);
    if (mounted) setState(() => _items = items);
  }

  Future<void> _processAndSave() async {
    final session = SessionScope.of(context).session;
    final input = _inputController.text.trim();
    if (session == null || input.isEmpty || _processing) return;

    setState(() => _processing = true);
    try {
      await _database.ensureUser(userId: session.userId, email: session.email);
      final results = await _intelligence.process(userId: session.userId, input: input);
      if (results.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi belum dikenali. Contoh: nasi 25rb dan bensin 50k.')),
          );
        }
        return;
      }

      final now = DateTime.now();
      for (var index = 0; index < results.length; index++) {
        final item = results[index];
        await _transactions.save(TransactionEntity(
          id: '${session.userId}_${now.microsecondsSinceEpoch}_$index',
          userId: session.userId,
          type: item.type == ParsedTransactionType.income ? TransactionType.income : TransactionType.expense,
          amount: item.amount,
          description: item.description,
          categoryId: item.categoryId,
          transactionDate: DateTime(now.year, now.month, now.day),
          inputSource: InputSource.text,
          processedBy: item.processedBy,
          confidence: item.confidence,
          createdAt: now,
          updatedAt: now,
        ));
      }
      _inputController.clear();
      await _loadTransactions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${results.length} transaksi langsung tersimpan.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan transaksi: $error')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _editTransaction(TransactionEntity transaction) async {
    final categories = await _categories.getCategories();
    if (!mounted) return;
    final result = await showDialog<TransactionEntity>(
      context: context,
      builder: (_) => _EditTransactionDialog(transaction: transaction, categories: categories),
    );
    if (result == null) return;

    await _transactions.update(result);
    if (result.categoryId != transaction.categoryId) {
      await _learning.recordCorrection(
        userId: transaction.userId,
        text: result.description,
        categoryId: result.categoryId,
      );
    }
    await _loadTransactions();
  }

  Future<void> _deleteTransaction(TransactionEntity transaction) async {
    await _transactions.delete(transaction.id);
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context).session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinChat'),
        actions: [
          IconButton(
            onPressed: session == null ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportScreen(userId: session.userId))),
            tooltip: 'Laporan',
            icon: const Icon(Icons.analytics_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(onPressed: SessionScope.of(context).logout, tooltip: 'Keluar', icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _items.isEmpty
                  ? _EmptyChat(email: session?.email ?? '')
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final transaction = _items[index];
                        return Dismissible(
                          key: ValueKey(transaction.id),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.blue,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              await _editTransaction(transaction);
                              return false;
                            }
                            await _deleteTransaction(transaction);
                            return true;
                          },
                          child: _TransactionCard(
                            transaction: transaction,
                            onEdit: () => _editTransaction(transaction),
                            onDelete: () => _deleteTransaction(transaction),
                          ),
                        );
                      },
                    ),
            ),
            _Composer(controller: _inputController, busy: _processing, onSubmit: _processAndSave),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.onEdit, required this.onDelete});
  final TransactionEntity transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final income = transaction.type == TransactionType.income;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Icon(income ? Icons.arrow_downward : Icons.arrow_upward)),
        title: Text(transaction.description),
        subtitle: Text('${_date(transaction.transactionDate)} • ${transaction.categoryId}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_money(transaction.amount)),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), tooltip: 'Edit'),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), tooltip: 'Hapus'),
          ],
        ),
      ),
    );
  }
}

class _EditTransactionDialog extends StatefulWidget {
  const _EditTransactionDialog({required this.transaction, required this.categories});
  final TransactionEntity transaction;
  final List<CategoryEntity> categories;

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late TransactionType _type;
  late String _categoryId;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.transaction.description);
    _amount = TextEditingController(text: widget.transaction.amount.toStringAsFixed(0));
    _type = widget.transaction.type;
    _categoryId = widget.transaction.categoryId;
    _date = widget.transaction.transactionDate;
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amount.text.replaceAll('.', '').replaceAll(',', '.'));
    if (amount == null || amount <= 0 || _description.text.trim().isEmpty) return;
    final now = DateTime.now();
    Navigator.of(context).pop(TransactionEntity(
      id: widget.transaction.id,
      userId: widget.transaction.userId,
      type: _type,
      amount: amount,
      description: _description.text.trim(),
      categoryId: _categoryId,
      transactionDate: _date,
      transactionTime: widget.transaction.transactionTime,
      inputSource: widget.transaction.inputSource,
      processedBy: ProcessedBy.manual,
      confidence: widget.transaction.confidence,
      createdAt: widget.transaction.createdAt,
      updatedAt: now,
      syncStatus: 'local',
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Edit transaksi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _description, decoration: const InputDecoration(labelText: 'Keterangan')),
              TextField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp ')),
              const SizedBox(height: 12),
              DropdownButtonFormField<TransactionType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Jenis'),
                items: const [
                  DropdownMenuItem(value: TransactionType.expense, child: Text('Pengeluaran')),
                  DropdownMenuItem(value: TransactionType.income, child: Text('Pemasukan')),
                ],
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: widget.categories.any((c) => c.id == _categoryId) ? _categoryId : null,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (value) => setState(() => _categoryId = value ?? _categoryId),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tanggal: ${_date(_date)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final value = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (value != null) setState(() => _date = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
          FilledButton(onPressed: _save, child: const Text('Simpan')),
        ],
      );
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 64),
              const SizedBox(height: 16),
              Text('Halo ${email.isEmpty ? '' : email}'),
              const SizedBox(height: 8),
              const Text(
                'Ketik transaksi dengan bahasa sehari-hari. FinChat akan memisahkan beberapa transaksi dan langsung menyimpannya. Anda dapat edit atau hapus setelah tersimpan.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text('Contoh: Beli nasi 25rb dan bensin 50k'),
            ],
          ),
        ),
      );
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.busy, required this.onSubmit});
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Contoh: makan 25rb dan bensin 50k',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: busy ? null : onSubmit,
              icon: busy
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              tooltip: 'Proses transaksi',
            ),
          ],
        ),
      );
}

class _NoOpAiCategoryProvider implements AiCategoryProvider {
  @override
  Future<AiCategorySuggestion?> suggestCategory(AiCategoryRequest request) async => null;
}

String _money(double value) => 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (m) => '.') }';
String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
