import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_price.dart';

/// Type d'autocomplétion
enum AutocompleteType {
  product,
  store,
}

/// Service d'autocomplétion intelligent basé sur l'historique
/// 
/// Ce service fournit des suggestions d'autocomplétion pour les noms de produits
/// et de magasins en se basant sur l'historique des saisies. Les suggestions sont
/// triées par fréquence d'utilisation décroissante.
class AutocompleteService {
  static const String _productPriceBoxName = 'productPrices';
  static const int _maxSuggestions = 10;

  Box<ProductPrice>? _productPriceBox;

  /// Initialise le service en ouvrant la box Hive
  Future<void> initialize() async {
    _productPriceBox = await Hive.openBox<ProductPrice>(_productPriceBoxName);
  }

  /// Retourne une liste de suggestions basée sur la requête
  /// 
  /// [query] - La chaîne de recherche (minimum 2 caractères recommandé)
  /// [type] - Le type d'autocomplétion (produit ou magasin)
  /// 
  /// Retourne une liste de suggestions triées par fréquence décroissante,
  /// limitée à 10 éléments maximum.
  List<String> getSuggestions(String query, AutocompleteType type) {
    if (_productPriceBox == null) {
      return [];
    }

    // Normaliser la requête (minuscules, trim)
    final normalizedQuery = query.trim().toLowerCase();
    
    if (normalizedQuery.isEmpty) {
      return [];
    }

    // Obtenir la map de fréquence
    final frequencyMap = getFrequencyMap(type);
    
    // Filtrer les entrées qui contiennent la requête (case-insensitive)
    final matches = frequencyMap.keys
        .where((item) => item.toLowerCase().contains(normalizedQuery))
        .toList();
    
    // Trier par fréquence décroissante
    matches.sort((a, b) => frequencyMap[b]!.compareTo(frequencyMap[a]!));
    
    // Limiter à 10 suggestions maximum
    return matches.take(_maxSuggestions).toList();
  }

  /// Enregistre l'utilisation d'une valeur pour améliorer les suggestions futures
  /// 
  /// Cette méthode est appelée automatiquement lors de l'ajout d'un nouveau prix.
  /// Elle n'a pas besoin d'être appelée manuellement car les données sont déjà
  /// persistées dans Hive via le StorageService.
  /// 
  /// [value] - La valeur utilisée (nom de produit ou magasin)
  /// [type] - Le type d'autocomplétion
  void recordUsage(String value, AutocompleteType type) {
    // Cette méthode est principalement documentaire car l'enregistrement
    // se fait automatiquement via l'ajout de ProductPrice dans Hive.
    // La fréquence est calculée dynamiquement via getFrequencyMap().
  }

  /// Retourne une map de fréquence pour le type spécifié
  /// 
  /// [type] - Le type d'autocomplétion (produit ou magasin)
  /// 
  /// Retourne une Map où les clés sont les noms (produits ou magasins)
  /// et les valeurs sont le nombre d'occurrences.
  Map<String, int> getFrequencyMap(AutocompleteType type) {
    if (_productPriceBox == null) {
      return {};
    }

    final frequencyMap = <String, int>{};
    
    for (final price in _productPriceBox!.values) {
      final key = type == AutocompleteType.product 
          ? price.productName 
          : price.shop;
      
      frequencyMap[key] = (frequencyMap[key] ?? 0) + 1;
    }
    
    return frequencyMap;
  }

  /// Retourne les N suggestions les plus fréquentes pour un type donné
  /// 
  /// Utile pour afficher des suggestions par défaut avant que l'utilisateur
  /// ne commence à taper.
  /// 
  /// [type] - Le type d'autocomplétion
  /// [limit] - Nombre maximum de suggestions (par défaut 10)
  List<String> getTopSuggestions(AutocompleteType type, {int limit = 10}) {
    final frequencyMap = getFrequencyMap(type);
    
    final sortedEntries = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  /// Nettoie les ressources
  Future<void> dispose() async {
    // La box est gérée globalement, pas besoin de la fermer ici
  }
}
