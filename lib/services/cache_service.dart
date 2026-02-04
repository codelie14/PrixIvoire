import 'package:hive_flutter/hive_flutter.dart';
import '../models/scraped_product.dart';
import '../models/search_history.dart';

class CacheService {
  static const String _cacheBoxName = 'searchCache';
  static const String _historyBoxName = 'searchHistory';
  static const Duration _cacheValidity = Duration(hours: 24);

  late Box<Map> _cacheBox;
  late Box<SearchHistory> _historyBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<Map>(_cacheBoxName);
    _historyBox = await Hive.openBox<SearchHistory>(_historyBoxName);
  }

  /// Récupère les résultats en cache pour une requête
  List<ScrapedProduct>? getCachedResults(String query) {
    final cacheKey = _getCacheKey(query);
    final cachedData = _cacheBox.get(cacheKey);

    if (cachedData == null) return null;

    final cachedTime = DateTime.parse(cachedData['timestamp'] as String);
    final now = DateTime.now();

    // Vérifier si le cache est encore valide
    if (now.difference(cachedTime) > _cacheValidity) {
      _cacheBox.delete(cacheKey);
      return null;
    }

    // Désérialiser les résultats
    final results = (cachedData['results'] as List)
        .map((item) => ScrapedProduct.fromMap(item as Map<String, dynamic>))
        .toList();

    return results;
  }

  /// Met en cache les résultats d'une recherche
  Future<void> cacheResults(String query, List<ScrapedProduct> results) async {
    final cacheKey = _getCacheKey(query);
    final cacheData = {
      'timestamp': DateTime.now().toIso8601String(),
      'results': results.map((p) => p.toMap()).toList(),
    };
    await _cacheBox.put(cacheKey, cacheData);
  }

  /// Ajoute une recherche à l'historique
  Future<void> addToHistory(String query) async {
    // Supprimer les anciennes entrées avec la même requête
    final existing = _historyBox.values
        .where((h) => h.query.toLowerCase() == query.toLowerCase())
        .toList();
    for (final entry in existing) {
      await entry.delete();
    }

    // Ajouter la nouvelle entrée
    final history = SearchHistory(query: query);
    await _historyBox.add(history);

    // Limiter l'historique à 50 entrées
    final allHistory = _historyBox.values.toList()
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    if (allHistory.length > 50) {
      for (final entry in allHistory.skip(50)) {
        await entry.delete();
      }
    }
  }

  /// Récupère l'historique des recherches
  List<SearchHistory> getHistory() {
    final history = _historyBox.values.toList();
    history.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return history;
  }

  /// Supprime l'historique
  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  /// Nettoie le cache expiré
  Future<void> cleanExpiredCache() async {
    final now = DateTime.now();
    final keysToDelete = <String>[];

    for (final key in _cacheBox.keys) {
      final cachedData = _cacheBox.get(key);
      if (cachedData != null) {
        final cachedTime = DateTime.parse(cachedData['timestamp'] as String);
        if (now.difference(cachedTime) > _cacheValidity) {
          keysToDelete.add(key.toString());
        }
      }
    }

    for (final key in keysToDelete) {
      await _cacheBox.delete(key);
    }
  }

  String _getCacheKey(String query) {
    return query.toLowerCase().trim();
  }
}
