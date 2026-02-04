import 'package:flutter/material.dart';
import '../services/autocomplete_service.dart';
import 'autocomplete_text_field.dart';
import 'simple_autocomplete_field.dart';

/// Exemple d'utilisation des widgets d'autocomplétion
/// 
/// Ce fichier démontre comment intégrer les widgets d'autocomplétion
/// dans un formulaire. Il peut être utilisé comme référence pour
/// l'intégration dans AddPriceScreen et autres écrans.
class AutocompleteExampleScreen extends StatefulWidget {
  const AutocompleteExampleScreen({super.key});

  @override
  State<AutocompleteExampleScreen> createState() => _AutocompleteExampleScreenState();
}

class _AutocompleteExampleScreenState extends State<AutocompleteExampleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();
  final _autocompleteService = AutocompleteService();
  bool _isInitialized = false;
  bool _useSimpleVersion = true; // Toggle entre les deux versions

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _autocompleteService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _productController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    _autocompleteService.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Produit: ${_productController.text}, '
            'Magasin: ${_storeController.text}, '
            'Prix: ${_priceController.text} FCFA',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Autocomplétion'),
        actions: [
          IconButton(
            icon: Icon(_useSimpleVersion ? Icons.toggle_on : Icons.toggle_off),
            onPressed: () {
              setState(() {
                _useSimpleVersion = !_useSimpleVersion;
              });
            },
            tooltip: _useSimpleVersion 
                ? 'Version Simple (Autocomplete natif)'
                : 'Version Personnalisée',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info sur la version utilisée
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _useSimpleVersion
                        ? 'Version Simple (Autocomplete natif de Flutter)'
                        : 'Version Personnalisée (Overlay manuel)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Champ Produit
              if (_useSimpleVersion)
                SimpleAutocompleteField(
                  controller: _productController,
                  type: AutocompleteType.product,
                  autocompleteService: _autocompleteService,
                  label: 'Nom du produit',
                  hintText: 'Ex: Riz 25kg',
                  icon: Icons.shopping_basket,
                  required: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom du produit est requis';
                    }
                    if (value.trim().length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                  onSelected: (value) {
                    // Produit sélectionné
                  },
                )
              else
                AutocompleteTextField(
                  controller: _productController,
                  type: AutocompleteType.product,
                  autocompleteService: _autocompleteService,
                  label: 'Nom du produit',
                  hintText: 'Ex: Riz 25kg',
                  icon: Icons.shopping_basket,
                  required: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom du produit est requis';
                    }
                    if (value.trim().length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                  onSelected: (value) {
                    // Produit sélectionné
                  },
                ),
              const SizedBox(height: 16),

              // Champ Magasin
              if (_useSimpleVersion)
                SimpleAutocompleteField(
                  controller: _storeController,
                  type: AutocompleteType.store,
                  autocompleteService: _autocompleteService,
                  label: 'Nom du magasin',
                  hintText: 'Ex: Carrefour',
                  icon: Icons.store,
                  required: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom du magasin est requis';
                    }
                    return null;
                  },
                  onSelected: (value) {
                    // Magasin sélectionné
                  },
                )
              else
                AutocompleteTextField(
                  controller: _storeController,
                  type: AutocompleteType.store,
                  autocompleteService: _autocompleteService,
                  label: 'Nom du magasin',
                  hintText: 'Ex: Carrefour',
                  icon: Icons.store,
                  required: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom du magasin est requis';
                    }
                    return null;
                  },
                  onSelected: (value) {
                    // Magasin sélectionné
                  },
                ),
              const SizedBox(height: 16),

              // Champ Prix (sans autocomplétion)
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Prix *',
                  hintText: 'Ex: 15000',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prix est requis';
                  }
                  final price = double.tryParse(value);
                  if (price == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (price <= 0) {
                    return 'Le prix doit être positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                ),
              ),
              const SizedBox(height: 16),

              // Informations sur les suggestions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistiques d\'autocomplétion',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        'Produits uniques',
                        _autocompleteService
                            .getFrequencyMap(AutocompleteType.product)
                            .length
                            .toString(),
                      ),
                      _buildStatRow(
                        'Magasins uniques',
                        _autocompleteService
                            .getFrequencyMap(AutocompleteType.store)
                            .length
                            .toString(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
