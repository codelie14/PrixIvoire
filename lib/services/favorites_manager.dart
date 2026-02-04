import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_price.dart';
import '../services/storage_service.dart';

/// Service de gestion des produits favoris
/// 
/// Ce service permet de marquer des produits comme favoris et de gérer
/// la liste des favoris avec persistance dans Hive.
class FavoritesManager {
  static const String _favoritesBoxName = 'favorites';
  
  Box<List<dynamic>>? _favoritesBox;
  final StorageService _storageService;
  Set<String> _favoriteProductNames = {};
  
  FavoritesManager(this._storageService);
  
  /// Initialise le service et charge les favoris depuis Hive
  Future<void> initialize() async {
    _favoritesBox = await Hive.openBox<List<dynamic>>(_favoritesBoxName);
    await loadFavorites();
  }
  
  /// Charge les favoris depuis Hive
  Future<void> loadFavorites() async {
    if (_favoritesBox == null) {
      throw StateError('FavoritesManager not initialized. Call initialize() first.');
    }
    
    final storedFavorites = _favoritesBox!.get('favorite_products');
    if (storedFavorites != null) {
      _favoriteProductNames = Set<String>.from(storedFavorites.cast<String>());
    } else {
      _favoriteProductNames = {};
    }
  }
  
  /// Sauvegarde les favoris dans Hive
  Future<void> saveFavorites() async {
    if (_favoritesBox == null) {
      throw StateError('FavoritesManager not initialized. Call initialize() first.');
    }
    
    await _favoritesBox!.put('favorite_products', _favoriteProductNames.toList());
  }
  
  /// Ajoute un produit aux favoris
  /// 
  /// [productName] Le nom du produit à ajouter aux favoris
  /// Retourne true si le produit a été ajouté, false s'il était déjà favori
  Future<bool> addFavorite(String productName) async {
    if (_favoriteProductNames.contains(productName)) {
      return false;
    }
    
    _favoriteProductNames.add(productName);
    await saveFavorites();
    
    // Mettre à jour le flag isFavorite sur tous les prix de ce produit
    await _updateProductFavoriteStatus(productName, true);
    
    return true;
  }
  
  /// Retire un produit des favoris
  /// 
  /// [productName] Le nom du produit à retirer des favoris
  /// Retourne true si le produit a été retiré, false s'il n'était pas favori
  Future<bool> removeFavorite(String productName) async {
    if (!_favoriteProductNames.contains(productName)) {
      return false;
    }
    
    _favoriteProductNames.remove(productName);
    await saveFavorites();
    
    // Mettre à jour le flag isFavorite sur tous les prix de ce produit
    await _updateProductFavoriteStatus(productName, false);
    
    return true;
  }
  
  /// Vérifie si un produit est dans les favoris
  /// 
  /// [productName] Le nom du produit à vérifier
  /// Retourne true si le produit est favori, false sinon
  bool isFavorite(String productName) {
    return _favoriteProductNames.contains(productName);
  }
  
  /// Récupère la liste des produits favoris avec leur dernier prix connu
  /// 
  /// Retourne une liste de ProductPrice contenant le prix le plus récent
  /// pour chaque produit favori
  List<ProductPrice> getFavoriteProducts() {
    final List<ProductPrice> favoriteProducts = [];
    
    for (final productName in _favoriteProductNames) {
      // Récupérer tous les prix pour ce produit
      final prices = _storageService.getProductPricesByProduct(productName);
      
      if (prices.isNotEmpty) {
        // Trier par date décroissante et prendre le plus récent
        prices.sort((a, b) => b.date.compareTo(a.date));
        favoriteProducts.add(prices.first);
      }
    }
    
    // Trier les favoris par nom de produit
    favoriteProducts.sort((a, b) => a.productName.compareTo(b.productName));
    
    return favoriteProducts;
  }
  
  /// Récupère le nombre de produits favoris
  int get favoriteCount => _favoriteProductNames.length;
  
  /// Récupère la liste des noms de produits favoris
  List<String> get favoriteProductNames => _favoriteProductNames.toList()..sort();
  
  /// Met à jour le statut favori de tous les prix d'un produit
  /// 
  /// Cette méthode est privée et utilisée en interne pour synchroniser
  /// le flag isFavorite sur les objets ProductPrice
  Future<void> _updateProductFavoriteStatus(String productName, bool isFavorite) async {
    final prices = _storageService.getProductPricesByProduct(productName);
    
    for (final price in prices) {
      // Créer une copie avec le nouveau statut favori
      final updatedPrice = price.copyWith(isFavorite: isFavorite);
      
      // Sauvegarder la mise à jour
      // Note: Hive met à jour automatiquement l'objet si on modifie ses propriétés
      // mais comme ProductPrice utilise des champs final, on doit supprimer et recréer
      await _storageService.deleteProductPrice(price);
      await _storageService.addProductPrice(updatedPrice);
    }
  }
  
  /// Nettoie les favoris orphelins (produits qui n'existent plus dans la base)
  Future<void> cleanOrphanedFavorites() async {
    final allProductNames = _storageService.getAllProductNames().toSet();
    final orphanedFavorites = _favoriteProductNames.difference(allProductNames);
    
    if (orphanedFavorites.isNotEmpty) {
      _favoriteProductNames.removeAll(orphanedFavorites);
      await saveFavorites();
    }
  }
  
  /// Ferme le service et libère les ressources
  Future<void> dispose() async {
    await _favoritesBox?.close();
  }
}
