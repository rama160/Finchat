import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/ocr/receipt_image_preprocessor.dart';

class ImageReceiptPreprocessor implements ReceiptImagePreprocessor {
  const ImageReceiptPreprocessor();

  @override
  Future<Uint8List> preprocess(
    Uint8List input, {
    ReceiptImagePreprocessConfig config = const ReceiptImagePreprocessConfig(),
  }) async {
    if (input.isEmpty) {
      throw const FormatException('Receipt image is empty.');
    }

    img.Image? decoded;
    try {
      decoded = img.decodeImage(input);
    } catch (_) {
      throw const FormatException('Receipt image format is not supported.');
    }

    if (decoded == null) {
      throw const FormatException('Receipt image format is not supported.');
    }

    var image = img.bakeOrientation(decoded);
    if (image.width > config.maxWidth) {
      image = img.copyResize(
        image,
        width: config.maxWidth,
        maintainAspect: true,
        interpolation: img.Interpolation.cubic,
      );
    }

    image = img.grayscale(image);
    image = img.adjustColor(image, contrast: config.contrast);

    return Uint8List.fromList(
      img.encodeJpg(image, quality: config.jpegQuality),
    );
  }
}
