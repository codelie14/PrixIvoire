import '../models/product_price.dart';
import 'optimized_storage_service.dart';
import 'enhanced_cache_service.dart';

/// Wrapper service that integrates caching with storage operations
class CachedStorageService {
  final OptimizedStorageService _storageService;
  final EnhancedCacheService _cacheService;

  CachedStorageService({
    required OptimizedStorageService storageService,
    required EnhancedCacheService cacheService,
  })  : _storageService = storageService,
        _cacheService = cacheService;

  /// Initialize both services
  Future<void> initialize() async {
    await _storageService.initialize();
  }

  /// Search products with caching
  Future<List<ProductPrice>> searchProducts(String query) async {
    // Try to get from cache first
    final cached = _cacheService.getCachedSearchResults(query);
    if (cached != null) {
      return cached;
    }

    // If not in cache, fetch from storage
    final results = await _storageService.searchProducts(query);

    // Cache the results
    _cacheService.cacheSearchResults(query, results);

    return results;
  }

  /// Get popular products (most consulted) with caching
  Future<List<ProductPrice>> getPopularProducts({int limit = 50}) async {
    // Try to get from cache first
    final cached = _cacheService.getCachedPopularProducts();
    if (cached != null) {
      return cached.take(limit).toList();
    }

    // If not in cache, fetch from storage
    // For now, we'll get all products and sort by frequency
    // In a real implementation, you'd track access counts
    final allPrices = _storageService.getAllProductPrices();
    
    // Group by product name and count occurrences
    final productCounts = <String, int>{};
    for (final price in allPrices) {
      productCounts[price.productName] = (productCounts[price.productName] ?? 0) + 1;
    }

    // Sort by count and get top products
    final sortedProducts = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get the actual product prices for the top products
    final popularProducts = <ProductPrice>[];
    for (final entry in sortedProducts.take(limit)) {
      final prices = await _storageService.getProductPricesByProduct(entry.key);
      if (prices.isNotEmpty) {
        // Get the most recent price for this product
        prices.sort((a, b) => b.date.compareTo(a.date));
        popularProducts.add(prices.first);
      }
    }

    // Cache the results
    _cacheService.cachePopularProducts(popularProducts);

    return popularProducts;
  }

  /// Add a product price and invalidate relevant caches
  Future<void> addProductPrice(ProductPrice price) async {
    await _storageService.addProductPrice(price);
    
    // Invalidate caches that might be affected
    _cacheService.onDataModified(productName: price.productName);
  }

  /// Delete a product price and invalidate relevant caches
  Future<void> deleteProductPrice(ProductPrice price) async {
    await _storageService.deleteProductPrice(price);
    
    // Invalidate caches that might be affected
    _cacheService.onDataModified(productName: price.productName);
  }

  /// Get prices with pagination (no caching for paginated results)
  Future<List<ProductPrice>> getPricesPaginated(int page, {int pageSize = 50}) async {
    return _storageService.getPricesPaginated(page, pageSize: pageSize);
  }

  /// Get all product names
  List<String> getAllProductNames() {
    return _storageService.getAllProductNames();
  }

  /// Get all shops
  List<String> getAllShops() {
    return _storageService.getAllShops();
  }

  /// Get product prices by product name
  Future<List<ProductPrice>> getProductPricesByProduct(String productName) async {
    return _storageService.getProductPricesByProduct(productName);
  }

  /// Get product prices by shop
  Future<List<ProductPrice>> getProductPricesByShop(String shop) async {
    return _storageService.getProductPricesByShop(shop);
  }

  /// Search by store
  Future<List<ProductPrice>> searchByStore(String storeName) async {
    return _storageService.searchByStore(storeName);
  }

  /// Search by date
  Future<List<ProductPrice>> searchByDate(DateTime date) async {
    return _storageService.searchByDate(date);
  }

  /// Get all product prices
  List<ProductPrice> getAllProductPrices() {
    return _storageService.getAllProductPrices();
  }

  /// Compact database
  Future<bool> compactDatabase({int maxSizeBytes = 50 * 1024 * 1024}) async {
    return _storageService.compactDatabase(maxSizeBytes: maxSizeBytes);
  }

  /// Clean old entries
  Future<int> cleanOldEntries({int maxEntries = 1000}) async {
    final deleted = await _storageService.cleanOldEntries(maxEntries: maxEntries);
    
    // Clear cache after cleaning old entries
    _cacheService.clearAll();
    
    return deleted;
  }

  /// Get total prices count
  int get totalPricesCount => _storageService.totalPricesCount;

  /// Get database size
  Future<int> getDatabaseSize() async {
    return _storageService.getDatabaseSize();
  }

  /// Clear all caches manually
  void clearCache() {
    _cacheService.clearAll();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getCacheStats();
  }

  /// Clean expired cache entries
  void cleanExpiredCache() {
    _cacheService.cleanExpired();
  }

  /// Close the service
  Future<void> close() async {
    await _storageService.close();
  }

  /// Get the underlying storage service (for direct access if needed)
  OptimizedStorageService get storageService => _storageService;

  /// Get the underlying cache service (for direct access if needed)
  EnhancedCacheService get cacheService => _cacheService;
}
