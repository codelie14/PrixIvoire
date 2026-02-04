import 'package:flutter_test/flutter_test.dart';
import 'package:prixivoire/services/enhanced_cache_service.dart';
import 'package:prixivoire/services/cache_manager.dart';
import 'package:prixivoire/models/product_price.dart';

void main() {
  group('EnhancedCacheService', () {
    late EnhancedCacheService cacheService;

    setUp(() {
      final cacheManager = CacheManager(maxSizeBytes: 10 * 1024 * 1024);
      cacheService = EnhancedCacheService(cacheManager: cacheManager);
    });

    test('should cache and retrieve search results', () {
      final products = [
        ProductPrice(
          productName: 'Test Product',
          price: 1000,
          shop: 'Test Shop',
          date: DateTime.now(),
        ),
      ];

      cacheService.cacheSearchResults('test query', products);
      final cached = cacheService.getCachedSearchResults('test query');

      expect(cached, isNotNull);
      expect(cached!.length, equals(1));
      expect(cached.first.productName, equals('Test Product'));
    });

    test('should cache and retrieve popular products', () {
      final products = [
        ProductPrice(
          productName: 'Popular Product',
          price: 2000,
          shop: 'Test Shop',
          date: DateTime.now(),
        ),
      ];

      cacheService.cachePopularProducts(products);
      final cached = cacheService.getCachedPopularProducts();

      expect(cached, isNotNull);
      expect(cached!.length, equals(1));
      expect(cached.first.productName, equals('Popular Product'));
    });

    test('should cache and retrieve statistics', () {
      final stats = {
        'mean': 1500.0,
        'median': 1400.0,
        'min': 1000.0,
        'max': 2000.0,
      };

      cacheService.cacheStatistics('Test Product', stats);
      final cached = cacheService.getCachedStatistics('Test Product');

      expect(cached, isNotNull);
      expect(cached!['mean'], equals(1500.0));
      expect(cached['median'], equals(1400.0));
    });

    test('should invalidate search caches', () {
      final products = [
        ProductPrice(
          productName: 'Test Product',
          price: 1000,
          shop: 'Test Shop',
          date: DateTime.now(),
        ),
      ];

      cacheService.cacheSearchResults('query1', products);
      cacheService.cacheSearchResults('query2', products);

      cacheService.invalidateSearchCaches();

      expect(cacheService.getCachedSearchResults('query1'), isNull);
      expect(cacheService.getCachedSearchResults('query2'), isNull);
    });

    test('should invalidate product statistics', () {
      final stats = {'mean': 1500.0};

      cacheService.cacheStatistics('Product1', stats);
      cacheService.cacheStatistics('Product2', stats);

      cacheService.invalidateProductStatistics('Product1');

      expect(cacheService.getCachedStatistics('Product1'), isNull);
      expect(cacheService.getCachedStatistics('Product2'), isNotNull);
    });

    test('should invalidate all statistics', () {
      final stats = {'mean': 1500.0};

      cacheService.cacheStatistics('Product1', stats);
      cacheService.cacheStatistics('Product2', stats);

      cacheService.invalidateAllStatistics();

      expect(cacheService.getCachedStatistics('Product1'), isNull);
      expect(cacheService.getCachedStatistics('Product2'), isNull);
    });

    test('should invalidate popular products', () {
      final products = [
        ProductPrice(
          productName: 'Popular Product',
          price: 2000,
          shop: 'Test Shop',
          date: DateTime.now(),
        ),
      ];

      cacheService.cachePopularProducts(products);
      cacheService.invalidatePopularProducts();

      expect(cacheService.getCachedPopularProducts(), isNull);
    });

    test('should invalidate all related caches on data modification', () {
      final products = [
        ProductPrice(
          productName: 'Test Product',
          price: 1000,
          shop: 'Test Shop',
          date: DateTime.now(),
        ),
      ];
      final stats = {'mean': 1500.0};

      cacheService.cacheSearchResults('query', products);
      cacheService.cachePopularProducts(products);
      cacheService.cacheStatistics('Test Product', stats);

      cacheService.onDataModified(productName: 'Test Product');

      expect(cacheService.getCachedSearchResults('query'), isNull);
      expect(cacheService.getCachedPopularProducts(), isNull);
      expect(cacheService.getCachedStatistics('Test Product'), isNull);
    });

    test('should clear all caches', () {
      final products = [
        ProductPrice(
          productName: 'Test Product',
          price: 1000,
          shop: 'Test Shop',
          date: DateTime.now(),
        ),
      ];
      final stats = {'mean': 1500.0};

      cacheService.cacheSearchResults('query', products);
      cacheService.cachePopularProducts(products);
      cacheService.cacheStatistics('Test Product', stats);

      cacheService.clearAll();

      expect(cacheService.getCachedSearchResults('query'), isNull);
      expect(cacheService.getCachedPopularProducts(), isNull);
      expect(cacheService.getCachedStatistics('Test Product'), isNull);
    });

    test('should provide cache statistics', () {
      final stats = cacheService.getCacheStats();

      expect(stats, isNotNull);
      expect(stats.containsKey('currentSizeBytes'), isTrue);
      expect(stats.containsKey('maxSizeBytes'), isTrue);
      expect(stats.containsKey('entryCount'), isTrue);
      expect(stats.containsKey('usagePercentage'), isTrue);
    });

    test('should handle case-insensitive queries', () {
      final products = [
        ProductPrice(
          productName: 'Test Product',
          price: 1000,
          shop: 'Test Shop',
          date: DateTime.now(),
        ),
      ];

      cacheService.cacheSearchResults('Test Query', products);
      
      // Should retrieve with different case
      final cached1 = cacheService.getCachedSearchResults('test query');
      final cached2 = cacheService.getCachedSearchResults('TEST QUERY');

      expect(cached1, isNotNull);
      expect(cached2, isNotNull);
    });
  });
}
