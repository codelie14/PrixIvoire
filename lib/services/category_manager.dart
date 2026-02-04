import '../models/category.dart';
import '../models/product_price.dart';

/// Service de gestion des catégories de produits
/// 
/// Ce service fournit des méthodes pour :
/// - Récupérer les catégories prédéfinies
/// - Filtrer les produits par catégorie
/// - Obtenir les comptages de produits par catégorie
class CategoryManager {
  /// Récupère toutes les catégories prédéfinies
  List<Category> getAllCategories() {
    return Category.predefinedCategories;
  }

  /// Récupère une catégorie par son ID
  /// 
  /// Retourne null si la catégorie n'existe pas
  Category? getCategoryById(String? id) {
    return Category.getCategoryById(id);
  }

  /// Récupère une catégorie par son ID ou retourne "Autres" si non trouvée
  Category getCategoryByIdOrDefault(String? id) {
    return Category.getCategoryByIdOrDefault(id);
  }

  /// Filtre une liste de produits par catégorie
  /// 
  /// [prices] - Liste des prix de produits à filtrer
  /// [categoryId] - ID de la catégorie à filtrer
  /// 
  /// Retourne une liste contenant uniquement les produits de la catégorie spécifiée.
  /// Si categoryId est 'other', retourne les produits sans catégorie ou avec catégorie 'other'.
  List<ProductPrice> filterByCategory(
    List<ProductPrice> prices,
    String categoryId,
  ) {
    if (categoryId == 'other') {
      // Pour la catégorie "Autres", inclure les produits sans catégorie
      // ou avec categoryId explicitement défini à 'other'
      return prices.where((price) {
        return price.categoryId == null ||
            price.categoryId == 'other' ||
            price.categoryId!.isEmpty;
      }).toList();
    }

    return prices.where((price) => price.categoryId == categoryId).toList();
  }

  /// Calcule le nombre de produits par catégorie
  /// 
  /// [prices] - Liste des prix de produits à analyser
  /// 
  /// Retourne une Map où la clé est l'ID de la catégorie et la valeur est le nombre
  /// de produits dans cette catégorie.
  Map<String, int> getCategoryCounts(List<ProductPrice> prices) {
    final Map<String, int> counts = {};

    // Initialiser les compteurs pour toutes les catégories prédéfinies
    for (final category in Category.predefinedCategories) {
      counts[category.id] = 0;
    }

    // Compter les produits par catégorie
    for (final price in prices) {
      final categoryId = price.categoryId;

      if (categoryId == null || categoryId.isEmpty) {
        // Produits sans catégorie vont dans "Autres"
        counts['other'] = (counts['other'] ?? 0) + 1;
      } else if (counts.containsKey(categoryId)) {
        // Catégorie valide
        counts[categoryId] = (counts[categoryId] ?? 0) + 1;
      } else {
        // Catégorie inconnue va dans "Autres"
        counts['other'] = (counts['other'] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Récupère les noms de produits uniques pour une catégorie donnée
  /// 
  /// [prices] - Liste des prix de produits
  /// [categoryId] - ID de la catégorie
  /// 
  /// Retourne une liste triée de noms de produits uniques dans la catégorie
  List<String> getProductNamesForCategory(
    List<ProductPrice> prices,
    String categoryId,
  ) {
    final filteredPrices = filterByCategory(prices, categoryId);
    final productNames = filteredPrices
        .map((price) => price.productName)
        .toSet()
        .toList();
    productNames.sort();
    return productNames;
  }

  /// Récupère la catégorie la plus utilisée
  /// 
  /// [prices] - Liste des prix de produits
  /// 
  /// Retourne la catégorie avec le plus de produits, ou null si la liste est vide
  Category? getMostUsedCategory(List<ProductPrice> prices) {
    if (prices.isEmpty) return null;

    final counts = getCategoryCounts(prices);
    
    // Trouver la catégorie avec le maximum de produits
    String? maxCategoryId;
    int maxCount = 0;

    counts.forEach((categoryId, count) {
      if (count > maxCount) {
        maxCount = count;
        maxCategoryId = categoryId;
      }
    });

    return maxCategoryId != null ? getCategoryById(maxCategoryId) : null;
  }

  /// Vérifie si une catégorie existe
  bool categoryExists(String? categoryId) {
    if (categoryId == null) return false;
    return Category.predefinedCategories.any((cat) => cat.id == categoryId);
  }
}
