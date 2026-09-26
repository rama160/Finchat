import 'dart:io';
import 'dart:typed_data';

import '../../domain/ocr/receipt_image_preprocessor.dart';
import '../../domain/ocr/receipt_ocr.dart';

class ReceiptOcrService {
  const ReceiptOcrService({
    required ReceiptImagePreprocessor preprocessor,
    required ReceiptOcrProvider provider,
  })  : _preprocessor = preprocessor,
        _provider = provider;

  final ReceiptImagePreprocessor _preprocessor;
  final ReceiptOcrProvider _provider;

  Future<ReceiptOcrResult> processImageBytes({
    required Uint8List imageBytes,
    required String workingImagePath,
    ReceiptImagePreprocessConfig config = const ReceiptImagePreprocessConfig(),
  }) async {
    if (workingImagePath.trim().isEmpty) {
      throw ArgumentError.value(
        workingImagePath,
        'workingImagePath',
        'must not be empty',
      );
    }

    final processed = await _preprocessor.preprocess(imageBytes, config: config);
    final file = File(workingImagePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(processed, flush: true);

    try {
      return await _provider.recognizeText(file.path);
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
