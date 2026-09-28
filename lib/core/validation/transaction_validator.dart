import '../../domain/entities/transaction_entity.dart';

class TransactionValidator {
  const TransactionValidator._();

  static void validateInput(String input) {
    final value = input.trim();
    if (value.isEmpty) throw const FormatException('Input transaksi kosong.');
    if (value.length > 2000) throw const FormatException('Input transaksi terlalu panjang. Maksimal 2000 karakter.');
  }

  static void validate(TransactionEntity transaction) {
    if (transaction.id.trim().isEmpty) throw const FormatException('ID transaksi tidak boleh kosong.');
    if (transaction.userId.trim().isEmpty) throw const FormatException('User ID transaksi tidak boleh kosong.');
    if (transaction.description.trim().isEmpty) throw const FormatException('Keterangan transaksi tidak boleh kosong.');
    if (transaction.description.length > 1000) throw const FormatException('Keterangan transaksi terlalu panjang.');
    if (!transaction.amount.isFinite || transaction.amount <= 0) throw const FormatException('Nominal transaksi harus lebih besar dari nol.');
    if (!transaction.confidence.isFinite || transaction.confidence < 0 || transaction.confidence > 1) throw const FormatException('Confidence transaksi harus berada di antara 0 dan 1.');
    if (transaction.categoryId.trim().isEmpty) throw const FormatException('Kategori transaksi tidak boleh kosong.');
  }
}
