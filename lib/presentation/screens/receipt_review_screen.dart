import '../../core/formatting/rupiah.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';

class ReceiptReviewItem {
  ReceiptReviewItem({
    required this.description,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.processedBy = ProcessedBy.manual,
    this.confidence = 0.0,
  });

  String description;
  double amount;
  TransactionType type;
  String categoryId;
  ProcessedBy processedBy;
  double confidence;
}

class ReceiptReviewScreen extends StatefulWidget {
  const ReceiptReviewScreen({super.key, required this.items, required this.categories});

  final List<ReceiptReviewItem> items;
  final List<CategoryEntity> categories;

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  late final List<ReceiptReviewItem> _items = widget.items
      .map((item) => ReceiptReviewItem(
            description: item.description,
            amount: item.amount,
            type: item.type,
            categoryId: item.categoryId,
            processedBy: item.processedBy,
            confidence: item.confidence,
          ))
      .toList();

  void _edit(int index) async {
    final item = _items[index];
    final description = TextEditingController(text: item.description);
    final amount = TextEditingController(text: item.amount.toStringAsFixed(0));
    var type = item.type;
    var category = item.categoryId;

    final result = await showDialog<ReceiptReviewItem>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Periksa transaksi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: description, decoration: const InputDecoration(labelText: 'Keterangan')),
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp '),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Jenis'),
                  items: const [
                    DropdownMenuItem(value: TransactionType.expense, child: Text('Pengeluaran')),
                    DropdownMenuItem(value: TransactionType.income, child: Text('Pemasukan')),
                  ],
                  onChanged: (value) => setDialogState(() => type = value ?? type),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: widget.categories.any((c) => c.id == category) ? category : null,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (value) => setDialogState(() => category = value ?? category),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final parsedAmount = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '.'));
                if (parsedAmount == null || parsedAmount <= 0 || description.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  ReceiptReviewItem(
                    description: description.text.trim(),
                    amount: parsedAmount,
                    type: type,
                    categoryId: category,
                    processedBy: item.processedBy,
                    confidence: item.confidence,
                  ),
                );
              },
              child: const Text('Simpan perubahan'),
            ),
          ],
        ),
      ),
    );

    description.dispose();
    amount.dispose();
    if (result != null && mounted) setState(() => _items[index] = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periksa struk'),
        actions: [
          IconButton(
            tooltip: 'Simpan semua',
            onPressed: _items.isEmpty ? null : () => Navigator.pop(context, _items),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Tidak ada transaksi yang dapat dikenali dari struk.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.description),
                    subtitle: Text('${item.categoryId} • ${item.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_money(item.amount)),
                        IconButton(onPressed: () => _edit(index), icon: const Icon(Icons.edit_outlined)),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, _items),
                icon: const Icon(Icons.save_outlined),
                label: Text('Simpan ${_items.length} transaksi'),
              ),
            ),
    );
  }
}

String _money(double value) => formatRupiah(value);
