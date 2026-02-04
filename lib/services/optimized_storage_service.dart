import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_price.dart';
import '../models/price_alert.dart';
import '../models/search_history.dart';

/// Service de stockage optimisé avec indexation, pagination et gestion de la performance
class OptimizedStorageService {
  static const String _productPriceBoxName = 'productPrices';
  static const String _priceAlertBoxName = 'priceAlerts';
  static const String _searchHistoryBoxName = 'searchHistory';

  late Box<ProductPrice> _productPriceBox;
  late Box<PriceAlert> _priceAlertBox;
  late Box<SearchHistory> _searchHistoryBox;

  // Index pour optimiser les recherches
  final Map<String, List<int>> _productNameIndex = {};
  final Map<String, List<int>> _storeNameIndex = {};
  final Map<String, List<int>> _dateIndex = {};

  bool _isInitialized = false;

  /// Initialise le service et ouvre les boxes Hive
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Ouvrir les boxes
      _productPriceBox = await Hive.openBox<ProductPrice>(_productPriceBoxName);
      _priceAlertBox = await Hive.openBox<PriceAlert>(_priceAlertBoxName);
      _searchHistoryBox = await Hive.openBox<SearchHistory>(_searchHistoryBoxName);

      // Créer les index
      await createIndexes();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Erreur lors de l\'initialisation du stockage: $e');
    }
  }

  /// Crée des index sur les champs fréquemment recherchés
  Future<void> createIndexes() async {
    _productNameIndex.clear();
    _storeNameIndex.clear();
    _dateIndex.clear();

    // Parcourir tous les prix et construire les index
    for (var i = 0; i < _productPriceBox.length; i++) {
      final price = _productPriceBox.getAt(i);
      if (price != null) {
        // Index par nom de produit
        final productKey = price.productName.toLowerCase();
        _productNameIndex.putIfAbsent(productKey, () => []).add(i);

        // Index par nom de magasin
        final storeKey = price.shop.toLowerCase();
        _storeNameIndex.putIfAbsent(storeKey, () => []).add(i);

        // Index par date (format YYYY-MM-DD)
        final dateKey = _formatDateKey(price.date);
        _dateIndex.putIfAbsent(dateKey, () => []).add(i);
      }
    }
  }

  /// Formate une date en clé pour l'index
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Récupère les prix avec pagination
  /// 
  /// [page] : Numéro de page (commence à 0)
  /// [pageSize] : Nombre d'éléments par page (par défaut 50)
  Future<List<ProductPrice>> getPricesPaginated(int page, {int pageSize = 50}) async {
    _ensureInitialized();

    final skip = page * pageSize;
    final take = pageSize;

    if (skip >= _productPriceBox.length) {
      return [];
    }

    final endIndex = (skip + take).clamp(0, _productPriceBox.length);
    final result = <ProductPrice>[];

    for (var i = skip; i < endIndex; i++) {
      final price = _productPriceBox.getAt(i);
      if (price != null) {
        result.add(price);
      }
    }

    return result;
  }

  /// Recherche optimisée de produits par nom
  /// 
  /// Utilise l'index pour une recherche rapide
  Future<List<ProductPrice>> searchProducts(String query) async {
    _ensureInitialized();

    if (query.isEmpty) {
      return [];
    }

    final queryLower = query.toLowerCase();
    final results = <ProductPrice>[];
    final seenIndices = <int>{};

    // Rechercher dans l'index des noms de produits
    for (final entry in _productNameIndex.entries) {
      if (entry.key.contains(queryLower)) {
        for (final index in entry.value) {
          if (!seenIndices.contains(index)) {
            final price = _productPriceBox.getAt(index);
            if (price != null) {
              results.add(price);
              seenIndices.add(index);
            }
          }
        }
      }
    }

    return results;
  }

  /// Recherche optimisée par magasin
  Future<List<ProductPrice>> searchByStore(String storeName) async {
    _ensureInitialized();

    if (storeName.isEmpty) {
      return [];
    }

    final storeKey = storeName.toLowerCase();
    final indices = _storeNameIndex[storeKey] ?? [];
    final results = <ProductPrice>[];

    for (final index in indices) {
      final price = _productPriceBox.getAt(index);
      if (price != null) {
        results.add(price);
      }
    }

    return results;
  }

  /// Recherche optimisée par date
  Future<List<ProductPrice>> searchByDate(DateTime date) async {
    _ensureInitialized();

    final dateKey = _formatDateKey(date);
    final indices = _dateIndex[dateKey] ?? [];
    final results = <ProductPrice>[];

    for (final index in indices) {
      final price = _productPriceBox.getAt(index);
      if (price != null) {
        results.add(price);
      }
    }

    return results;
  }

  /// Ajoute un prix et met à jour les index
  Future<void> addProductPrice(ProductPrice price) async {
    _ensureInitialized();

    final index = _productPriceBox.length;
    await _productPriceBox.add(price);

    // Mettre à jour les index
    final productKey = price.productName.toLowerCase();
    _productNameIndex.putIfAbsent(productKey, () => []).add(index);

    final storeKey = price.shop.toLowerCase();
    _storeNameIndex.putIfAbsent(storeKey, () => []).add(index);

    final dateKey = _formatDateKey(price.date);
    _dateIndex.putIfAbsent(dateKey, () => []).add(index);
  }

  /// Supprime un prix et met à jour les index
  Future<void> deleteProductPrice(ProductPrice price) async {
    _ensureInitialized();

    await price.delete();
    
    // Reconstruire les index après suppression
    await createIndexes();
  }

  /// Récupère tous les prix (non paginé - à utiliser avec précaution)
  List<ProductPrice> getAllProductPrices() {
    _ensureInitialized();
    return _productPriceBox.values.toList();
  }

  /// Récupère les prix d'un produit spécifique
  Future<List<ProductPrice>> getProductPricesByProduct(String productName) async {
    _ensureInitialized();

    final productKey = productName.toLowerCase();
    final indices = _productNameIndex[productKey] ?? [];
    final results = <ProductPrice>[];

    for (final index in indices) {
      final price = _productPriceBox.getAt(index);
      if (price != null && price.productName == productName) {
        results.add(price);
      }
    }

    return results;
  }

  /// Récupère les prix d'un magasin spécifique
  Future<List<ProductPrice>> getProductPricesByShop(String shop) async {
    return searchByStore(shop);
  }

  /// Récupère tous les noms de produits uniques
  List<String> getAllProductNames() {
    _ensureInitialized();
    return _productNameIndex.keys.map((key) {
      // Récupérer le nom original (avec la casse correcte)
      final index = _productNameIndex[key]!.first;
      final price = _productPriceBox.getAt(index);
      return price?.productName ?? key;
    }).toSet().toList()..sort();
  }

  /// Récupère tous les noms de magasins uniques
  List<String> getAllShops() {
    _ensureInitialized();
    return _storeNameIndex.keys.map((key) {
      // Récupérer le nom original (avec la casse correcte)
      final index = _storeNameIndex[key]!.first;
      final price = _productPriceBox.getAt(index);
      return price?.shop ?? key;
    }).toSet().toList()..sort();
  }

  /// Compacte la base de données si la taille dépasse le seuil
  /// 
  /// [maxSizeBytes] : Taille maximale en octets (par défaut 50MB)
  /// Retourne true si la compaction a été effectuée
  Future<bool> compactDatabase({int maxSizeBytes = 50 * 1024 * 1024}) async {
    _ensureInitialized();

    // Vérifier la taille de la base de données
    final boxPath = _productPriceBox.path;
    if (boxPath == null) return false;

    final file = File(boxPath);
    if (!await file.exists()) return false;

    final fileSize = await file.length();

    if (fileSize > maxSizeBytes) {
      try {
        // Compacter la box principale
        await _productPriceBox.compact();
        
        // Compacter les autres boxes aussi
        await _priceAlertBox.compact();
        await _searchHistoryBox.compact();

        // Reconstruire les index après compaction
        await createIndexes();

        return true;
      } catch (e) {
        debugPrint('Erreur lors de la compaction: $e');
        return false;
      }
    }

    return false;
  }

  /// Nettoie les anciennes entrées pour limiter la taille
  /// 
  /// [maxEntries] : Nombre maximum d'entrées à conserver (par défaut 1000)
  /// Retourne le nombre total d'entrées supprimées
  Future<int> cleanOldEntries({int maxEntries = 1000}) async {
    _ensureInitialized();

    int totalDeleted = 0;

    // Nettoyer les prix
    if (_productPriceBox.length > maxEntries) {
      final prices = _productPriceBox.values.toList();
      // Trier par date (les plus anciens en premier)
      prices.sort((a, b) => a.date.compareTo(b.date));

      final toDelete = prices.take(_productPriceBox.length - maxEntries).toList();
      for (final price in toDelete) {
        await price.delete();
        totalDeleted++;
      }

      // Reconstruire les index
      await createIndexes();
    }

    // Nettoyer les alertes
    if (_priceAlertBox.length > maxEntries) {
      final alerts = _priceAlertBox.values.toList();
      final toDelete = alerts.take(_priceAlertBox.length - maxEntries).toList();
      for (final alert in toDelete) {
        await alert.delete();
        totalDeleted++;
      }
    }

    // Nettoyer l'historique de recherche
    if (_searchHistoryBox.length > maxEntries) {
      final history = _searchHistoryBox.values.toList();
      // Trier par date (les plus anciens en premier)
      history.sort((a, b) => a.searchedAt.compareTo(b.searchedAt));

      final toDelete = history.take(_searchHistoryBox.length - maxEntries).toList();
      for (final item in toDelete) {
        await item.delete();
        totalDeleted++;
      }
    }

    return totalDeleted;
  }

  /// Méthodes pour les alertes de prix
  Future<void> addPriceAlert(PriceAlert alert) async {
    _ensureInitialized();
    await _priceAlertBox.add(alert);
  }

  Future<void> deletePriceAlert(PriceAlert alert) async {
    _ensureInitialized();
    await alert.delete();
  }

  List<PriceAlert> getAllPriceAlerts() {
    _ensureInitialized();
    return _priceAlertBox.values.toList();
  }

  /// Méthodes pour l'historique de recherche
  Future<void> addSearchHistory(SearchHistory history) async {
    _ensureInitialized();
    await _searchHistoryBox.add(history);
  }

  List<SearchHistory> getAllSearchHistory() {
    _ensureInitialized();
    return _searchHistoryBox.values.toList();
  }

  /// Récupère le nombre total d'entrées
  int get totalPricesCount {
    _ensureInitialized();
    return _productPriceBox.length;
  }

  /// Récupère la taille de la base de données en octets
  Future<int> getDatabaseSize() async {
    _ensureInitialized();

    int totalSize = 0;

    // Taille de la box des prix
    final priceBoxPath = _productPriceBox.path;
    if (priceBoxPath != null) {
      final file = File(priceBoxPath);
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }

    // Taille de la box des alertes
    final alertBoxPath = _priceAlertBox.path;
    if (alertBoxPath != null) {
      final file = File(alertBoxPath);
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }

    // Taille de la box de l'historique
    final historyBoxPath = _searchHistoryBox.path;
    if (historyBoxPath != null) {
      final file = File(historyBoxPath);
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }

    return totalSize;
  }

  /// Vérifie que le service est initialisé
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('OptimizedStorageService n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
  }

  /// Ferme toutes les boxes
  Future<void> close() async {
    if (_isInitialized) {
      await _productPriceBox.close();
      await _priceAlertBox.close();
      await _searchHistoryBox.close();
      _isInitialized = false;
    }
  }
}
