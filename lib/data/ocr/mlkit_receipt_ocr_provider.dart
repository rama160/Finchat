import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/ocr/receipt_ocr.dart';

class MlKitReceiptOcrProvider implements ReceiptOcrProvider {
  MlKitReceiptOcrProvider({TextRecognitionScript script = TextRecognitionScript.latin})
      : _recognizer = TextRecognizer(script: script);

  final TextRecognizer _recognizer;
  bool _closed = false;

  @override
  Future<ReceiptOcrResult> recognizeText(String imagePath) async {
    if (_closed) {
      throw StateError('Receipt OCR provider has been closed.');
    }
    if (imagePath.trim().isEmpty) {
      throw ArgumentError.value(imagePath, 'imagePath', 'must not be empty');
    }

    final result = await _recognizer.processImage(InputImage.fromFilePath(imagePath));
    var lineCount = 0;
    for (final block in result.blocks) {
      lineCount += block.lines.length;
    }

    return ReceiptOcrResult(
      rawText: result.text.trim(),
      blockCount: result.blocks.length,
      lineCount: lineCount,
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _recognizer.close();
  }
}
