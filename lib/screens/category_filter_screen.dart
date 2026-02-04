import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/category_manager.dart';
import '../models/product_price.dart';

/// Écran de filtrage des produits par catégorie
/// 
/// Permet de :
/// - Voir toutes les catégories avec leur nombre de produits
/// - Filtrer les produits par catégorie
/// - Afficher les produits d'une catégorie sélectionnée
class CategoryFilterScreen extends StatefulWidget {
  final StorageService storageService;

  const CategoryFilterScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  final _categoryManager = CategoryManager();
  String? _selectedCategoryId;
  List<ProductPrice> _filteredPrices = [];
  Map<String, int> _categoryCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allPrices = widget.storageService.getAllProductPrices();
      
      // Calculer les comptages par catégorie
      final counts = _categoryManager.getCategoryCounts(allPrices);

      setState(() {
        _categoryCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      final allPrices = widget.storageService.getAllProductPrices();
      _filteredPrices = _categoryManager.filterByCategory(allPrices, categoryId);
      // Trier par date décroissante
      _filteredPrices.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedCategoryId = null;
      _filteredPrices = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrer par catégorie'),
        actions: [
          if (_selectedCategoryId != null)
            Semantics(
              label: 'Effacer le filtre',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearFilter,
                tooltip: 'Effacer le filtre',
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedCategoryId == null
              ? _buildCategoryList()
              : _buildFilteredProductList(),
    );
  }

  Widget _buildCategoryList() {
    final categories = _categoryManager.getAllCategories();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Sélectionnez une catégorie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) {
          final count = _categoryCounts[category.id] ?? 0;
          
          return Semantics(
            label: '${category.name}, $count produits',
            button: true,
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 28,
                  ),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: count > 0 ? () => _selectCategory(category.id) : null,
                enabled: count > 0,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilteredProductList() {
    final category = _categoryManager.getCategoryById(_selectedCategoryId);
    
    if (category == null) {
      return const Center(
        child: Text('Catégorie non trouvée'),
      );
    }

    if (_filteredPrices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 64,
              color: category.color.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun produit dans ${category.name}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: category.color.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(category.icon, color: category.color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_filteredPrices.length} produit${_filteredPrices.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredPrices.length,
            itemBuilder: (context, index) {
              final price = _filteredPrices[index];
              
              return Semantics(
                label: '${price.productName}, ${price.price.toStringAsFixed(0)} francs CFA, ${price.shop}, ${DateFormat('dd MMMM yyyy', 'fr_FR').format(price.date)}',
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      price.productName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${price.shop} • ${DateFormat('dd/MM/yyyy').format(price.date)}',
                    ),
                    trailing: Text(
                      '${price.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
