import 'dart:convert';

/// Entry in the cache with metadata for LRU eviction
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime expiresAt;
  int accessCount;
  DateTime lastAccessedAt;
  final int sizeBytes;

  CacheEntry({
    required this.value,
    required this.createdAt,
    required this.expiresAt,
    this.accessCount = 0,
    required this.lastAccessedAt,
    required this.sizeBytes,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  void recordAccess() {
    accessCount++;
    lastAccessedAt = DateTime.now();
  }
}

/// Cache manager with LRU eviction policy and TTL support
class CacheManager {
  final Map<String, CacheEntry> _cache = {};
  final int maxSizeBytes;
  int _currentSizeBytes = 0;

  CacheManager({this.maxSizeBytes = 10 * 1024 * 1024}); // 10MB default

  /// Get a value from cache
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      return null;
    }

    // Check if expired
    if (entry.isExpired) {
      invalidate(key);
      return null;
    }

    // Record access for LRU
    entry.recordAccess();
    
    return entry.value as T?;
  }

  /// Set a value in cache with TTL
  void set<T>(String key, T value, Duration ttl) {
    final now = DateTime.now();
    final sizeBytes = _estimateSize(value);

    // Remove old entry if exists
    if (_cache.containsKey(key)) {
      _currentSizeBytes -= _cache[key]!.sizeBytes;
    }

    // Check if we need to evict entries
    while (_currentSizeBytes + sizeBytes > maxSizeBytes && _cache.isNotEmpty) {
      evictLRU();
    }

    // Add new entry
    final entry = CacheEntry<T>(
      value: value,
      createdAt: now,
      expiresAt: now.add(ttl),
      lastAccessedAt: now,
      sizeBytes: sizeBytes,
    );

    _cache[key] = entry;
    _currentSizeBytes += sizeBytes;
  }

  /// Invalidate a specific cache entry
  void invalidate(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSizeBytes -= entry.sizeBytes;
    }
  }

  /// Invalidate entries matching a pattern
  void invalidatePattern(String pattern) {
    final regex = RegExp(pattern);
    final keysToRemove = _cache.keys.where((key) => regex.hasMatch(key)).toList();
    
    for (final key in keysToRemove) {
      invalidate(key);
    }
  }

  /// Clear all cache entries
  void clear() {
    _cache.clear();
    _currentSizeBytes = 0;
  }

  /// Evict the least recently used entry
  void evictLRU() {
    if (_cache.isEmpty) return;

    // Find the entry with the oldest lastAccessedAt
    String? lruKey;
    DateTime? oldestAccess;

    for (final entry in _cache.entries) {
      if (oldestAccess == null || entry.value.lastAccessedAt.isBefore(oldestAccess)) {
        oldestAccess = entry.value.lastAccessedAt;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      invalidate(lruKey);
    }
  }

  /// Get current cache size in bytes
  int get currentSizeBytes => _currentSizeBytes;

  /// Get number of entries in cache
  int get entryCount => _cache.length;

  /// Estimate size of an object in bytes
  int _estimateSize(dynamic value) {
    try {
      // For simple types, use rough estimates
      if (value is String) {
        return value.length * 2; // UTF-16 encoding
      } else if (value is int) {
        return 8;
      } else if (value is double) {
        return 8;
      } else if (value is bool) {
        return 1;
      } else if (value is List) {
        return value.fold<int>(0, (sum, item) => sum + _estimateSize(item));
      } else if (value is Map) {
        return value.entries.fold<int>(
          0,
          (sum, entry) => sum + _estimateSize(entry.key) + _estimateSize(entry.value),
        );
      } else {
        // For complex objects, try JSON serialization
        try {
          final json = jsonEncode(value);
          return json.length * 2;
        } catch (e) {
          // Fallback to a default size
          return 1024; // 1KB default
        }
      }
    } catch (e) {
      return 1024; // 1KB default on error
    }
  }

  /// Clean up expired entries
  void cleanExpired() {
    final keysToRemove = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      invalidate(key);
    }
  }
}
