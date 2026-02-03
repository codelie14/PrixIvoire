import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String?> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<File?> takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Extraire les prix depuis le texte OCR
  List<Map<String, dynamic>> extractPricesFromText(String text) {
    final List<Map<String, dynamic>> prices = [];
    
    // Expression régulière pour trouver les prix (format: nombre FCFA ou nombre F)
    final RegExp pricePattern = RegExp(r'(\d+(?:\s?\d+)*(?:\s?[.,]\d+)?)\s*(?:FCFA|F|francs?)', caseSensitive: false);
    
    final matches = pricePattern.allMatches(text);
    for (final match in matches) {
      final priceStr = match.group(1)?.replaceAll(RegExp(r'[\s.,]'), '') ?? '';
      final price = double.tryParse(priceStr);
      if (price != null && price > 0) {
        prices.add({
          'price': price,
          'context': match.group(0) ?? '',
        });
      }
    }
    
    return prices;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
