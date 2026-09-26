import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../../../lib/data/ocr/image_receipt_preprocessor.dart';
import '../../../lib/domain/ocr/receipt_image_preprocessor.dart';

void main() {
  test('preprocesses a receipt image into OCR-friendly JPEG bytes', () async {
    final source = img.Image(width: 2400, height: 1200);
    for (final pixel in source) {
      pixel
        ..r = 255
        ..g = 255
        ..b = 255;
    }
    final input = Uint8List.fromList(img.encodePng(source));

    final output = await const ImageReceiptPreprocessor().preprocess(
      input,
      config: const ReceiptImagePreprocessConfig(maxWidth: 1200),
    );

    final decoded = img.decodeImage(output);
    expect(decoded, isNotNull);
    expect(decoded!.width, 1200);
    expect(decoded.height, 600);
  });

  test('rejects empty image input', () async {
    expect(
      () => const ImageReceiptPreprocessor().preprocess(Uint8List(0)),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unsupported image bytes', () async {
    expect(
      () => const ImageReceiptPreprocessor().preprocess(
        Uint8List.fromList(<int>[1, 2, 3, 4]),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
