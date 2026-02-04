import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/web_scraper_service.dart';
import '../services/cache_service.dart';
import '../models/scraped_product.dart';
import '../models/product_price.dart';
import '../models/search_history.dart';
import 'price_comparison_visual_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  final StorageService storageService;
  final CacheService cacheService;

  const ProductSearchScreen({
    super.key,
    required this.storageService,
    required this.cacheService,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _webScraperService = WebScraperService();
  
  List<ScrapedProduct> _allResults = [];
  List<ScrapedProduct> _filteredResults = [];
  List<SearchHistory> _history = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _sortOrder = 'prix_croissant'; // prix_croissant, prix_decroissant, site
  double? _minPrice;
  double? _maxPrice;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _loadHistory() {
    setState(() {
      _history = widget.cacheService.getHistory();
    });
  }

  Future<void> _searchProduct() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un nom de produit';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _allResults = [];
      _filteredResults = [];
      _showHistory = false;
    });

    try {
      // Vérifier le cache d'abord
      final cachedResults = widget.cacheService.getCachedResults(query);
      
      List<ScrapedProduct> results;
      if (cachedResults != null) {
        results = cachedResults;
      } else {
        // Recherche en ligne
        results = await _webScraperService.searchProduct(query);
        // Mettre en cache
        await widget.cacheService.cacheResults(query, results);
      }

      // Ajouter à l'historique
      await widget.cacheService.addToHistory(query);
      _loadHistory();

      setState(() {
        _allResults = results;
        _applyFiltersAndSort();
        _isSearching = false;
        if (results.isEmpty) {
          _errorMessage = 'Aucun résultat trouvé pour "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Erreur lors de la recherche: $e';
      });
    }
  }

  void _applyFiltersAndSort() {
    List<ScrapedProduct> filtered = List.from(_allResults);

    // Filtrer par prix
    if (_minPrice != null || _maxPrice != null) {
      filtered = filtered.where((product) {
        if (product.price == null) return false;
        if (_minPrice != null && product.price! < _minPrice!) return false;
        if (_maxPrice != null && product.price! > _maxPrice!) return false;
        return true;
      }).toList();
    }

    // Trier
    switch (_sortOrder) {
      case 'prix_croissant':
        filtered.sort((a, b) {
          if (a.price == null) return 1;
          if (b.price == null) return -1;
          return a.price!.compareTo(b.price!);
        });
        break;
      case 'prix_decroissant':
        filtered.sort((a, b) {
          if (a.price == null) return 1;
          if (b.price == null) return -1;
          return b.price!.compareTo(a.price!);
        });
        break;
      case 'site':
        filtered.sort((a, b) => a.shop.compareTo(b.shop));
        break;
    }

    setState(() {
      _filteredResults = filtered;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres et tri'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _minPriceController,
                decoration: const InputDecoration(
                  labelText: 'Prix minimum (FCFA)',
                  hintText: 'Ex: 10000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _maxPriceController,
                decoration: const InputDecoration(
                  labelText: 'Prix maximum (FCFA)',
                  hintText: 'Ex: 50000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text('Trier par:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'prix_croissant',
                    label: Text('Prix ↑'),
                  ),
                  ButtonSegment<String>(
                    value: 'prix_decroissant',
                    label: Text('Prix ↓'),
                  ),
                  ButtonSegment<String>(
                    value: 'site',
                    label: Text('Site'),
                  ),
                ],
                selected: {_sortOrder},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _sortOrder = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _minPriceController.clear();
              _maxPriceController.clear();
              setState(() {
                _minPrice = null;
                _maxPrice = null;
                _sortOrder = 'prix_croissant';
              });
              _applyFiltersAndSort();
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _minPrice = _minPriceController.text.isNotEmpty
                    ? double.tryParse(_minPriceController.text)
                    : null;
                _maxPrice = _maxPriceController.text.isNotEmpty
                    ? double.tryParse(_maxPriceController.text)
                    : null;
              });
              _applyFiltersAndSort();
              Navigator.pop(context);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct(ScrapedProduct scrapedProduct) async {
    if (scrapedProduct.price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de sauvegarder : prix non disponible'),
        ),
      );
      return;
    }

    final productPrice = ProductPrice(
      productName: scrapedProduct.name,
      price: scrapedProduct.price!,
      shop: scrapedProduct.shop,
      date: DateTime.now(),
    );

    await widget.storageService.addProductPrice(productPrice);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prix sauvegardé : ${scrapedProduct.name}'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _selectFromHistory(String query) {
    _searchController.text = query;
    _searchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche en ligne'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_filteredResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              tooltip: 'Comparer les prix',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PriceComparisonVisualScreen(
                      products: _filteredResults,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtres et tri',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher un produit (ex: iPhone X)',
                          hintText: 'Entrez le nom du produit',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _allResults = [];
                                      _filteredResults = [];
                                      _errorMessage = null;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.history),
                                  tooltip: 'Historique',
                                  onPressed: () {
                                    setState(() {
                                      _showHistory = !_showHistory;
                                    });
                                  },
                                ),
                        ),
                        onSubmitted: (_) => _searchProduct(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isSearching ? null : _searchProduct,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Rechercher'),
                    ),
                  ],
                ),
                // Historique
                if (_showHistory && _history.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final historyItem = _history[index];
                        return ListTile(
                          leading: const Icon(Icons.history, size: 20),
                          title: Text(historyItem.query),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(historyItem.searchedAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => _selectFromHistory(historyItem.query),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              await historyItem.delete();
                              _loadHistory();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
                // Indicateurs de filtres actifs
                if ((_minPrice != null || _maxPrice != null) && _filteredResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Chip(
                          label: Text(
                            '${_filteredResults.length} résultat${_filteredResults.length > 1 ? 's' : ''}',
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        if (_minPrice != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Chip(
                              label: Text('Min: ${NumberFormat('#,##0').format(_minPrice)} FCFA'),
                              onDeleted: () {
                                setState(() {
                                  _minPrice = null;
                                  _minPriceController.clear();
                                });
                                _applyFiltersAndSort();
                              },
                            ),
                          ),
                        if (_maxPrice != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Chip(
                              label: Text('Max: ${NumberFormat('#,##0').format(_maxPrice)} FCFA'),
                              onDeleted: () {
                                setState(() {
                                  _maxPrice = null;
                                  _maxPriceController.clear();
                                });
                                _applyFiltersAndSort();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Message d'erreur
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Résultats de recherche
          Expanded(
            child: _isSearching
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Recherche en cours...'),
                      ],
                    ),
                  )
                : _filteredResults.isEmpty && _allResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune recherche effectuée',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Entrez un nom de produit et cliquez sur Rechercher',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _filteredResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.filter_alt_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucun résultat ne correspond aux filtres',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _filteredResults.length,
                            itemBuilder: (context, index) {
                              final product = _filteredResults[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: product.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            product.imageUrl!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.image),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.shopping_bag),
                                        ),
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.store,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            product.shop,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (product.price != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '${NumberFormat('#,##0').format(product.price)} FCFA',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ] else
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Prix non disponible',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: product.price != null
                                      ? IconButton(
                                          icon: const Icon(Icons.save),
                                          tooltip: 'Sauvegarder le prix',
                                          onPressed: () => _saveProduct(product),
                                        )
                                      : null,
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
