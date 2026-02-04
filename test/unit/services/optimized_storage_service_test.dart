import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:prixivoire/models/product_price.dart';
import 'package:prixivoire/models/price_alert.dart';
import 'package:prixivoire/models/search_history.dart';
import 'package:prixivoire/services/optimized_storage_service.dart';
import 'package:prixivoire/adapters/product_price_adapter.dart';
import 'package:prixivoire/adapters/price_alert_adapter.dart';
import 'package:prixivoire/adapters/search_history_adapter.dart';
import 'package:path/path.dart' as path;

void main() {
  group('OptimizedStorageService', () {
    late OptimizedStorageService service;
    late Directory tempDir;

    setUpAll(() async {
      // Créer un répertoire temporaire pour les tests
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      
      // Initialiser Hive avec le répertoire temporaire
      Hive.init(tempDir.path);
      
      // Enregistrer les adaptateurs
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductPriceAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PriceAlertAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SearchHistoryAdapter());
      }
    });

    setUp(() async {
      service = OptimizedStorageService();
      await service.initialize();
    });

    tearDown(() async {
      await service.close();
      // Nettoyer les boxes de test
      await Hive.deleteBoxFromDisk('productPrices');
      await Hive.deleteBoxFromDisk('priceAlerts');
      await Hive.deleteBoxFromDisk('searchHistory');
    });

    tearDownAll(() async {
      // Supprimer le répertoire temporaire
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initialize should open boxes and create indexes', () async {
      expect(service.totalPricesCount, equals(0));
    });

    test('addProductPrice should add price and update indexes', () async {
      final price = ProductPrice(
        productName: 'Riz 25kg',
        price: 15000,
        shop: 'Carrefour',
        date: DateTime.now(),
      );

      await service.addProductPrice(price);

      expect(service.totalPricesCount, equals(1));
      
      final prices = await service.searchProducts('Riz');
      expect(prices.length, equals(1));
      expect(prices.first.productName, equals('Riz 25kg'));
    });

    test('getPricesPaginated should return correct page', () async {
      // Ajouter 100 prix
      for (int i = 0; i < 100; i++) {
        await service.addProductPrice(ProductPrice(
          productName: 'Produit $i',
          price: 1000.0 + i,
          shop: 'Magasin ${i % 5}',
          date: DateTime.now(),
        ));
      }

      // Récupérer la première page (50 éléments)
      final page1 = await service.getPricesPaginated(0, pageSize: 50);
      expect(page1.length, equals(50));

      // Récupérer la deuxième page (50 éléments)
      final page2 = await service.getPricesPaginated(1, pageSize: 50);
      expect(page2.length, equals(50));

      // Récupérer la troisième page (devrait être vide)
      final page3 = await service.getPricesPaginated(2, pageSize: 50);
      expect(page3.length, equals(0));
    });

    test('searchProducts should use index for fast search', () async {
      // Ajouter plusieurs produits
      await service.addProductPrice(ProductPrice(
        productName: 'Riz blanc',
        price: 15000,
        shop: 'Carrefour',
        date: DateTime.now(),
      ));

      await service.addProductPrice(ProductPrice(
        productName: 'Riz complet',
        price: 18000,
        shop: 'Casino',
        date: DateTime.now(),
      ));

      await service.addProductPrice(ProductPrice(
        productName: 'Huile',
        price: 5000,
        shop: 'Carrefour',
        date: DateTime.now(),
      ));

      final results = await service.searchProducts('riz');
      expect(results.length, equals(2));
      expect(results.every((p) => p.productName.toLowerCase().contains('riz')), isTrue);
    });

    test('searchByStore should return prices from specific store', () async {
      await service.addProductPrice(ProductPrice(
        productName: 'Riz',
        price: 15000,
        shop: 'Carrefour',
        date: DateTime.now(),
      ));

      await service.addProductPrice(ProductPrice(
        productName: 'Huile',
        price: 5000,
        shop: 'Casino',
        date: DateTime.now(),
      ));

      final carrefourPrices = await service.searchByStore('Carrefour');
      expect(carrefourPrices.length, equals(1));
      expect(carrefourPrices.first.shop, equals('Carrefour'));
    });

    test('cleanOldEntries should limit entries to maxEntries', () async {
      // Ajouter 1500 prix
      for (int i = 0; i < 1500; i++) {
        await service.addProductPrice(ProductPrice(
          productName: 'Produit $i',
          price: 1000.0 + i,
          shop: 'Magasin',
          date: DateTime.now().subtract(Duration(days: 1500 - i)),
        ));
      }

      expect(service.totalPricesCount, equals(1500));

      // Nettoyer pour garder seulement 1000 entrées
      final deleted = await service.cleanOldEntries(maxEntries: 1000);

      expect(deleted, equals(500));
      expect(service.totalPricesCount, equals(1000));
    });

    test('getAllProductNames should return unique product names', () async {
      await service.addProductPrice(ProductPrice(
        productName: 'Riz',
        price: 15000,
        shop: 'Carrefour',
        date: DateTime.now(),
      ));

      await service.addProductPrice(ProductPrice(
        productName: 'Riz',
        price: 16000,
        shop: 'Casino',
        date: DateTime.now(),
      ));

      await service.addProductPrice(ProductPrice(
        productName: 'Huile',
        price: 5000,
        shop: 'Carrefour',
        date: DateTime.now(),
      ));

      final names = service.getAllProductNames();
      expect(names.length, equals(2));
      expect(names.contains('Riz'), isTrue);
      expect(names.contains('Huile'), isTrue);
    });

    test('getDatabaseSize should return size in bytes', () async {
      // Ajouter quelques prix
      for (int i = 0; i < 10; i++) {
        await service.addProductPrice(ProductPrice(
          productName: 'Produit $i',
          price: 1000.0 + i,
          shop: 'Magasin',
          date: DateTime.now(),
        ));
      }

      final size = await service.getDatabaseSize();
      expect(size, greaterThan(0));
    });
  });
}
