import 'cache_manager.dart';
import '../models/product_price.dart';

/// Enhanced cache service with automatic invalidation on data modifications
class EnhancedCacheService {
  final CacheManager _cacheManager;
  
  // TTL configurations
  static const Duration _searchResultsTTL = Duration(minutes: 5);
  static const Duration _popularProductsTTL = Duration(minutes: 5);
  static const Duration _statisticsTTL = Duration(minutes: 10);

  EnhancedCacheService({CacheManager? cacheManager})
      : _cacheManager = cacheManager ?? CacheManager();

  /// Cache search results
  void cacheSearchResults(String query, List<ProductPrice> results) {
    final key = 'search:${query.toLowerCase().trim()}';
    _cacheManager.set(key, results, _searchResultsTTL);
  }

  /// Get cached search results
  List<ProductPrice>? getCachedSearchResults(String query) {
    final key = 'search:${query.toLowerCase().trim()}';
    return _cacheManager.get<List<ProductPrice>>(key);
  }

  /// Cache popular products
  void cachePopularProducts(List<ProductPrice> products) {
    _cacheManager.set('popular_products', products, _popularProductsTTL);
  }

  /// Get cached popular products
  List<ProductPrice>? getCachedPopularProducts() {
    return _cacheManager.get<List<ProductPrice>>('popular_products');
  }

  /// Cache statistics for a product
  void cacheStatistics(String productName, Map<String, dynamic> statistics) {
    final key = 'stats:${productName.toLowerCase().trim()}';
    _cacheManager.set(key, statistics, _statisticsTTL);
  }

  /// Get cached statistics for a product
  Map<String, dynamic>? getCachedStatistics(String productName) {
    final key = 'stats:${productName.toLowerCase().trim()}';
    return _cacheManager.get<Map<String, dynamic>>(key);
  }

  /// Invalidate all search-related caches
  void invalidateSearchCaches() {
    _cacheManager.invalidatePattern(r'^search:');
  }

  /// Invalidate statistics for a specific product
  void invalidateProductStatistics(String productName) {
    final key = 'stats:${productName.toLowerCase().trim()}';
    _cacheManager.invalidate(key);
  }

  /// Invalidate all statistics caches
  void invalidateAllStatistics() {
    _cacheManager.invalidatePattern(r'^stats:');
  }

  /// Invalidate popular products cache
  void invalidatePopularProducts() {
    _cacheManager.invalidate('popular_products');
  }

  /// Invalidate all caches when data is modified
  void onDataModified({String? productName}) {
    // Invalidate search results as they may now be outdated
    invalidateSearchCaches();
    
    // Invalidate popular products
    invalidatePopularProducts();
    
    // If a specific product was modified, invalidate its statistics
    if (productName != null) {
      invalidateProductStatistics(productName);
    } else {
      // If we don't know which product, invalidate all statistics
      invalidateAllStatistics();
    }
  }

  /// Clear all cache entries
  void clearAll() {
    _cacheManager.clear();
  }

  /// Clean expired entries
  void cleanExpired() {
    _cacheManager.cleanExpired();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'currentSizeBytes': _cacheManager.currentSizeBytes,
      'maxSizeBytes': _cacheManager.maxSizeBytes,
      'entryCount': _cacheManager.entryCount,
      'usagePercentage': (_cacheManager.currentSizeBytes / _cacheManager.maxSizeBytes * 100).toStringAsFixed(2),
    };
  }

  /// Get the underlying cache manager (for testing)
  CacheManager get cacheManager => _cacheManager;
}
