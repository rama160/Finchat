class ReceiptOcrResult {
  const ReceiptOcrResult({
    required this.rawText,
    required this.blockCount,
    required this.lineCount,
    this.lines = const [],
  });

  final String rawText;
  final int blockCount;
  final int lineCount;
  final List<ReceiptOcrLine> lines;

  bool get hasText => rawText.trim().isNotEmpty;
}

abstract interface class ReceiptOcrProvider {
  Future<ReceiptOcrResult> recognizeText(String imagePath);
}

/// Image coordinates retain reading order when OCR returns separate columns.
class ReceiptOcrLine {
  const ReceiptOcrLine({required this.text, required this.left, required this.top,
    required this.right, required this.bottom});
  final String text;
  final double left, top, right, bottom;
}

List<String> receiptReadingRows(List<ReceiptOcrLine> lines) {
  final sorted = [...lines]..sort((a, b) => a.top.compareTo(b.top));
  final rows = <List<ReceiptOcrLine>>[];
  for (final line in sorted) {
    if (line.text.trim().isEmpty) continue;
    final center = (line.top + line.bottom) / 2;
    List<ReceiptOcrLine>? matching;
    for (final row in rows.reversed) {
      final anchor = row.first;
      final anchorCenter = (anchor.top + anchor.bottom) / 2;
      final height = (line.bottom - line.top) < (anchor.bottom - anchor.top)
          ? line.bottom - line.top : anchor.bottom - anchor.top;
      if ((center - anchorCenter).abs() <= height * .45) {
        matching = row;
        break;
      }
    }
    if (matching == null) {
      rows.add([line]);
    } else {
      matching.add(line);
    }
  }
  return rows.map((row) {
    row.sort((a, b) => a.left.compareTo(b.left));
    return row.map((line) => line.text).join(' ');
  }).toList();
}
