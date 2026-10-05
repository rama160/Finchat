String normalizeSpokenMoney(String input) {
  const units = {'nol': 0, 'satu': 1, 'dua': 2, 'tiga': 3, 'empat': 4, 'lima': 5, 'enam': 6, 'tujuh': 7, 'delapan': 8, 'sembilan': 9, 'sepuluh': 10, 'sebelas': 11, 'seratus': 100};
  final pattern = RegExp(r'\b((?:(?:nol|satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|seratus|belas|puluh|ratus)\s+)+)(ribu|juta|miliar|rupiah)\b', caseSensitive: false);
  return input.replaceAllMapped(pattern, (match) {
    var total = 0;
    var current = 0;
    for (final word in match[1]!.trim().toLowerCase().split(RegExp(r'\s+'))) {
      if (word == 'belas') { current += 10; }
      else if (word == 'puluh') { current *= 10; }
      else if (word == 'ratus') { total += current * 100; current = 0; }
      else { current += units[word] ?? 0; }
    }
    final value = total + current;
    return match[2]!.toLowerCase() == 'rupiah' ? 'Rp $value' : '$value ${match[2]}';
  });
}
