import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/favorites_manager.dart';
import '../models/product_price.dart';

class PriceComparisonScreen extends StatefulWidget {
  final StorageService storageService;
  final FavoritesManager? favoritesManager;

  const PriceComparisonScreen({
    super.key,
    required this.storageService,
    this.favoritesManager,
  });

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
  
  /// Toggle le statut favori d'un produit
  Future<void> _toggleFavorite(String productName) async {
    if (widget.favoritesManager == null) return;
    
    try {
      final isFavorite = widget.favoritesManager!.isFavorite(productName);
      
      if (isFavorite) {
        await widget.favoritesManager!.removeFavorite(productName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$productName retiré des favoris'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await widget.favoritesManager!.addFavorite(productName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$productName ajouté aux favoris'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      
      // Recharger pour mettre à jour l'affichage
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          Semantics(
            label: 'Ouvrir les filtres',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.filter_alt),
              tooltip: 'Filtrer les prix',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Filtres'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: 'Filtrer par produit',
                          child: DropdownButtonFormField<String>(
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
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Filtrer par magasin',
                          child: DropdownButtonFormField<String>(
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
          ),
        ],
      ),
      body: _filteredPrices.isEmpty
          ? const Center(child: Text('Aucun prix enregistré'))
          : ListView.builder(
              itemCount: _filteredPrices.length,
              itemBuilder: (context, index) {
                final price = _filteredPrices[index];
                final isFavorite = widget.favoritesManager?.isFavorite(price.productName) ?? false;
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Semantics(
                    label: '${price.productName}, ${price.price.toStringAsFixed(0)} francs CFA, ${price.shop}, ${DateFormat('dd MMMM yyyy', 'fr_FR').format(price.date)}',
                    child: ListTile(
                      leading: widget.favoritesManager != null
                          ? Semantics(
                              label: isFavorite 
                                  ? 'Retirer ${price.productName} des favoris' 
                                  : 'Ajouter ${price.productName} aux favoris',
                              button: true,
                              child: IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.star : Icons.star_border,
                                  color: isFavorite ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () => _toggleFavorite(price.productName),
                                tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                              ),
                            )
                          : null,
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
                  ),
                );
              },
            ),
    );
  }
}
