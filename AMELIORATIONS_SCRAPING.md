# Améliorations du Web Scraping - PrixIvoire

## 📊 État Actuel

Le service `WebScraperService` est déjà implémenté et supporte :

### ✅ Sites Actuellement Supportés
1. **Jumia CI** - ✅ Implémenté
2. **Djokstore CI** - ✅ Implémenté
3. **CoinAfrique CI** - ✅ Implémenté
4. **Cdiscount** - ✅ Implémenté (France)
5. **Fnac** - ✅ Implémenté (France)
6. **Amazon** - ✅ Implémenté (France)
7. **AliExpress** - ✅ Implémenté

### 🎯 Priorités Ivoiriennes
Les 3 premiers sites sont parfaits pour la Côte d'Ivoire :
- ✅ Jumia CI
- ✅ Djokstore CI
- ✅ CoinAfrique CI

---

## 🚀 Améliorations Recommandées

### 1. Ajouter de Nouveaux Sites Africains

#### A. Glotelho (Côte d'Ivoire/Cameroun)
```dart
Future<List<ScrapedProduct>?> _searchOnGlotelho(String query) async {
  try {
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://www.glotelho.ci/search?q=$encodedQuery';
    
    final response = await http
        .get(Uri.parse(url), headers: _headers)
        .timeout(_timeout);
    
    if (response.statusCode != 200) return null;
    
    final document = html_parser.parse(response.body);
    final products = <ScrapedProduct>[];
    
    final productElements = document.querySelectorAll(
      '.product-item, .product-card, [class*="product"]'
    );
    
    for (final element in productElements.take(10)) {
      final nameElement = element.querySelector('.product-title, h3, h2');
      final name = nameElement?.text.trim() ?? '';
      
      if (name.isEmpty) continue;
      
      final priceElement = element.querySelector('.price, .product-price');
      final priceText = priceElement?.text.trim() ?? '';
      final price = _extractPrice(priceText);
      
      final imageElement = element.querySelector('img');
      final imageUrl = imageElement?.attributes['data-src'] ??
          imageElement?.attributes['src'] ?? '';
      
      final linkElement = element.querySelector('a');
      final productUrl = linkElement?.attributes['href'] ?? '';
      
      products.add(ScrapedProduct(
        name: name,
        price: price,
        shop: 'Glotelho CI',
        imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.glotelho.ci') : null,
        productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.glotelho.ci') : null,
      ));
    }
    
    return products;
  } catch (e) {
    debugPrint('Erreur lors du scraping Glotelho: $e');
    return null;
  }
}
```

#### B. Konga (Nigeria)
```dart
Future<List<ScrapedProduct>?> _searchOnKonga(String query) async {
  try {
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://www.konga.com/search?search=$encodedQuery';
    
    final response = await http
        .get(Uri.parse(url), headers: _headers)
        .timeout(_timeout);
    
    if (response.statusCode != 200) return null;
    
    final document = html_parser.parse(response.body);
    final products = <ScrapedProduct>[];
    
    final productElements = document.querySelectorAll(
      '._2d6c4_3Xdq2, .product-item, [data-product-id]'
    );
    
    for (final element in productElements.take(10)) {
      final nameElement = element.querySelector('._2aKVe_2B0vN, .product-name, h3');
      final name = nameElement?.text.trim() ?? '';
      
      if (name.isEmpty) continue;
      
      final priceElement = element.querySelector('._2aKVe_2B0vN, .price');
      final priceText = priceElement?.text.trim() ?? '';
      final price = _extractPrice(priceText);
      
      final imageElement = element.querySelector('img');
      final imageUrl = imageElement?.attributes['data-src'] ??
          imageElement?.attributes['src'] ?? '';
      
      final linkElement = element.querySelector('a');
      final productUrl = linkElement?.attributes['href'] ?? '';
      
      products.add(ScrapedProduct(
        name: name,
        price: price,
        shop: 'Konga NG',
        imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.konga.com') : null,
        productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.konga.com') : null,
      ));
    }
    
    return products;
  } catch (e) {
    debugPrint('Erreur lors du scraping Konga: $e');
    return null;
  }
}
```

#### C. Kilimall (Kenya)
```dart
Future<List<ScrapedProduct>?> _searchOnKilimall(String query) async {
  try {
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://www.kilimall.co.ke/search?keyword=$encodedQuery';
    
    final response = await http
        .get(Uri.parse(url), headers: _headers)
        .timeout(_timeout);
    
    if (response.statusCode != 200) return null;
    
    final document = html_parser.parse(response.body);
    final products = <ScrapedProduct>[];
    
    final productElements = document.querySelectorAll(
      '.product-item, .goods-item, [class*="product"]'
    );
    
    for (final element in productElements.take(10)) {
      final nameElement = element.querySelector('.goods-name, .product-title, h3');
      final name = nameElement?.text.trim() ?? '';
      
      if (name.isEmpty) continue;
      
      final priceElement = element.querySelector('.price, .goods-price');
      final priceText = priceElement?.text.trim() ?? '';
      final price = _extractPrice(priceText);
      
      final imageElement = element.querySelector('img');
      final imageUrl = imageElement?.attributes['data-src'] ??
          imageElement?.attributes['src'] ?? '';
      
      final linkElement = element.querySelector('a');
      final productUrl = linkElement?.attributes['href'] ?? '';
      
      products.add(ScrapedProduct(
        name: name,
        price: price,
        shop: 'Kilimall KE',
        imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.kilimall.co.ke') : null,
        productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.kilimall.co.ke') : null,
      ));
    }
    
    return products;
  } catch (e) {
    debugPrint('Erreur lors du scraping Kilimall: $e');
    return null;
  }
}
```

### 2. Améliorer la Robustesse

#### A. Ajouter un Système de Retry
```dart
Future<http.Response?> _fetchWithRetry(String url, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        return response;
      }
      
      // Attendre avant de réessayer
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      }
    } catch (e) {
      if (i == maxRetries - 1) {
        debugPrint('Échec après $maxRetries tentatives: $e');
        return null;
      }
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
  }
  return null;
}
```

#### B. Ajouter un Rate Limiter
```dart
class RateLimiter {
  final Map<String, DateTime> _lastRequest = {};
  final Duration _minDelay = Duration(seconds: 2);
  
  Future<void> waitIfNeeded(String site) async {
    final lastTime = _lastRequest[site];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < _minDelay) {
        await Future.delayed(_minDelay - elapsed);
      }
    }
    _lastRequest[site] = DateTime.now();
  }
}
```

### 3. Améliorer l'Extraction de Prix

Le code actuel a déjà une bonne extraction de prix, mais on peut l'améliorer :

```dart
double? _extractPrice(String priceText) {
  if (priceText.isEmpty) return null;
  
  // Nettoyer le texte
  String cleaned = priceText.trim();
  
  // Patterns de prix courants
  final patterns = [
    // Format FCFA : 15 000 FCFA, 15000 FCFA, 15.000 FCFA
    RegExp(r'(\d+(?:[\s.,]\d+)*)\s*(?:FCFA|F|francs?)', caseSensitive: false),
    // Format EUR : 15,99 €, 15.99 €
    RegExp(r'(\d+[.,]\d{2})\s*€'),
    // Format USD : $15.99, 15.99$
    RegExp(r'[\$]?(\d+[.,]\d{2})[\$]?'),
    // Format simple : 15000, 15 000
    RegExp(r'(\d+(?:[\s.,]\d+)*)'),
  ];
  
  for (final pattern in patterns) {
    final match = pattern.firstMatch(cleaned);
    if (match != null) {
      String numStr = match.group(1)!;
      // Normaliser : supprimer espaces, remplacer virgule par point
      numStr = numStr.replaceAll(RegExp(r'[\s]'), '');
      
      // Déterminer si virgule ou point est le séparateur décimal
      final commaCount = ','.allMatches(numStr).length;
      final dotCount = '.'.allMatches(numStr).length;
      
      if (commaCount == 1 && dotCount == 0) {
        // Format français : 15,99
        numStr = numStr.replaceAll(',', '.');
      } else if (commaCount > 1 || dotCount > 1) {
        // Séparateurs de milliers : 15.000,99 ou 15,000.99
        final lastComma = numStr.lastIndexOf(',');
        final lastDot = numStr.lastIndexOf('.');
        
        if (lastComma > lastDot) {
          // Format français
          numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // Format anglais
          numStr = numStr.replaceAll(',', '');
        }
      }
      
      final price = double.tryParse(numStr);
      if (price != null && price >= 50) {
        return price;
      }
    }
  }
  
  return null;
}
```

### 4. Ajouter un Système de Configuration

```dart
class ScraperConfig {
  final String name;
  final String baseUrl;
  final String searchPath;
  final Map<String, String> selectors;
  final bool enabled;
  
  const ScraperConfig({
    required this.name,
    required this.baseUrl,
    required this.searchPath,
    required this.selectors,
    this.enabled = true,
  });
}

class WebScraperService {
  static final Map<String, ScraperConfig> _configs = {
    'jumia_ci': ScraperConfig(
      name: 'Jumia CI',
      baseUrl: 'https://www.jumia.ci',
      searchPath: '/catalog/?q=',
      selectors: {
        'product': 'article.prd, article[data-id]',
        'name': 'h3.name, h3.prd-name',
        'price': '.prc, .price',
        'image': 'img',
        'link': 'a',
      },
    ),
    'djokstore': ScraperConfig(
      name: 'Djokstore CI',
      baseUrl: 'https://djokstore.ci',
      searchPath: '/recherche?search_query=',
      selectors: {
        'product': '.product-item, .product-container',
        'name': '.product-title, .product-name',
        'price': '.price, .product-price',
        'image': 'img',
        'link': 'a',
      },
    ),
    // ... autres configs
  };
  
  Future<List<ScrapedProduct>> searchProduct(String query) async {
    final List<ScrapedProduct> allResults = [];
    
    for (final config in _configs.values.where((c) => c.enabled)) {
      try {
        final results = await _searchOnSite(query, config);
        if (results != null) {
          allResults.addAll(results);
        }
      } catch (e) {
        debugPrint('Erreur ${config.name}: $e');
      }
    }
    
    return allResults;
  }
  
  Future<List<ScrapedProduct>?> _searchOnSite(
    String query,
    ScraperConfig config,
  ) async {
    // Implémentation générique basée sur la config
    // ...
  }
}
```

---

## 📝 Plan d'Action

### Phase 1 : Optimisation (Immédiat)
1. ✅ Améliorer l'extraction de prix (déjà bon)
2. ⏳ Ajouter le système de retry
3. ⏳ Ajouter le rate limiter
4. ⏳ Améliorer le logging

### Phase 2 : Nouveaux Sites (Court terme)
1. ⏳ Ajouter Glotelho CI
2. ⏳ Tester et valider les 3 sites ivoiriens
3. ⏳ Optimiser les sélecteurs CSS

### Phase 3 : Extension Régionale (Moyen terme)
1. ⏳ Ajouter Konga (Nigeria)
2. ⏳ Ajouter Kilimall (Kenya)
3. ⏳ Ajouter autres pays Jumia

### Phase 4 : Système Avancé (Long terme)
1. ⏳ Système de configuration dynamique
2. ⏳ Interface admin pour gérer les scrapers
3. ⏳ Monitoring et alertes
4. ⏳ API cache pour réduire les requêtes

---

## 🧪 Tests Recommandés

### Tests Unitaires
```dart
test('Extract price from FCFA format', () {
  expect(_extractPrice('15 000 FCFA'), 15000);
  expect(_extractPrice('15000 FCFA'), 15000);
  expect(_extractPrice('15.000 FCFA'), 15000);
  expect(_extractPrice('15,000 FCFA'), 15000);
});

test('Extract price from decimal format', () {
  expect(_extractPrice('15,99 €'), 15.99);
  expect(_extractPrice('15.99 $'), 15.99);
});

test('Handle invalid prices', () {
  expect(_extractPrice(''), null);
  expect(_extractPrice('abc'), null);
  expect(_extractPrice('10 FCFA'), null); // Trop petit
});
```

### Tests d'Intégration
```dart
test('Search on Jumia CI returns results', () async {
  final service = WebScraperService();
  final results = await service._searchOnJumia('iphone');
  
  expect(results, isNotNull);
  expect(results!.isNotEmpty, true);
  expect(results.first.shop, 'Jumia CI');
});
```

---

## 📊 Métriques de Succès

### KPIs à Suivre
- **Taux de succès** : % de requêtes réussies par site
- **Temps de réponse** : Temps moyen par site
- **Nombre de résultats** : Moyenne de produits trouvés
- **Taux d'erreur** : % de requêtes échouées

### Objectifs
- ✅ Taux de succès > 90% pour sites ivoiriens
- ✅ Temps de réponse < 5 secondes par site
- ✅ Minimum 5 résultats par recherche
- ✅ Taux d'erreur < 10%

---

## 🔒 Considérations Légales

**Important** : Respecter les conditions d'utilisation de chaque site.

### Bonnes Pratiques
- ✅ Respecter robots.txt
- ✅ Rate limiting (2-5 secondes entre requêtes)
- ✅ User-Agent honnête
- ✅ Pas de surcharge des serveurs
- ✅ Cache des résultats

### À Éviter
- ❌ Scraping intensif
- ❌ Contournement de protections
- ❌ Revente de données
- ❌ Violation des CGU

---

**Dernière mise à jour** : Février 2026
**Statut** : Document de référence pour améliorations
