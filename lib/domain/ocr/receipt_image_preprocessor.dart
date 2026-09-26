import 'dart:typed_data';

class ReceiptImagePreprocessConfig {
  const ReceiptImagePreprocessConfig({
    this.maxWidth = 1800,
    this.jpegQuality = 90,
    this.contrast = 1.15,
  });

  final int maxWidth;
  final int jpegQuality;
  final double contrast;
}

abstract interface class ReceiptImagePreprocessor {
  Future<Uint8List> preprocess(
    Uint8List input, {
    ReceiptImagePreprocessConfig config = const ReceiptImagePreprocessConfig(),
  });
}
