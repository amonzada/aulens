import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts printed text from whiteboard images using Google ML Kit
/// (on-device, no network required).
class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  /// Runs text recognition on the image at [imagePath] and returns the
  /// extracted text, or `null` when the image contains no readable text
  /// or when recognition fails.
  ///
  /// A fresh [TextRecognizer] is created and closed for every call so that
  /// no native resources are held between captures.
  Future<String?> extractText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFile(File(imagePath));
      final result = await recognizer.processImage(input);
      final text = result.text.trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      // OCR failure is non-fatal – the note is still saved without text.
      return null;
    } finally {
      await recognizer.close();
    }
  }
}
