class MoneyAmountParser {
  static const Map<String, double> _multipliers = {
    'rb': 1000,
    'ribu': 1000,
    'k': 1000,
    'jt': 1000000,
    'juta': 1000000,
    'm': 1000000,
    'miliar': 1000000000,
    'milyar': 1000000000,
    'b': 1000000000,
  };

  static final RegExp amountPattern = RegExp(
    r'(?<![\w])(?:rp\s*)?([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]+)?|[0-9]+(?:[.,][0-9]+)?)\s*'
    r'(rb|ribu|k|jt|juta|miliar|milyar|m|b)(?:\b|(?=\s|$))|'
    r'(?<![\w])(?:rp\s*)?([0-9]{1,3}(?:[.,][0-9]{3})+(?:\s*(?:rupiah))?\b)|'
    r'(?<![\w])rp\s*([0-9]+(?:[.,][0-9]+)?)\b',
    caseSensitive: false,
  );

  static double? parse(String rawNumber, {String? multiplier}) {
    var value = rawNumber.trim().replaceAll(' ', '');
    if (value.isEmpty) return null;

    if (value.contains('.') && value.contains(',')) {
      // Indonesian style: 1.234,56 -> 1234.56.
      if (value.lastIndexOf(',') > value.lastIndexOf('.')) {
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (value.contains(',')) {
      final parts = value.split(',');
      value = parts.length == 2 && parts.last.length == 3
          ? parts.join()
          : value.replaceAll(',', '.');
    } else if (value.contains('.')) {
      final parts = value.split('.');
      value = parts.length > 2 || (parts.length == 2 && parts.last.length == 3)
          ? parts.join()
          : value;
    }

    final number = double.tryParse(value);
    if (number == null) return null;
    final factor = _multipliers[multiplier?.toLowerCase() ?? ''] ?? 1;
    return number * factor;
  }

  static List<MoneyMatch> findAll(String input) {
    final matches = <MoneyMatch>[];
    for (final match in amountPattern.allMatches(input)) {
      final rawNumber = match.group(1) ?? match.group(3) ?? match.group(4);
      final suffix = match.group(2)?.toLowerCase();
      if (rawNumber == null) continue;
      final amount = parse(rawNumber, multiplier: suffix);
      if (amount == null) continue;
      matches.add(
        MoneyMatch(
          amount: amount,
          raw: match.group(0)!,
          start: match.start,
          end: match.end,
        ),
      );
    }
    return matches;
  }
}

class MoneyMatch {
  const MoneyMatch({
    required this.amount,
    required this.raw,
    required this.start,
    required this.end,
  });

  final double amount;
  final String raw;
  final int start;
  final int end;
}
