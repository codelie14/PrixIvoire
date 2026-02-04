# Système de Cache - PrixIvoire

## Vue d'Ensemble

Le système de cache de PrixIvoire implémente une stratégie de mise en cache en mémoire avec politique LRU (Least Recently Used) et gestion TTL (Time To Live) pour améliorer les performances de l'application.

## Architecture

### Composants

1. **CacheManager** - Gestionnaire de cache générique
2. **EnhancedCacheService** - Service de cache spécialisé pour PrixIvoire
3. **CachedStorageService** - Wrapper qui intègre le cache avec le stockage

### Flux de Données

```
Requête → CachedStorageService → EnhancedCacheService → CacheManager
                ↓                                              ↓
         OptimizedStorageService                        Mémoire (Map)
                ↓
              Hive
```

## Utilisation

### Configuration de Base

```dart
// Initialiser les services
final storageService = OptimizedStorageService();
await storageService.initialize();

final cacheService = EnhancedCacheService();
final cachedStorage = CachedStorageService(
  storageService: storageService,
  cacheService: cacheService,
);
```

### Recherche avec Cache

```dart
// Première recherche - va au stockage
final results = await cachedStorage.searchProducts('pain');

// Deuxième recherche dans les 5 minutes - vient du cache
final cachedResults = await cachedStorage.searchProducts('pain');
```

### Produits Populaires

```dart
// Récupère les 50 produits les plus consultés (avec cache)
final popular = await cachedStorage.getPopularProducts(limit: 50);
```

### Invalidation Automatique

```dart
// Ajouter un prix - invalide automatiquement les caches
await cachedStorage.addProductPrice(newPrice);

// Supprimer un prix - invalide automatiquement les caches
await cachedStorage.deleteProductPrice(price);
```

### Vidage Manuel

```dart
// Vider tout le cache
cachedStorage.clearCache();

// Nettoyer les entrées expirées
cachedStorage.cleanExpiredCache();
```

### Statistiques du Cache

```dart
final stats = cachedStorage.getCacheStats();
print('Taille: ${stats['currentSizeBytes']} / ${stats['maxSizeBytes']}');
print('Utilisation: ${stats['usagePercentage']}%');
print('Entrées: ${stats['entryCount']}');
```

## Configuration

### TTL par Type de Données

| Type de Données | TTL | Raison |
|----------------|-----|--------|
| Résultats de recherche | 5 minutes | Les prix changent fréquemment |
| Produits populaires | 5 minutes | La popularité évolue |
| Statistiques | 10 minutes | Calculs coûteux, changent moins souvent |

### Limites

- **Taille maximale**: 10MB (configurable)
- **Politique d'éviction**: LRU (Least Recently Used)
- **Invalidation**: Automatique lors des modifications

## CacheManager - API Détaillée

### Méthodes Principales

#### `get<T>(String key)`
Récupère une valeur du cache.

```dart
final value = cacheManager.get<String>('my_key');
if (value != null) {
  // Utiliser la valeur
}
```

#### `set<T>(String key, T value, Duration ttl)`
Ajoute une valeur au cache avec TTL.

```dart
cacheManager.set('my_key', 'my_value', Duration(minutes: 5));
```

#### `invalidate(String key)`
Invalide une entrée spécifique.

```dart
cacheManager.invalidate('my_key');
```

#### `invalidatePattern(String pattern)`
Invalide les entrées correspondant à un pattern regex.

```dart
// Invalide toutes les clés commençant par "search:"
cacheManager.invalidatePattern(r'^search:');
```

#### `clear()`
Vide tout le cache.

```dart
cacheManager.clear();
```

#### `evictLRU()`
Évince l'entrée la moins récemment utilisée.

```dart
cacheManager.evictLRU();
```

#### `cleanExpired()`
Nettoie les entrées expirées.

```dart
cacheManager.cleanExpired();
```

## EnhancedCacheService - API Détaillée

### Méthodes de Cache

#### Résultats de Recherche

```dart
// Mettre en cache
cacheService.cacheSearchResults('query', results);

// Récupérer du cache
final cached = cacheService.getCachedSearchResults('query');
```

#### Produits Populaires

```dart
// Mettre en cache
cacheService.cachePopularProducts(products);

// Récupérer du cache
final cached = cacheService.getCachedPopularProducts();
```

#### Statistiques

```dart
// Mettre en cache
cacheService.cacheStatistics('productName', stats);

// Récupérer du cache
final cached = cacheService.getCachedStatistics('productName');
```

### Méthodes d'Invalidation

```dart
// Invalider les recherches
cacheService.invalidateSearchCaches();

// Invalider les statistiques d'un produit
cacheService.invalidateProductStatistics('productName');

// Invalider toutes les statistiques
cacheService.invalidateAllStatistics();

// Invalider les produits populaires
cacheService.invalidatePopularProducts();

// Invalider tout ce qui est lié à une modification
cacheService.onDataModified(productName: 'productName');
```

## Bonnes Pratiques

### 1. Utiliser CachedStorageService

Toujours utiliser `CachedStorageService` au lieu d'accéder directement à `OptimizedStorageService` pour bénéficier du cache.

```dart
// ✅ Bon
final results = await cachedStorage.searchProducts('query');

// ❌ Mauvais
final results = await storageService.searchProducts('query');
```

### 2. Invalider Après Modifications

Toujours invalider le cache après avoir modifié des données.

```dart
// ✅ Bon - utilise CachedStorageService qui invalide automatiquement
await cachedStorage.addProductPrice(price);

// ❌ Mauvais - modifie sans invalider
await storageService.addProductPrice(price);
```

### 3. Nettoyer Périodiquement

Nettoyer les entrées expirées périodiquement pour libérer la mémoire.

```dart
// Dans un timer ou au démarrage
Timer.periodic(Duration(minutes: 10), (_) {
  cachedStorage.cleanExpiredCache();
});
```

### 4. Surveiller la Taille

Surveiller la taille du cache pour éviter une utilisation excessive de la mémoire.

```dart
final stats = cachedStorage.getCacheStats();
if (int.parse(stats['usagePercentage'].toString().split('.')[0]) > 80) {
  // Cache presque plein, considérer un nettoyage
  cachedStorage.cleanExpiredCache();
}
```

## Performance

### Temps d'Accès

| Opération | Sans Cache | Avec Cache | Amélioration |
|-----------|-----------|-----------|--------------|
| Recherche simple | ~50-200ms | <1ms | 50-200x |
| Produits populaires | ~100-300ms | <1ms | 100-300x |
| Statistiques | ~20-50ms | <1ms | 20-50x |

### Utilisation Mémoire

- **Taille maximale**: 10MB
- **Taille typique**: 2-5MB avec utilisation normale
- **Éviction**: Automatique quand > 10MB

## Tests

### Exécuter les Tests

```bash
# Tests du CacheManager
flutter test test/unit/services/cache_manager_test.dart

# Tests du EnhancedCacheService
flutter test test/unit/services/enhanced_cache_service_test.dart

# Tous les tests de cache
flutter test test/unit/services/cache_manager_test.dart test/unit/services/enhanced_cache_service_test.dart
```

### Couverture

- **CacheManager**: 11 tests
- **EnhancedCacheService**: 11 tests
- **Total**: 22 tests, tous passent ✅

## Dépannage

### Le Cache Ne Fonctionne Pas

1. Vérifier que `CachedStorageService` est utilisé
2. Vérifier que le service est initialisé
3. Vérifier les logs pour les erreurs

### Cache Trop Plein

1. Réduire les TTL
2. Augmenter la limite de taille
3. Nettoyer plus fréquemment

### Données Obsolètes

1. Vérifier que l'invalidation fonctionne
2. Réduire les TTL
3. Forcer un vidage manuel

## Références

- **Exigences**: 12.1 - 12.6
- **Design**: Section "Système de Cache" dans design.md
- **Tests**: test/unit/services/cache_*.dart
