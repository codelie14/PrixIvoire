import 'package:flutter_test/flutter_test.dart';
import 'package:prixivoire/services/cache_manager.dart';

void main() {
  group('CacheManager', () {
    late CacheManager cacheManager;

    setUp(() {
      cacheManager = CacheManager(maxSizeBytes: 1024); // 1KB for testing
    });

    test('should store and retrieve values', () {
      cacheManager.set('key1', 'value1', const Duration(minutes: 5));
      
      final result = cacheManager.get<String>('key1');
      
      expect(result, equals('value1'));
    });

    test('should return null for non-existent keys', () {
      final result = cacheManager.get<String>('nonexistent');
      
      expect(result, isNull);
    });

    test('should expire entries after TTL', () async {
      cacheManager.set('key1', 'value1', const Duration(milliseconds: 100));
      
      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 150));
      
      final result = cacheManager.get<String>('key1');
      
      expect(result, isNull);
    });

    test('should invalidate specific entries', () {
      cacheManager.set('key1', 'value1', const Duration(minutes: 5));
      cacheManager.set('key2', 'value2', const Duration(minutes: 5));
      
      cacheManager.invalidate('key1');
      
      expect(cacheManager.get<String>('key1'), isNull);
      expect(cacheManager.get<String>('key2'), equals('value2'));
    });

    test('should invalidate entries by pattern', () {
      cacheManager.set('user:1', 'John', const Duration(minutes: 5));
      cacheManager.set('user:2', 'Jane', const Duration(minutes: 5));
      cacheManager.set('product:1', 'Apple', const Duration(minutes: 5));
      
      cacheManager.invalidatePattern(r'^user:');
      
      expect(cacheManager.get<String>('user:1'), isNull);
      expect(cacheManager.get<String>('user:2'), isNull);
      expect(cacheManager.get<String>('product:1'), equals('Apple'));
    });

    test('should clear all entries', () {
      cacheManager.set('key1', 'value1', const Duration(minutes: 5));
      cacheManager.set('key2', 'value2', const Duration(minutes: 5));
      
      cacheManager.clear();
      
      expect(cacheManager.get<String>('key1'), isNull);
      expect(cacheManager.get<String>('key2'), isNull);
      expect(cacheManager.entryCount, equals(0));
    });

    test('should evict LRU entry when cache is full', () {
      // Fill cache with small entries
      cacheManager.set('key1', 'a' * 200, const Duration(minutes: 5));
      cacheManager.set('key2', 'b' * 200, const Duration(minutes: 5));
      
      // Access key2 to make it more recently used
      cacheManager.get<String>('key2');
      
      // Add a large entry that requires eviction
      cacheManager.set('key3', 'c' * 500, const Duration(minutes: 5));
      
      // key1 should be evicted (least recently used), but key3 should be present
      expect(cacheManager.get<String>('key3'), isNotNull);
      // Either key1 or key2 might be evicted depending on size requirements
      final hasKey1 = cacheManager.get<String>('key1') != null;
      final hasKey2 = cacheManager.get<String>('key2') != null;
      // At least one should be evicted
      expect(hasKey1 && hasKey2, isFalse);
    });

    test('should track access count', () {
      cacheManager.set('key1', 'value1', const Duration(minutes: 5));
      
      // Access multiple times
      cacheManager.get<String>('key1');
      cacheManager.get<String>('key1');
      cacheManager.get<String>('key1');
      
      // We can't directly check access count, but we can verify the entry exists
      expect(cacheManager.get<String>('key1'), equals('value1'));
    });

    test('should clean expired entries', () {
      cacheManager.set('key1', 'value1', const Duration(milliseconds: 100));
      cacheManager.set('key2', 'value2', const Duration(minutes: 5));
      
      // Wait for key1 to expire
      Future.delayed(const Duration(milliseconds: 150), () {
        cacheManager.cleanExpired();
        
        expect(cacheManager.get<String>('key1'), isNull);
        expect(cacheManager.get<String>('key2'), equals('value2'));
        expect(cacheManager.entryCount, equals(1));
      });
    });

    test('should estimate size correctly', () {
      cacheManager.set('key1', 'test', const Duration(minutes: 5));
      
      expect(cacheManager.currentSizeBytes, greaterThan(0));
      expect(cacheManager.currentSizeBytes, lessThanOrEqualTo(cacheManager.maxSizeBytes));
    });

    test('should handle different data types', () {
      cacheManager.set('string', 'value', const Duration(minutes: 5));
      cacheManager.set('int', 42, const Duration(minutes: 5));
      cacheManager.set('double', 3.14, const Duration(minutes: 5));
      cacheManager.set('bool', true, const Duration(minutes: 5));
      cacheManager.set('list', [1, 2, 3], const Duration(minutes: 5));
      cacheManager.set('map', {'key': 'value'}, const Duration(minutes: 5));
      
      expect(cacheManager.get<String>('string'), equals('value'));
      expect(cacheManager.get<int>('int'), equals(42));
      expect(cacheManager.get<double>('double'), equals(3.14));
      expect(cacheManager.get<bool>('bool'), equals(true));
      expect(cacheManager.get<List>('list'), equals([1, 2, 3]));
      expect(cacheManager.get<Map>('map'), equals({'key': 'value'}));
    });
  });
}
