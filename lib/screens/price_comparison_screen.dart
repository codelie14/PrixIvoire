import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/product_price.dart';

class PriceComparisonScreen extends StatefulWidget {
  final StorageService storageService;

  const PriceComparisonScreen({super.key, required this.storageService});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  List<ProductPrice> _allPrices = [];
  List<ProductPrice> _filteredPrices = [];
  String? _selectedProduct;
  String? _selectedShop;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  void _loadPrices() {
    setState(() {
      _allPrices = widget.storageService.getAllProductPrices();
      _allPrices.sort((a, b) => b.date.compareTo(a.date));
      _filteredPrices = _allPrices;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredPrices = _allPrices.where((price) {
        if (_selectedProduct != null && price.productName != _selectedProduct) {
          return false;
        }
        if (_selectedShop != null && price.shop != _selectedShop) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.storageService.getAllProductNames();
    final shops = widget.storageService.getAllShops();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparaison des prix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Filtres'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProduct,
                        decoration: const InputDecoration(labelText: 'Produit'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous les produits'),
                          ),
                          ...products.map(
                            (product) => DropdownMenuItem(
                              value: product,
                              child: Text(product),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedProduct = value;
                          });
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedShop,
                        decoration: const InputDecoration(labelText: 'Magasin'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous les magasins'),
                          ),
                          ...shops.map(
                            (shop) => DropdownMenuItem(
                              value: shop,
                              child: Text(shop),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedShop = value;
                          });
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedProduct = null;
                          _selectedShop = null;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Réinitialiser'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _filteredPrices.isEmpty
          ? const Center(child: Text('Aucun prix enregistré'))
          : ListView.builder(
              itemCount: _filteredPrices.length,
              itemBuilder: (context, index) {
                final price = _filteredPrices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      price.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(price.shop),
                        Text(
                          DateFormat('dd/MM/yyyy').format(price.date),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${price.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
