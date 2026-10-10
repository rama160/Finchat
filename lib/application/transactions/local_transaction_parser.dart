import '../../domain/parsing/money_amount_parser.dart';
import '../../domain/parsing/spoken_money_normalizer.dart';

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
    'gajian',
    'salary',
    'upah',
    'komisi',
    'thr',
    'dividen',
    'uang masuk',
    'hasil jual',
    'hasil penjualan',
    'pensiun',
    'insentif',
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
    // Bare salary amounts are common in typed input ("gaji 5000000").
    // Add a currency prefix only beside an income keyword, never to dates.
    final source = normalizeSpokenMoney(input).trim().replaceAllMapped(
      RegExp(r'\b(gaji|gajian|salary|upah|honor|honorarium|bonus|komisi|thr|pemasukan|pendapatan|uang masuk)\s+(\d{4,})(?![\d.,])', caseSensitive: false),
      (match) => '${match[1]} Rp ${match[2]}',
    );
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
    if (RegExp(r'\b(bayar|membayar|beli|belanja)\b').hasMatch(context)) return ParsedTransactionType.expense;
    if (_incomeWords.any((word) => RegExp(r'\b' + RegExp.escape(word) + r'\b').hasMatch(context))) return ParsedTransactionType.income;
    if (_expenseWords.any(context.contains)) return ParsedTransactionType.expense;
    return ParsedTransactionType.expense;
  }

  String _detectCategory(String context) {
    if (RegExp(r'\b(gaji|gajian|salary|upah|honor|honorarium|thr)\b').hasMatch(context)) return 'gaji';
    if (context.contains('bensin') || context.contains('solar') || context.contains('parkir')) {
      return 'transportasi';
    }
    if (RegExp(r'\b(makan\w*|minum\w*|nasi|bakso|kopi|teh|roti|mie|mi|jajan|susu|air mineral)\b').hasMatch(context)) {
      return 'makanan';
    }
    if (RegExp(r'\b(tagihan|listrik|air|internet|pulsa|wifi)\b').hasMatch(context)) {
      return 'tagihan';
    }
    if (RegExp(r'\b(obat|dokter|rumah sakit|klinik|vitamin|apotek)\b').hasMatch(context)) return 'kesehatan';
    if (RegExp(r'\b(sabun|deterjen|pampers|gas|elpiji|galon)\b').hasMatch(context)) return 'belanja_dapur';
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
