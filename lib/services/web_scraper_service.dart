import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/scraped_product.dart';

class WebScraperService {
  static const Duration _timeout = Duration(seconds: 10);
  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
  };

  /// Recherche un produit sur plusieurs sites d'e-commerce
  Future<List<ScrapedProduct>> searchProduct(String query) async {
    final List<ScrapedProduct> allResults = [];

    debugPrint('=== Début de la recherche pour: "$query" ===');

    // Exécuter les recherches en parallèle
    final futures = [
      _searchOnJumia(query),
      _searchOnDjokstore(query),
      _searchOnCoinafrique(query),
      _searchOnCdiscount(query),
      _searchOnFnac(query),
      _searchOnAmazon(query),
      _searchOnAliExpress(query),
    ];

    final results = await Future.wait(
      futures,
      eagerError: false,
    );

    // Combiner tous les résultats avec logging
    final siteNames = ['Jumia', 'Djokstore', 'CoinAfrique', 'Cdiscount', 'Fnac', 'Amazon', 'AliExpress'];
    for (int i = 0; i < results.length; i++) {
      if (results[i] != null) {
        final count = results[i]!.length;
        debugPrint('${siteNames[i]}: $count résultat(s)');
        allResults.addAll(results[i]!);
      } else {
        debugPrint('${siteNames[i]}: Aucun résultat');
      }
    }

    debugPrint('=== Total: ${allResults.length} résultats ===');
    return allResults;
  }

  /// Recherche sur Jumia (Côte d'Ivoire)
  Future<List<ScrapedProduct>?> _searchOnJumia(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://www.jumia.ci/catalog/?q=$encodedQuery';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('Jumia: Status code ${response.statusCode}');
        return null;
      }

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour Jumia - plusieurs variantes possibles
      final productElements = document.querySelectorAll(
        'article.prd, article[data-id], .prd, [data-sku], .sku, .product-item'
      );

      debugPrint('Jumia: ${productElements.length} éléments trouvés');

      for (final element in productElements.take(15)) {
        // Nom du produit - plusieurs sélecteurs possibles
        final nameElement = element.querySelector(
          'h3.name, h3.prd-name, .name, .prd-name, [data-name], .product-title, h2, h3'
        );
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix - plusieurs sélecteurs et attributs possibles
        var priceText = '';
        var priceElement = element.querySelector(
          '.prc, .price, .prc-box, [data-price], .product-price, .current-price'
        );
        
        if (priceElement != null) {
          priceText = priceElement.text.trim();
          // Vérifier aussi l'attribut data-price
          if (priceText.isEmpty) {
            priceText = priceElement.attributes['data-price'] ?? '';
          }
        }
        
        // Si toujours vide, chercher dans tout l'élément
        if (priceText.isEmpty) {
          final allText = element.text;
          final priceMatch = RegExp(r'(\d+(?:\s?\d+)*(?:\s?[.,]\d+)?)\s*(?:FCFA|F|francs?)', caseSensitive: false)
              .firstMatch(allText);
          priceText = priceMatch?.group(0) ?? '';
        }
        
        final price = _extractPrice(priceText);
        
        if (price != null && price < 100) {
          debugPrint('Jumia: Prix suspect ($price) pour "$name" - texte: "$priceText"');
        }

        // Image
        final imageElement = element.querySelector('img');
        final imageUrl = imageElement?.attributes['data-src'] ??
            imageElement?.attributes['data-lazy-src'] ??
            imageElement?.attributes['src'] ??
            '';

        // Lien produit
        final linkElement = element.querySelector('a');
        final productUrl = linkElement?.attributes['href'] ?? '';

        products.add(ScrapedProduct(
          name: name,
          price: price,
          shop: 'Jumia CI',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.jumia.ci') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.jumia.ci') : null,
        ));
      }

      debugPrint('Jumia: ${products.length} produits extraits');
      return products;
    } catch (e) {
      debugPrint('Erreur lors du scraping Jumia: $e');
      return null;
    }
  }

  /// Recherche sur Amazon (exemple générique)
  Future<List<ScrapedProduct>?> _searchOnAmazon(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://www.amazon.fr/s?k=$encodedQuery';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour Amazon
      final productElements = document.querySelectorAll('[data-component-type="s-search-result"]');

      for (final element in productElements.take(10)) {
        // Nom du produit
        final nameElement = element.querySelector('h2 a span');
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix
        final priceElement = element.querySelector('.a-price-whole, .a-price .a-offscreen');
        final priceText = priceElement?.text.trim() ?? '';
        final price = _extractPrice(priceText);

        // Image
        final imageElement = element.querySelector('img');
        final imageUrl = imageElement?.attributes['src'] ?? '';

        // Lien produit
        final linkElement = element.querySelector('h2 a');
        final productUrl = linkElement?.attributes['href'] ?? '';

        products.add(ScrapedProduct(
          name: name,
          price: price,
          shop: 'Amazon',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.amazon.fr') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.amazon.fr') : null,
        ));
      }

      return products;
    } catch (e) {
      debugPrint('Erreur lors du scraping Amazon: $e');
      return null;
    }
  }

  /// Recherche sur AliExpress (exemple générique)
  Future<List<ScrapedProduct>?> _searchOnAliExpress(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://fr.aliexpress.com/wholesale?SearchText=$encodedQuery';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour AliExpress
      final productElements = document.querySelectorAll('[data-widget-cid="2-1"]');

      for (final element in productElements.take(10)) {
        // Nom du produit
        final nameElement = element.querySelector('h1, .item-title');
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix
        final priceElement = element.querySelector('.price-current, .price');
        final priceText = priceElement?.text.trim() ?? '';
        final price = _extractPrice(priceText);

        // Image
        final imageElement = element.querySelector('img');
        final imageUrl = imageElement?.attributes['src'] ?? '';

        // Lien produit
        final linkElement = element.querySelector('a');
        final productUrl = linkElement?.attributes['href'] ?? '';

        products.add(ScrapedProduct(
          name: name,
          price: price,
          shop: 'AliExpress',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://fr.aliexpress.com') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://fr.aliexpress.com') : null,
        ));
      }

      return products;
    } catch (e) {
      debugPrint('Erreur lors du scraping AliExpress: $e');
      return null;
    }
  }

  /// Recherche sur Djokstore (Côte d'Ivoire)
  Future<List<ScrapedProduct>?> _searchOnDjokstore(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://djokstore.ci/recherche?controller=search&orderby=position&orderway=desc&search_query=$encodedQuery';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('Djokstore: Status code ${response.statusCode}');
        return null;
      }

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour Djokstore - plusieurs variantes
      final productElements = document.querySelectorAll(
        '.product-item, .product-container, article.product, .product, [class*="product"], .item-product'
      );

      debugPrint('Djokstore: ${productElements.length} éléments trouvés');

      for (final element in productElements.take(10)) {
        // Nom du produit
        final nameElement = element.querySelector(
          '.product-title, .product-name, h3, h2, .title, [class*="title"]'
        );
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix - chercher dans plusieurs endroits
        var priceText = '';
        var priceElement = element.querySelector(
          '.price, .product-price, .current-price, [class*="price"], .price-current'
        );
        
        if (priceElement != null) {
          priceText = priceElement.text.trim();
        }
        
        // Si toujours vide, chercher dans tout l'élément
        if (priceText.isEmpty) {
          final allText = element.text;
          final priceMatch = RegExp(r'(\d+(?:\s?\d+)*(?:\s?[.,]\d+)?)\s*(?:FCFA|F|francs?)', caseSensitive: false)
              .firstMatch(allText);
          priceText = priceMatch?.group(0) ?? '';
        }
        
        final price = _extractPrice(priceText);

        // Image
        final imageElement = element.querySelector('img');
        final imageUrl = imageElement?.attributes['data-src'] ??
            imageElement?.attributes['data-lazy-src'] ??
            imageElement?.attributes['src'] ??
            '';

        // Lien produit
        final linkElement = element.querySelector('a');
        final productUrl = linkElement?.attributes['href'] ?? '';

        products.add(ScrapedProduct(
          name: name,
          price: price,
          shop: 'Djokstore CI',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://djokstore.ci') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://djokstore.ci') : null,
        ));
      }

      debugPrint('Djokstore: ${products.length} produits extraits');
      return products;
    } catch (e) {
      debugPrint('Erreur lors du scraping Djokstore: $e');
      return null;
    }
  }

  /// Recherche sur CoinAfrique (Côte d'Ivoire)
  Future<List<ScrapedProduct>?> _searchOnCoinafrique(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://ci.coinafrique.com/search?q=$encodedQuery';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('CoinAfrique: Status code ${response.statusCode}');
        return null;
      }

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour CoinAfrique
      final productElements = document.querySelectorAll(
        '.ad-item, .product-card, [class*="product"], .ad, [class*="ad"], .item'
      );

      debugPrint('CoinAfrique: ${productElements.length} éléments trouvés');

      for (final element in productElements.take(10)) {
        // Nom du produit
        final nameElement = element.querySelector(
          '.ad-title, .product-title, h3, h2, .title, [class*="title"]'
        );
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix
        var priceText = '';
        var priceElement = element.querySelector(
          '.price, .ad-price, [class*="price"], .amount'
        );
        
        if (priceElement != null) {
          priceText = priceElement.text.trim();
        }
        
        // Si toujours vide, chercher dans tout l'élément
        if (priceText.isEmpty) {
          final allText = element.text;
          final priceMatch = RegExp(r'(\d+(?:\s?\d+)*(?:\s?[.,]\d+)?)\s*(?:FCFA|F|francs?)', caseSensitive: false)
              .firstMatch(allText);
          priceText = priceMatch?.group(0) ?? '';
        }
        
        final price = _extractPrice(priceText);

        // Image
        final imageElement = element.querySelector('img');
        final imageUrl = imageElement?.attributes['data-src'] ??
            imageElement?.attributes['data-lazy-src'] ??
            imageElement?.attributes['src'] ??
            '';

        // Lien produit
        final linkElement = element.querySelector('a');
        final productUrl = linkElement?.attributes['href'] ?? '';

        products.add(ScrapedProduct(
          name: name,
          price: price,
          shop: 'CoinAfrique CI',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://ci.coinafrique.com') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://ci.coinafrique.com') : null,
        ));
      }

      debugPrint('CoinAfrique: ${products.length} produits extraits');
      return products;
    } catch (e) {
      debugPrint('Erreur lors du scraping CoinAfrique: $e');
      return null;
    }
  }

  /// Recherche sur Cdiscount
  Future<List<ScrapedProduct>?> _searchOnCdiscount(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://www.cdiscount.com/search/10/$encodedQuery.html';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour Cdiscount
      final productElements = document.querySelectorAll('.prdtBloc, .prdtBZPrice, [data-product-id]');

      for (final element in productElements.take(10)) {
        // Nom du produit
        final nameElement = element.querySelector('.prdtBILa, .prdtBTit, h2, h3');
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix
        final priceElement = element.querySelector('.price, .prdtPrice, .fpPrice');
        final priceText = priceElement?.text.trim() ?? '';
        final price = _extractPrice(priceText);

        // Image
        final imageElement = element.querySelector('img');
        final imageUrl = imageElement?.attributes['data-src'] ??
            imageElement?.attributes['src'] ??
            '';

        // Lien produit
        final linkElement = element.querySelector('a');
        final productUrl = linkElement?.attributes['href'] ?? '';

        products.add(ScrapedProduct(
          name: name,
          price: price,
          shop: 'Cdiscount',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.cdiscount.com') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.cdiscount.com') : null,
        ));
      }

      return products;
    } catch (e) {
      debugPrint('Erreur lors du scraping Cdiscount: $e');
      return null;
    }
  }

  /// Recherche sur Fnac
  Future<List<ScrapedProduct>?> _searchOnFnac(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://www.fnac.com/SearchResult/ResultList.aspx?SCat=0&Search=$encodedQuery';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour Fnac
      final productElements = document.querySelectorAll('.Article-item, .product-item, [data-product-id]');

      for (final element in productElements.take(10)) {
        // Nom du produit
        final nameElement = element.querySelector('.Article-title, .product-title, h2, h3');
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix
        final priceElement = element.querySelector('.price, .userPrice, .f-priceBox');
        final priceText = priceElement?.text.trim() ?? '';
        final price = _extractPrice(priceText);

        // Image
        final imageElement = element.querySelector('img');
        final imageUrl = imageElement?.attributes['data-src'] ??
            imageElement?.attributes['src'] ??
            '';

        // Lien produit
        final linkElement = element.querySelector('a');
        final productUrl = linkElement?.attributes['href'] ?? '';

        products.add(ScrapedProduct(
          name: name,
          price: price,
          shop: 'Fnac',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.fnac.com') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.fnac.com') : null,
        ));
      }

      return products;
    } catch (e) {
      debugPrint('Erreur lors du scraping Fnac: $e');
      return null;
    }
  }

  /// Extrait le prix d'une chaîne de caractères
  double? _extractPrice(String priceText) {
    if (priceText.isEmpty) return null;

    // Nettoyer le texte : supprimer les espaces, caractères spéciaux, etc.
    String cleaned = priceText.trim();
    
    // Remplacer les séparateurs de milliers (espaces, points comme séparateurs de milliers)
    // Format français : 1 234,56 ou 1.234,56
    // Format anglais : 1,234.56
    // Format simple : 1234.56 ou 1234,56
    
    // Détecter le format
    bool hasComma = cleaned.contains(',');
    bool hasDot = cleaned.contains('.');
    
    if (hasComma && hasDot) {
      // Format mixte : déterminer lequel est le séparateur décimal
      final commaIndex = cleaned.lastIndexOf(',');
      final dotIndex = cleaned.lastIndexOf('.');
      
      if (commaIndex > dotIndex) {
        // Format français : 1.234,56 ou 1 234,56
        cleaned = cleaned.replaceAll(RegExp(r'[\s.]'), '').replaceAll(',', '.');
      } else {
        // Format anglais : 1,234.56
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (hasComma) {
      // Format avec virgule : peut être français (1 234,56) ou simple (1234,56)
      // Si la virgule est suivie de 2 chiffres, c'est probablement un séparateur décimal
      final commaMatch = RegExp(r',(\d{1,2})\D').firstMatch(cleaned);
      if (commaMatch != null && commaMatch.group(1)!.length <= 2) {
        // Séparateur décimal
        cleaned = cleaned.replaceAll(RegExp(r'[\s.]'), '').replaceAll(',', '.');
      } else {
        // Séparateur de milliers ou format simple
        cleaned = cleaned.replaceAll(RegExp(r'[\s,]'), '');
      }
    } else if (hasDot) {
      // Format avec point : peut être anglais (1,234.56) ou simple (1234.56)
      // Si le point est suivi de 2 chiffres, c'est probablement un séparateur décimal
      final dotMatch = RegExp(r'\.(\d{1,2})\D').firstMatch(cleaned);
      if (dotMatch != null && dotMatch.group(1)!.length <= 2) {
        // Séparateur décimal
        cleaned = cleaned.replaceAll(RegExp(r'[\s,]'), '');
      } else {
        // Séparateur de milliers
        cleaned = cleaned.replaceAll(RegExp(r'[\s.]'), '');
      }
    } else {
      // Pas de séparateur, juste des chiffres
      cleaned = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    }
    
    // Extraire tous les nombres (y compris ceux avec décimales)
    final numbers = RegExp(r'\d+(?:[.,]\d+)?')
        .allMatches(cleaned)
        .map((m) {
          final numStr = m.group(0)!.replaceAll(',', '.');
          return double.tryParse(numStr);
        })
        .whereType<double>()
        .toList();
    
    if (numbers.isEmpty) {
      debugPrint('Aucun nombre trouvé dans: "$priceText" -> "$cleaned"');
      return null;
    }
    
    // Filtrer les nombres trop petits (< 50) qui sont probablement des erreurs ou des quantités
    final validNumbers = numbers.where((n) => n >= 50).toList();
    
    if (validNumbers.isEmpty) {
      debugPrint('Aucun nombre valide (>=50) dans: "$priceText" -> nombres: $numbers');
      return null;
    }
    
    // Prendre le nombre le plus grand (généralement le prix réel)
    final maxPrice = validNumbers.reduce((a, b) => a > b ? a : b);
    debugPrint('Prix extrait: "$priceText" -> $maxPrice (parmi: $validNumbers)');
    
    return maxPrice;
  }

  /// Convertit une URL relative en URL absolue
  String _makeAbsoluteUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }
}
