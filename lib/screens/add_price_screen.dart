import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/product_price.dart';

class AddPriceScreen extends StatefulWidget {
  final StorageService storageService;

  const AddPriceScreen({super.key, required this.storageService});

  @override
  State<AddPriceScreen> createState() => _AddPriceScreenState();
}

class _AddPriceScreenState extends State<AddPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _shopController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  NotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    // Charger les suggestions depuis les données existantes
    // TODO: Implémenter l'autocomplétion avec les produits et magasins existants
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _savePrice() async {
    if (_formKey.currentState!.validate()) {
      final productPrice = ProductPrice(
        productName: _productNameController.text.trim(),
        price: double.parse(_priceController.text),
        shop: _shopController.text.trim(),
        date: _selectedDate,
      );

      await widget.storageService.addProductPrice(productPrice);

      // Vérifier les alertes
      if (_notificationService != null) {
        await _notificationService!.checkPriceAlerts(productPrice);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prix enregistré avec succès !')),
        );
        Navigator.pop(context);
      }
    }
  }

  void setNotificationService(NotificationService service) {
    _notificationService = service;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _shopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisir un prix'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du produit',
                hintText: 'Ex: Riz 25kg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer le nom du produit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Prix (FCFA)',
                hintText: 'Ex: 12000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer le prix';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Veuillez entrer un prix valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shopController,
              decoration: const InputDecoration(
                labelText: 'Magasin ou marché',
                hintText: 'Ex: Carrefour, Marché d\'Adjamé',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer le nom du magasin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePrice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
