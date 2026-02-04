import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:prixivoire/services/favorites_manager.dart';
import 'package:prixivoire/services/storage_service.dart';
import 'package:prixivoire/models/product_price.dart';
import 'package:prixivoire/adapters/product_price_adapter.dart';
import 'package:prixivoire/adapters/price_alert_adapter.dart';
import 'dart:io';

void main() {
  late FavoritesManager favoritesManager;
  late StorageService storageService;
  late Directory testDirectory;

  setUpAll(() async {
    // Créer un répertoire temporaire pour les tests
    testDirectory = Directory.systemTemp.createTempSync('hive_test_');
    
    // Initialiser Hive avec le répertoire de test
    Hive.init(testDirectory.path);
    
    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductPriceAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PriceAlertAdapter());
    }
  });

  setUp(() async {
    // Nettoyer les boxes avant chaque test
    try {
      await Hive.deleteBoxFromDisk('productPrices');
      await Hive.deleteBoxFromDisk('priceAlerts');
      await Hive.deleteBoxFromDisk('favorites');
    } catch (e) {
      // Ignorer les erreurs si les boxes n'existent pas
    }
    
    // Initialiser les services
    storageService = StorageService();
    await storageService.init();
    
    favoritesManager = FavoritesManager(storageService);
    await favoritesManager.initialize();
  });

  tearDown(() async {
    // Nettoyer après chaque test
    try {
      await favoritesManager.dispose();
      await Hive.deleteBoxFromDisk('productPrices');
      await Hive.deleteBoxFromDisk('priceAlerts');
      await Hive.deleteBoxFromDisk('favorites');
    } catch (e) {
      // Ignorer les erreurs de nettoyage
    }
  });
  
  tearDownAll(() async {
    // Nettoyer le répertoire de test
    try {
      await Hive.close();
      if (testDirectory.existsSync()) {
        testDirectory.deleteSync(recursive: true);
      }
    } catch (e) {
      // Ignorer les erreurs de nettoyage final
    }
  });

  group('FavoritesManager - Basic Operations', () {
    test('should initialize with empty favorites', () {
      expect(favoritesManager.favoriteCount, 0);
      expect(favoritesManager.favoriteProductNames, isEmpty);
    });

    test('should add a product to favorites', () async {
      final added = await favoritesManager.addFavorite('Riz 25kg');
      
      expect(added, true);
      expect(favoritesManager.isFavorite('Riz 25kg'), true);
      expect(favoritesManager.favoriteCount, 1);
    });

    test('should not add duplicate favorites', () async {
      await favoritesManager.addFavorite('Riz 25kg');
      final addedAgain = await favoritesManager.addFavorite('Riz 25kg');
      
      expect(addedAgain, false);
      expect(favoritesManager.favoriteCount, 1);
    });

    test('should remove a product from favorites', () async {
      await favoritesManager.addFavorite('Riz 25kg');
      final removed = await favoritesManager.removeFavorite('Riz 25kg');
      
      expect(removed, true);
      expect(favoritesManager.isFavorite('Riz 25kg'), false);
      expect(favoritesManager.favoriteCount, 0);
    });

    test('should return false when removing non-favorite', () async {
      final removed = await favoritesManager.removeFavorite('Riz 25kg');
      
      expect(removed, false);
    });

    test('should check if product is favorite', () async {
      expect(favoritesManager.isFavorite('Riz 25kg'), false);
      
      await favoritesManager.addFavorite('Riz 25kg');
      expect(favoritesManager.isFavorite('Riz 25kg'), true);
    });
  });

  group('FavoritesManager - Persistence', () {
    test('should persist favorites across sessions', () async {
      // Ajouter des favoris
      await favoritesManager.addFavorite('Riz 25kg');
      await favoritesManager.addFavorite('Huile 1L');
      
      // Créer une nouvelle instance
      final newFavoritesManager = FavoritesManager(storageService);
      await newFavoritesManager.initialize();
      
      // Vérifier que les favoris sont chargés
      expect(newFavoritesManager.favoriteCount, 2);
      expect(newFavoritesManager.isFavorite('Riz 25kg'), true);
      expect(newFavoritesManager.isFavorite('Huile 1L'), true);
      
      await newFavoritesManager.dispose();
    });
  });

  group('FavoritesManager - Get Favorite Products', () {
    test('should return empty list when no favorites', () {
      final favorites = favoritesManager.getFavoriteProducts();
      expect(favorites, isEmpty);
    });

    test('should return favorite products with latest price', () async {
      // Ajouter des prix pour un produit
      final price1 = ProductPrice(
        productName: 'Riz 25kg',
        price: 15000,
        shop: 'Carrefour',
        date: DateTime(2024, 1, 1),
      );
      final price2 = ProductPrice(
        productName: 'Riz 25kg',
        price: 14500,
        shop: 'Sococé',
        date: DateTime(2024, 1, 15),
      );
      
      await storageService.addProductPrice(price1);
      await storageService.addProductPrice(price2);
      
      // Ajouter aux favoris
      await favoritesManager.addFavorite('Riz 25kg');
      
      // Récupérer les favoris
      final favorites = favoritesManager.getFavoriteProducts();
      
      expect(favorites.length, 1);
      expect(favorites[0].productName, 'Riz 25kg');
      expect(favorites[0].price, 14500); // Le plus récent
      expect(favorites[0].shop, 'Sococé');
    });

    test('should return multiple favorite products sorted by name', () async {
      // Ajouter des prix
      await storageService.addProductPrice(ProductPrice(
        productName: 'Riz 25kg',
        price: 15000,
        shop: 'Carrefour',
        date: DateTime.now(),
      ));
      await storageService.addProductPrice(ProductPrice(
        productName: 'Huile 1L',
        price: 2000,
        shop: 'Sococé',
        date: DateTime.now(),
      ));
      
      // Ajouter aux favoris dans un ordre différent
      await favoritesManager.addFavorite('Riz 25kg');
      await favoritesManager.addFavorite('Huile 1L');
      
      final favorites = favoritesManager.getFavoriteProducts();
      
      expect(favorites.length, 2);
      expect(favorites[0].productName, 'Huile 1L'); // Trié alphabétiquement
      expect(favorites[1].productName, 'Riz 25kg');
    });
  });

  group('FavoritesManager - Clean Orphaned Favorites', () {
    test('should remove favorites for deleted products', () async {
      // Ajouter un produit et le marquer comme favori
      final price = ProductPrice(
        productName: 'Riz 25kg',
        price: 15000,
        shop: 'Carrefour',
        date: DateTime.now(),
      );
      await storageService.addProductPrice(price);
      await favoritesManager.addFavorite('Riz 25kg');
      
      expect(favoritesManager.favoriteCount, 1);
      
      // Récupérer le produit depuis le storage pour avoir l'objet avec la clé Hive
      final prices = storageService.getProductPricesByProduct('Riz 25kg');
      expect(prices.isNotEmpty, true);
      
      // Supprimer le produit
      await storageService.deleteProductPrice(prices.first);
      
      // Nettoyer les favoris orphelins
      await favoritesManager.cleanOrphanedFavorites();
      
      expect(favoritesManager.favoriteCount, 0);
    });
  });
}
