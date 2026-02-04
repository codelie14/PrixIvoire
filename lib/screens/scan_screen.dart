import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/ocr_service.dart';
import '../core/utils/page_transitions.dart';
import 'add_price_screen.dart';

class ScanScreen extends StatefulWidget {
  final StorageService storageService;

  const ScanScreen({super.key, required this.storageService});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final OCRService _ocrService = OCRService();
  File? _selectedImage;
  String? _extractedText;
  List<Map<String, dynamic>> _extractedPrices = [];
  bool _isProcessing = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _ocrService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _extractedText = null;
        _extractedPrices = [];
      });
      await _processImage(image);
    }
  }

  Future<void> _takePhoto() async {
    final image = await _ocrService.takePhoto();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _extractedText = null;
        _extractedPrices = [];
      });
      await _processImage(image);
    }
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final text = await _ocrService.extractTextFromImage(image);
      if (text != null && text.isNotEmpty) {
        final prices = _ocrService.extractPricesFromText(text);
        setState(() {
          _extractedText = text;
          _extractedPrices = prices;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun texte détecté dans l\'image'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du traitement: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // TODO: Implémenter la sauvegarde directe depuis les prix détectés

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un prospectus'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Prendre une photo avec l\'appareil',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Prendre une photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    label: 'Choisir une image depuis la galerie',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choisir une image'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            
            if (_selectedImage != null && !_isProcessing) ...[
              Semantics(
                label: 'Image sélectionnée pour la reconnaissance de texte',
                image: true,
                child: Image.file(
                  _selectedImage!,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_extractedText != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Texte extrait:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_extractedText!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_extractedPrices.isNotEmpty) ...[
              const Text(
                'Prix détectés:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              ..._extractedPrices.map((priceData) => Card(
                child: Semantics(
                  label: 'Prix détecté: ${priceData['price'].toStringAsFixed(0)} francs CFA',
                  child: ListTile(
                    title: Text('${priceData['price'].toStringAsFixed(0)} FCFA'),
                    subtitle: Text('Contexte: ${priceData['context']}'),
                    trailing: Semantics(
                      label: 'Ajouter ce prix',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          // Ouvrir l'écran de saisie avec le prix pré-rempli
                          Navigator.push(
                            context,
                            SlideUpPageRoute(
                              page: AddPriceScreen(
                                storageService: widget.storageService,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
