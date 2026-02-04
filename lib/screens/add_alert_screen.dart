import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/price_alert.dart';

class AddAlertScreen extends StatefulWidget {
  final StorageService storageService;

  const AddAlertScreen({super.key, required this.storageService});

  @override
  State<AddAlertScreen> createState() => _AddAlertScreenState();
}

class _AddAlertScreenState extends State<AddAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _thresholdController = TextEditingController();
  String? _selectedProduct;
  bool _isAbove = true;

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveAlert() async {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
      final alert = PriceAlert(
        productName: _selectedProduct!,
        threshold: double.parse(_thresholdController.text),
        isAbove: _isAbove,
      );

      await widget.storageService.addPriceAlert(alert);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerte créée avec succès !')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.storageService.getAllProductNames();

    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Créer une alerte')),
        body: const Center(
          child: Text(
            'Aucun produit enregistré. Veuillez d\'abord ajouter des prix.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Créer une alerte')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Semantics(
              label: 'Sélectionner un produit pour l\'alerte',
              child: DropdownButtonFormField<String>(
                initialValue: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Produit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                items: products.map((product) {
                  return DropdownMenuItem(value: product, child: Text(product));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un produit';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thresholdController,
              decoration: const InputDecoration(
                labelText: 'Seuil de prix (FCFA)',
                hintText: 'Ex: 12000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer le seuil';
                }
                final threshold = double.tryParse(value);
                if (threshold == null || threshold <= 0) {
                  return 'Veuillez entrer un seuil valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Type d\'alerte:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Au-dessus'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('En-dessous'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_isAbove},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isAbove = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Créer l\'alerte de prix',
              button: true,
              child: ElevatedButton(
                onPressed: _saveAlert,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Créer l\'alerte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
