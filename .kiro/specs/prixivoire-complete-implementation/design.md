# Document de Design - PrixIvoire

## Vue d'Ensemble

PrixIvoire est une application Flutter de comparaison de prix qui permet aux utilisateurs de suivre, comparer et analyser les prix des produits en Côte d'Ivoire. Ce document décrit l'architecture technique, les composants, les modèles de données et les stratégies d'implémentation pour les améliorations complètes de l'application.

### Objectifs du Design

1. Améliorer l'expérience utilisateur avec une interface moderne et fluide
2. Optimiser les performances pour gérer de grands volumes de données
3. Implémenter des fonctionnalités avancées d'analyse et de visualisation
4. Assurer la robustesse avec une gestion d'erreurs complète
5. Faciliter le partage et l'export de données
6. Maintenir une architecture modulaire et testable

### Technologies Principales

- **Framework**: Flutter 3.x avec Dart 3.x
- **Stockage Local**: Hive (base de données NoSQL)
- **OCR**: google_ml_kit ou tesseract_ocr
- **Graphiques**: fl_chart ou syncfusion_flutter_charts
- **État**: Provider ou Riverpod pour la gestion d'état
- **Export**: pdf, csv, excel (syncfusion_flutter_xlsio)
- **Animations**: Flutter built-in animations + lottie

## Architecture

### Architecture Globale

L'application suit une architecture en couches (Layered Architecture) avec séparation claire des responsabilités :

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, ViewModels)         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Business Logic Layer            │
│  (Services, Controllers, Use Cases)     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Data Layer                      │
│  (Models, Repositories, Data Sources)   │
└─────────────────────────────────────────┘
```

### Structure des Dossiers

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── errors/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── services/
    ├── storage/
    ├── ocr/
    ├── cache/
    ├── export/
    └── analytics/
```

### Flux de Données

1. **Lecture de données**: Screen → Provider → UseCase → Repository → DataSource → Hive
2. **Écriture de données**: Screen → Provider → UseCase → Repository → DataSource → Hive → Cache Invalidation
3. **OCR**: Screen → OCR Service → Image Processing → Text Extraction → Data Parsing → Repository

## Composants et Interfaces

### 1. Système de Thèmes

#### ThemeManager

```dart
class ThemeManager {
  ThemeMode currentTheme;
  
  Future<void> loadTheme();
  Future<void> setTheme(ThemeMode mode);
  ThemeData getLightTheme();
  ThemeData getDarkTheme();
}
```

**Responsabilités**:
- Charger le thème sauvegardé au démarrage
- Persister les changements de thème
- Fournir les configurations de thème Material Design 3

**Implémentation**:
- Utiliser `ThemeData` avec `useMaterial3: true`
- Définir des `ColorScheme` personnalisés pour clair/sombre
- Sauvegarder dans Hive avec une clé `app_theme`

### 2. Système d'Autocomplétion

#### AutocompleteService

```dart
class AutocompleteService {
  List<String> getSuggestions(String query, AutocompleteType type);
  void recordUsage(String value, AutocompleteType type);
  Map<String, int> getFrequencyMap(AutocompleteType type);
}

enum AutocompleteType { product, store }
```

**Responsabilités**:
- Rechercher dans l'historique des produits/magasins
- Trier par fréquence d'utilisation
- Limiter à 10 suggestions maximum

**Algorithme de Suggestion**:
1. Filtrer les entrées contenant la requête (case-insensitive)
2. Trier par fréquence décroissante
3. Prendre les 10 premiers résultats
4. Retourner la liste triée

### 3. Système de Catégories

#### CategoryManager

```dart
class CategoryManager {
  static const List<Category> predefinedCategories = [
    Category(id: 'food', name: 'Alimentaire', icon: Icons.restaurant),
    Category(id: 'electronics', name: 'Électronique', icon: Icons.devices),
    Category(id: 'hygiene', name: 'Hygiène', icon: Icons.clean_hands),
    Category(id: 'clothing', name: 'Vêtements', icon: Icons.checkroom),
    Category(id: 'home', name: 'Maison', icon: Icons.home),
    Category(id: 'other', name: 'Autres', icon: Icons.category),
  ];
  
  Category getCategoryById(String id);
  List<ProductPrice> filterByCategory(String categoryId);
  Map<String, int> getCategoryCounts();
}
```

### 4. Moteur de Statistiques

#### StatisticsEngine

```dart
class StatisticsEngine {
  double calculateMean(List<double> prices);
  double calculateMedian(List<double> prices);
  double calculateStandardDeviation(List<double> prices);
  PriceRange findPriceRange(List<ProductPrice> prices);
  double calculatePotentialSavings(List<ProductPrice> prices);
  StoreComparison compareStores(String productName);
}

class PriceRange {
  double min;
  double max;
  String minStore;
  String maxStore;
}

class StoreComparison {
  Map<String, double> averagePriceByStore;
  String cheapestStore;
  String mostExpensiveStore;
}
```

**Algorithmes**:

- **Moyenne**: `sum(prices) / count(prices)`
- **Médiane**: Trier les prix, prendre la valeur centrale (ou moyenne des 2 centrales si pair)
- **Écart-type**: `sqrt(sum((x - mean)^2) / n)`
- **Économie potentielle**: `max(prices) - min(prices)`

### 5. Système de Filtrage

#### FilterManager

```dart
class FilterManager {
  PriceFilter currentFilter;
  
  List<ProductPrice> applyFilters(List<ProductPrice> prices);
  void setDateRange(DateRange range);
  void setPriceRange(double min, double max);
  void setCategory(String categoryId);
  void setStore(String storeName);
  void clearFilters();
}

class PriceFilter {
  DateRange? dateRange;
  PriceRange? priceRange;
  String? categoryId;
  String? storeName;
  
  bool matches(ProductPrice price);
}

class DateRange {
  DateTime start;
  DateTime end;
  
  static DateRange lastWeek();
  static DateRange lastMonth();
  static DateRange last3Months();
  static DateRange custom(DateTime start, DateTime end);
}
```

**Logique de Filtrage**:
- Appliquer tous les filtres avec un ET logique
- Chaque filtre null est ignoré
- Retourner uniquement les entrées qui passent tous les filtres actifs

### 6. Système de Favoris

#### FavoritesManager

```dart
class FavoritesManager {
  Set<String> favoriteProductIds;
  
  Future<void> addFavorite(String productName);
  Future<void> removeFavorite(String productName);
  bool isFavorite(String productName);
  List<ProductPrice> getFavoriteProducts();
  Future<void> loadFavorites();
  Future<void> saveFavorites();
}
```

**Implémentation**:
- Stocker les IDs de produits favoris dans un Set pour éviter les doublons
- Persister dans Hive avec une clé `favorite_products`
- Utiliser un Set pour des opérations O(1) sur contains/add/remove

### 7. Optimisation OCR

#### EnhancedOCRService

```dart
class EnhancedOCRService {
  Future<OCRResult> processImage(File imageFile);
  Future<File> preprocessImage(File imageFile);
  List<PriceEntry> extractPrices(String text);
}

class OCRResult {
  String rawText;
  List<PriceEntry> extractedPrices;
  double confidence;
  Duration processingTime;
}

class PriceEntry {
  String productName;
  double price;
  int lineNumber;
}
```

**Pipeline de Traitement**:

1. **Prétraitement d'Image**:
   - Conversion en niveaux de gris
   - Ajustement du contraste (CLAHE - Contrast Limited Adaptive Histogram Equalization)
   - Correction de la luminosité
   - Détection et correction de rotation (Hough Transform)
   - Réduction du bruit (Gaussian Blur)

2. **Extraction de Texte**:
   - Utiliser google_ml_kit TextRecognizer
   - Configurer pour le français
   - Extraire le texte ligne par ligne

3. **Parsing de Prix**:
   - Expression régulière: `r'([A-Za-zÀ-ÿ\s]+)\s+(\d+[\s,.]?\d*)\s*(?:FCFA|CFA|F)?'`
   - Nettoyer les espaces et caractères spéciaux
   - Valider que le prix est un nombre positif
   - Associer produit et prix sur la même ligne

### 8. Optimisation du Stockage Hive

#### OptimizedStorageService

```dart
class OptimizedStorageService {
  Box<ProductPrice> priceBox;
  Box<PriceAlert> alertBox;
  Box<SearchHistory> historyBox;
  
  Future<void> initialize();
  Future<List<ProductPrice>> getPricesPaginated(int page, int pageSize);
  Future<List<ProductPrice>> searchProducts(String query);
  Future<void> compactDatabase();
  Future<void> cleanOldEntries(int maxEntries);
  Future<void> createIndexes();
}
```

**Stratégies d'Optimisation**:

1. **Indexation**:
   - Créer des index sur `productName`, `storeName`, `date`
   - Utiliser `HiveList` pour les relations

2. **Pagination**:
   - Charger par lots de 50 éléments
   - Utiliser `skip()` et `take()` sur les requêtes

3. **Lazy Loading**:
   - Charger uniquement les données visibles à l'écran
   - Utiliser `ListView.builder` avec chargement à la demande

4. **Compaction**:
   - Déclencher `compact()` quand la taille > 50MB
   - Exécuter en arrière-plan avec `compute()`

5. **Nettoyage**:
   - Garder maximum 1000 entrées par type
   - Supprimer les plus anciennes avec tri par date

### 9. Système de Cache

#### CacheManager

```dart
class CacheManager {
  Map<String, CacheEntry> cache;
  int maxSizeBytes;
  
  T? get<T>(String key);
  void set<T>(String key, T value, Duration ttl);
  void invalidate(String key);
  void invalidatePattern(String pattern);
  void clear();
  void evictLRU();
}

class CacheEntry {
  dynamic value;
  DateTime createdAt;
  DateTime expiresAt;
  int accessCount;
  DateTime lastAccessedAt;
  int sizeBytes;
}
```

**Politique de Cache**:

1. **TTL (Time To Live)**:
   - Produits populaires: 5 minutes
   - Résultats de recherche: 5 minutes
   - Statistiques: 10 minutes

2. **Éviction LRU**:
   - Trier par `lastAccessedAt`
   - Supprimer les entrées les moins récemment utilisées
   - Déclencher quand taille > 10MB

3. **Invalidation**:
   - Invalider lors de modifications de données
   - Invalider par pattern (ex: `product:*` pour tous les produits)

### 10. Système d'Export

#### ExportService

```dart
class ExportService {
  Future<File> exportToCSV(List<ProductPrice> prices);
  Future<File> exportToPDF(List<ProductPrice> prices, ExportOptions options);
  Future<File> exportToExcel(List<ProductPrice> prices);
  Future<String> generateShareableJSON(List<ProductPrice> prices);
}

class ExportOptions {
  bool includeCharts;
  bool includeStatistics;
  DateRange? dateRange;
  List<String>? categories;
}
```

**Formats d'Export**:

1. **CSV**:
   - Colonnes: Date, Produit, Magasin, Prix, Catégorie
   - Encodage: UTF-8 avec BOM
   - Séparateur: virgule

2. **PDF**:
   - En-tête avec logo et titre
   - Tableau formaté avec les données
   - Graphiques de comparaison (si activé)
   - Section statistiques (si activé)
   - Pied de page avec date de génération

3. **Excel**:
   - Feuille "Données" avec tableau
   - Feuille "Statistiques" avec résumés
   - Feuille "Graphiques" avec visualisations
   - Formatage conditionnel (prix min en vert, max en rouge)

### 11. Générateur de Rapports

#### ReportGenerator

```dart
class ReportGenerator {
  Future<File> generateComparisonReport(ReportConfig config);
  Future<pw.Document> buildPDFDocument(ReportData data);
  List<charts.Series> buildChartData(ReportData data);
}

class ReportConfig {
  List<String> productNames;
  DateRange dateRange;
  bool includeCharts;
  bool includeStatistics;
}

class ReportData {
  List<ProductPrice> prices;
  Map<String, Statistics> statisticsByProduct;
  Map<String, List<ProductPrice>> pricesByStore;
  double totalPotentialSavings;
}
```

**Structure du Rapport**:

1. **Page de Garde**:
   - Titre: "Rapport de Comparaison de Prix"
   - Date de génération
   - Période couverte
   - Nombre de produits analysés

2. **Résumé Exécutif**:
   - Économie totale potentielle
   - Magasin le plus économique
   - Magasin le plus cher
   - Nombre de produits comparés

3. **Détails par Produit**:
   - Nom du produit
   - Tableau des prix par magasin
   - Graphique de comparaison
   - Statistiques (moyenne, médiane, écart-type)

4. **Graphiques Globaux**:
   - Graphique en barres: Prix moyen par magasin
   - Graphique circulaire: Répartition des économies

### 12. Système d'Onboarding

#### OnboardingManager

```dart
class OnboardingManager {
  bool isFirstLaunch;
  Set<String> viewedTooltips;
  
  Future<bool> shouldShowOnboarding();
  Future<void> markOnboardingComplete();
  bool shouldShowTooltip(String tooltipId);
  Future<void> markTooltipViewed(String tooltipId);
}

class OnboardingScreen extends StatefulWidget {
  final List<OnboardingPage> pages;
}

class OnboardingPage {
  String title;
  String description;
  String imagePath;
  Color backgroundColor;
}
```

**Pages d'Onboarding**:

1. **Page 1**: "Bienvenue sur PrixIvoire"
   - Description: Comparez les prix facilement
   - Image: Illustration de comparaison

2. **Page 2**: "Ajoutez vos prix"
   - Description: Saisissez manuellement ou scannez vos tickets
   - Image: Illustration de scan

3. **Page 3**: "Analysez et économisez"
   - Description: Visualisez les tendances et trouvez les meilleures offres
   - Image: Illustration de graphiques

4. **Page 4**: "Partagez vos données"
   - Description: Exportez et partagez vos comparaisons
   - Image: Illustration de partage

### 13. Système de Validation

#### ValidationService

```dart
class ValidationService {
  ValidationResult validatePrice(String input);
  ValidationResult validateProductName(String input);
  ValidationResult validateStoreName(String input);
}

class ValidationResult {
  bool isValid;
  String? errorMessage;
  
  static ValidationResult success();
  static ValidationResult error(String message);
}
```

**Règles de Validation**:

1. **Prix**:
   - Doit être un nombre
   - Doit être positif
   - Maximum: 10 000 000 FCFA (avec avertissement)
   - Décimales: maximum 2

2. **Nom de Produit**:
   - Non vide
   - Minimum 2 caractères
   - Maximum 100 caractères
   - Caractères autorisés: lettres, chiffres, espaces, tirets

3. **Nom de Magasin**:
   - Non vide
   - Minimum 2 caractères
   - Maximum 50 caractères

## Modèles de Données

### ProductPrice (Modèle Existant Amélioré)

```dart
@HiveType(typeId: 0)
class ProductPrice extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String productName;
  
  @HiveField(2)
  double price;
  
  @HiveField(3)
  String storeName;
  
  @HiveField(4)
  DateTime date;
  
  @HiveField(5)
  String? categoryId;  // NOUVEAU
  
  @HiveField(6)
  bool isFavorite;  // NOUVEAU
  
  @HiveField(7)
  String? notes;  // NOUVEAU
  
  @HiveField(8)
  String? imageUrl;  // NOUVEAU (pour référence au scan)
}
```

### Category (Nouveau Modèle)

```dart
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
```

### Statistics (Nouveau Modèle)

```dart
class Statistics {
  final double mean;
  final double median;
  final double standardDeviation;
  final double min;
  final double max;
  final String minStore;
  final String maxStore;
  final int sampleSize;
  final double potentialSavings;
  
  Statistics({
    required this.mean,
    required this.median,
    required this.standardDeviation,
    required this.min,
    required this.max,
    required this.minStore,
    required this.maxStore,
    required this.sampleSize,
    required this.potentialSavings,
  });
}
```

### AppSettings (Nouveau Modèle)

```dart
@HiveType(typeId: 10)
class AppSettings extends HiveObject {
  @HiveField(0)
  String themeMode;  // 'light', 'dark', 'system'
  
  @HiveField(1)
  bool onboardingCompleted;
  
  @HiveField(2)
  List<String> viewedTooltips;
  
  @HiveField(3)
  String defaultCurrency;
  
  @HiveField(4)
  int maxHistoryEntries;
  
  @HiveField(5)
  bool enableNotifications;
}
```

## Gestion d'Erreurs

### Hiérarchie d'Erreurs

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  AppException(this.message, {this.code, this.originalError});
}

class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class OCRException extends AppException {
  OCRException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  
  ValidationException(String message, this.fieldErrors)
      : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ExportException extends AppException {
  ExportException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}
```

### ErrorHandler

```dart
class ErrorHandler {
  static String getUserFriendlyMessage(Exception error) {
    if (error is StorageException) {
      return _getStorageErrorMessage(error);
    } else if (error is OCRException) {
      return _getOCRErrorMessage(error);
    } else if (error is ValidationException) {
      return _getValidationErrorMessage(error);
    } else if (error is NetworkException) {
      return "Erreur de connexion. Vérifiez votre connexion internet.";
    } else if (error is ExportException) {
      return "Erreur lors de l'export. Vérifiez l'espace de stockage disponible.";
    }
    return "Une erreur inattendue s'est produite.";
  }
  
  static String _getStorageErrorMessage(StorageException error) {
    if (error.code == 'STORAGE_FULL') {
      return "Espace de stockage insuffisant. Supprimez des anciennes données.";
    } else if (error.code == 'PERMISSION_DENIED') {
      return "Permission refusée. Vérifiez les autorisations de l'application.";
    }
    return "Erreur de stockage: ${error.message}";
  }
  
  static String _getOCRErrorMessage(OCRException error) {
    if (error.code == 'NO_TEXT_FOUND') {
      return "Aucun texte détecté. Assurez-vous que l'image est claire et bien éclairée.";
    } else if (error.code == 'POOR_QUALITY') {
      return "Qualité d'image insuffisante. Essayez avec une meilleure photo.";
    }
    return "Erreur de reconnaissance: ${error.message}";
  }
  
  static String _getValidationErrorMessage(ValidationException error) {
    return error.fieldErrors.values.first;
  }
  
  static void logError(Exception error, StackTrace stackTrace) {
    // Log vers console en développement
    print('ERROR: $error');
    print('STACK: $stackTrace');
    
    // En production, envoyer vers un service de logging (Firebase Crashlytics, Sentry, etc.)
  }
}
```

### Try-Catch Wrapper

```dart
class SafeExecutor {
  static Future<T?> execute<T>({
    required Future<T> Function() action,
    required BuildContext context,
    String? successMessage,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      // Afficher loading indicator
    }
    
    try {
      final result = await action();
      
      if (showLoading) {
        // Cacher loading indicator
      }
      
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
      
      return result;
    } catch (error, stackTrace) {
      if (showLoading) {
        // Cacher loading indicator
      }
      
      ErrorHandler.logError(error as Exception, stackTrace);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(error as Exception)),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: () => execute(action: action, context: context),
          ),
        ),
      );
      
      return null;
    }
  }
}
```

