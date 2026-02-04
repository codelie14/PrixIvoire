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

    // Exécuter les recherches en parallèle
    final futures = [
      _searchOnJumia(query),
      _searchOnAmazon(query),
      _searchOnAliExpress(query),
      // Ajouter d'autres sites ici
    ];

    final results = await Future.wait(
      futures,
      eagerError: false,
    );

    // Combiner tous les résultats
    for (final result in results) {
      if (result != null) {
        allResults.addAll(result);
      }
    }

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

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);
      final products = <ScrapedProduct>[];

      // Sélecteurs pour Jumia
      final productElements = document.querySelectorAll('article.prd');

      for (final element in productElements.take(10)) {
        // Nom du produit
        final nameElement = element.querySelector('h3.name, .name');
        final name = nameElement?.text.trim() ?? '';

        if (name.isEmpty) continue;

        // Prix
        final priceElement = element.querySelector('.prc, .price');
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
          shop: 'Jumia CI',
          imageUrl: imageUrl.isNotEmpty ? _makeAbsoluteUrl(imageUrl, 'https://www.jumia.ci') : null,
          productUrl: productUrl.isNotEmpty ? _makeAbsoluteUrl(productUrl, 'https://www.jumia.ci') : null,
        ));
      }

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

  /// Extrait le prix d'une chaîne de caractères
  double? _extractPrice(String priceText) {
    if (priceText.isEmpty) return null;

    // Supprimer tous les caractères sauf les chiffres, points et virgules
    final cleaned = priceText.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Remplacer la virgule par un point pour le parsing
    final normalized = cleaned.replaceAll(',', '.');
    
    // Extraire le premier nombre trouvé
    final match = RegExp(r'\d+\.?\d*').firstMatch(normalized);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }

    return null;
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
