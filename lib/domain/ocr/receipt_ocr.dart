class ReceiptOcrResult {
  const ReceiptOcrResult({
    required this.rawText,
    required this.blockCount,
    required this.lineCount,
  });

  final String rawText;
  final int blockCount;
  final int lineCount;

  bool get hasText => rawText.trim().isNotEmpty;
}

abstract interface class ReceiptOcrProvider {
  Future<ReceiptOcrResult> recognizeText(String imagePath);
}
