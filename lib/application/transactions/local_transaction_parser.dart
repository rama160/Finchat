import '../../domain/parsing/money_amount_parser.dart';

class ParsedTransaction {
  const ParsedTransaction({
    required this.amount,
    required this.description,
    required this.type,
    required this.categoryId,
    required this.confidence,
  });

  final double amount;
  final String description;
  final ParsedTransactionType type;
  final String categoryId;
  final double confidence;
}

enum ParsedTransactionType { income, expense }

class LocalTransactionParser {
  static const _incomeWords = <String>{
    'gaji',
    'bonus',
    'honor',
    'honorarium',
    'pendapatan',
    'pemasukan',
    'terima',
    'menerima',
    'transfer masuk',
    'refund',
  };

  static const _expenseWords = <String>{
    'beli',
    'bayar',
    'belanja',
    'pengeluaran',
    'keluar',
    'makan',
    'minum',
    'bensin',
    'ongkos',
    'tagihan',
    'sewa',
  };

  List<ParsedTransaction> parse(String input) {
    final source = input.trim();
    if (source.isEmpty) return const [];

    final money = MoneyAmountParser.findAll(source);
    if (money.isEmpty) return const [];

    final results = <ParsedTransaction>[];
    for (var i = 0; i < money.length; i++) {
      final current = money[i];
      final previousEnd = i == 0 ? 0 : money[i - 1].end;
      final nextStart = i + 1 < money.length ? money[i + 1].start : source.length;

      var description = source.substring(previousEnd, current.start);
      if (i > 0) {
        description = description.replaceFirst(
          RegExp(r'^\s*(?:dan|lalu|kemudian|serta|,|;)+\s*', caseSensitive: false),
          '',
        );
      }
      if (description.trim().isEmpty && i + 1 < money.length) {
        description = source.substring(current.end, nextStart);
      }
      description = _cleanDescription(description);

      final contextStart = i == 0 ? 0 : previousEnd;
      final context = source.substring(contextStart, current.end).toLowerCase();
      final type = _detectType(context);
      results.add(
        ParsedTransaction(
          amount: current.amount,
          description: description.isEmpty ? 'Transaksi' : description,
          type: type,
          categoryId: _detectCategory('$context $description'),
          confidence: _confidence(current.raw, description, type),
        ),
      );
    }
    return results;
  }

  ParsedTransactionType _detectType(String context) {
    if (_incomeWords.any(context.contains)) return ParsedTransactionType.income;
    if (_expenseWords.any(context.contains)) return ParsedTransactionType.expense;
    return ParsedTransactionType.expense;
  }

  String _detectCategory(String context) {
    if (context.contains('gaji') || context.contains('honor')) return 'gaji';
    if (context.contains('bensin') || context.contains('solar') || context.contains('parkir')) {
      return 'transportasi';
    }
    if (context.contains('makan') || context.contains('nasi')) {
      return 'makanan';
    }
    if (context.contains('tagihan') || context.contains('listrik') || context.contains('air')) {
      return 'tagihan';
    }
    return 'lainnya';
  }

  double _confidence(String rawAmount, String description, ParsedTransactionType type) {
    var score = 0.7;
    if (RegExp(r'(rp|rb|ribu|k|jt|juta|miliar|milyar|\bm\b|\bb\b)', caseSensitive: false).hasMatch(rawAmount)) {
      score += 0.15;
    }
    if (description.trim().length >= 3) score += 0.1;
    if (type == ParsedTransactionType.expense || type == ParsedTransactionType.income) score += 0.05;
    return score.clamp(0, 1).toDouble();
  }

  String _cleanDescription(String value) {
    return value
        .replaceAll(RegExp(r'^\s*(?:dan|lalu|kemudian|serta|,|;)+\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
