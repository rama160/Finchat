import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:finchat/application/ocr/receipt_ocr_service.dart';
import 'package:finchat/data/ocr/image_receipt_preprocessor.dart';
import 'package:finchat/domain/ocr/receipt_ocr.dart';

class _FakeReceiptOcrProvider implements ReceiptOcrProvider {
  String? receivedPath;

  @override
  Future<ReceiptOcrResult> recognizeText(String imagePath) async {
    receivedPath = imagePath;
    expect(File(imagePath).existsSync(), isTrue);
    return const ReceiptOcrResult(
      rawText: 'TOKO ABC\nTOTAL RP 25.000',
      blockCount: 2,
      lineCount: 2,
    );
  }
}

void main() {
  test('preprocesses bytes, sends a temporary file to OCR, and cleans it up', () async {
    final source = img.Image(width: 800, height: 400);
    for (final pixel in source) {
      pixel
        ..r = 255
        ..g = 255
        ..b = 255;
    }

    final provider = _FakeReceiptOcrProvider();
    final service = ReceiptOcrService(
      preprocessor: const ImageReceiptPreprocessor(),
      provider: provider,
    );

    final path = '${Directory.systemTemp.path}/finchat_receipt_ocr_test.jpg';
    final result = await service.processImageBytes(
      imageBytes: Uint8List.fromList(img.encodePng(source)),
      workingImagePath: path,
    );

    expect(result.hasText, isTrue);
    expect(result.rawText, contains('TOTAL RP 25.000'));
    expect(provider.receivedPath, path);
    expect(File(path).existsSync(), isFalse);
  });
}
