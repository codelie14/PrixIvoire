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



## Propriétés de Correction

Une propriété est une caractéristique ou un comportement qui doit être vrai pour toutes les exécutions valides d'un système - essentiellement, une déclaration formelle sur ce que le système devrait faire. Les propriétés servent de pont entre les spécifications lisibles par l'homme et les garanties de correction vérifiables par machine.

### Réflexion sur les Propriétés

Après analyse des critères d'acceptation, plusieurs propriétés peuvent être combinées ou sont redondantes :

- **2.2 et 2.3** : La persistance du thème et son chargement au démarrage peuvent être testés ensemble via un round-trip
- **4.3 et 7.3** : Le filtrage par catégorie est mentionné deux fois, une seule propriété suffit
- **9.5 et 11.5** : La gestion d'erreur OCR est mentionnée deux fois
- **6.1, 6.2, 6.3, 6.4, 6.6** : Les calculs statistiques peuvent être regroupés en une propriété de correction des calculs

### Propriétés Testables

#### Propriété 1: Persistance du Thème (Round-Trip)
*Pour tout* mode de thème sélectionné (clair, sombre, système), sauvegarder le thème puis redémarrer l'application devrait restaurer le même mode de thème.
**Valide: Exigences 2.2, 2.3**

#### Propriété 2: Performance des Transitions
*Pour toute* navigation entre écrans, la durée de la transition d'animation ne devrait pas dépasser 300ms.
**Valide: Exigences 1.2**

#### Propriété 3: Application Complète du Thème
*Pour tout* changement de thème, tous les widgets visibles devraient refléter le nouveau thème sans nécessiter de redémarrage de l'application.
**Valide: Exigences 1.3**

#### Propriété 4: Conformité WCAG pour les Contrastes
*Pour toute* paire de couleurs (texte/fond) dans l'application, le ratio de contraste devrait respecter le niveau AA de WCAG 2.1 (minimum 4.5:1 pour le texte normal, 3:1 pour le texte large).
**Valide: Exigences 1.5**

#### Propriété 5: Labels Sémantiques pour l'Accessibilité
*Pour tout* widget interactif (boutons, champs de saisie, liens), un label sémantique devrait être défini pour les lecteurs d'écran.
**Valide: Exigences 1.6**

#### Propriété 6: Performance du Changement de Thème
*Pour tout* changement de thème, la mise à jour visuelle devrait être complétée en moins de 100ms.
**Valide: Exigences 2.5**

#### Propriété 7: Suggestions d'Autocomplétion
*Pour toute* requête d'au moins 2 caractères dans un champ produit ou magasin, si des correspondances existent dans l'historique, une liste de suggestions devrait être retournée.
**Valide: Exigences 3.1**

#### Propriété 8: Remplissage Automatique par Suggestion
*Pour toute* suggestion sélectionnée dans la liste d'autocomplétion, le champ devrait être automatiquement rempli avec la valeur exacte de la suggestion.
**Valide: Exigences 3.2**

#### Propriété 9: Tri des Suggestions par Fréquence
*Pour toute* liste de suggestions d'autocomplétion, les suggestions devraient être triées par ordre décroissant de fréquence d'utilisation.
**Valide: Exigences 3.3**

#### Propriété 10: Limite des Suggestions
*Pour toute* requête d'autocomplétion, le nombre de suggestions retournées ne devrait jamais dépasser 10.
**Valide: Exigences 3.5**

#### Propriété 11: Filtrage par Catégorie
*Pour toute* catégorie sélectionnée, le filtrage devrait retourner uniquement les produits appartenant à cette catégorie.
**Valide: Exigences 4.3**

#### Propriété 12: Comptage par Catégorie
*Pour toute* catégorie, le nombre affiché de produits devrait correspondre exactement au nombre de produits ayant cette catégorie dans la base de données.
**Valide: Exigences 4.5**

#### Propriété 13: Correction des Calculs Statistiques
*Pour tout* ensemble de prix d'un produit :
- La moyenne devrait être égale à la somme des prix divisée par le nombre de prix
- La médiane devrait être la valeur centrale (ou moyenne des deux centrales) après tri
- L'écart-type devrait être calculé selon la formule : sqrt(sum((x - mean)^2) / n)
- Le minimum et maximum devraient correspondre aux valeurs extrêmes
- L'économie potentielle devrait être égale à (max - min)
**Valide: Exigences 6.1, 6.2, 6.3, 6.4, 6.6**

#### Propriété 14: Filtrage par Période
*Pour toute* plage de dates sélectionnée, le filtrage devrait retourner uniquement les prix dont la date est comprise entre la date de début et la date de fin (incluses).
**Valide: Exigences 7.1**

#### Propriété 15: Filtrage par Fourchette de Prix
*Pour toute* fourchette de prix (min, max), le filtrage devrait retourner uniquement les prix compris entre min et max (inclus).
**Valide: Exigences 7.2**

#### Propriété 16: Filtrage par Magasin
*Pour tout* nom de magasin sélectionné, le filtrage devrait retourner uniquement les prix provenant de ce magasin.
**Valide: Exigences 7.4**

#### Propriété 17: Combinaison de Filtres (ET Logique)
*Pour tout* ensemble de filtres appliqués simultanément (date, prix, catégorie, magasin), un prix devrait être inclus dans les résultats si et seulement si il satisfait TOUS les filtres actifs.
**Valide: Exigences 7.5**

#### Propriété 18: Performance du Filtrage
*Pour toute* application de filtres sur une base de données de moins de 10 000 entrées, les résultats devraient être retournés en moins de 500ms.
**Valide: Exigences 7.6**

#### Propriété 19: Comptage des Résultats Filtrés
*Pour tout* ensemble de filtres appliqués, le nombre affiché de résultats devrait correspondre exactement au nombre d'entrées satisfaisant les filtres.
**Valide: Exigences 7.7**

#### Propriété 20: Persistance des Favoris (Round-Trip)
*Pour tout* produit ajouté aux favoris, sauvegarder puis recharger l'application devrait conserver ce produit dans la liste des favoris.
**Valide: Exigences 8.2**

#### Propriété 21: Suppression des Favoris
*Pour tout* produit retiré des favoris, ce produit ne devrait plus apparaître dans la liste des favoris immédiatement après la suppression.
**Valide: Exigences 8.4**

#### Propriété 22: Récupération du Dernier Prix pour les Favoris
*Pour tout* produit dans la liste des favoris, le prix affiché devrait correspondre au prix le plus récent (date maximale) enregistré pour ce produit.
**Valide: Exigences 8.5**

#### Propriété 23: Prétraitement d'Image OCR
*Pour toute* image soumise à l'OCR, l'image devrait subir un prétraitement (ajustement contraste, luminosité, rotation) avant l'extraction de texte.
**Valide: Exigences 9.1**

#### Propriété 24: Performance de l'OCR
*Pour toute* image standard (< 5MB), le traitement OCR complet devrait être terminé en moins de 5 secondes.
**Valide: Exigences 9.3**

#### Propriété 25: Extraction de Paires Produit-Prix
*Pour tout* texte détecté par l'OCR contenant des motifs produit-prix, l'application devrait extraire correctement les paires en utilisant une expression régulière appropriée.
**Valide: Exigences 9.4**

#### Propriété 26: Performance de Recherche
*Pour toute* recherche dans une base de données de moins de 10 000 entrées, les résultats devraient être retournés en moins de 200ms.
**Valide: Exigences 10.2**

#### Propriété 27: Pagination des Listes
*Pour toute* liste contenant plus de 50 éléments, la pagination devrait être activée et charger les éléments par lots de 50.
**Valide: Exigences 10.3**

#### Propriété 28: Lazy Loading au Démarrage
*Pour tout* démarrage de l'application, seules les données nécessaires à l'affichage de l'écran d'accueil devraient être chargées initialement.
**Valide: Exigences 10.4**

#### Propriété 29: Limite de l'Historique
*Pour tout* type de données (prix, alertes, historique), le nombre d'entrées stockées ne devrait jamais dépasser 1000, les plus anciennes étant supprimées en premier.
**Valide: Exigences 10.6**

#### Propriété 30: Messages d'Erreur en Français
*Pour toute* erreur survenant dans l'application, le message d'erreur affiché à l'utilisateur devrait être en français.
**Valide: Exigences 11.1**

#### Propriété 31: Logging des Erreurs
*Pour toute* opération qui échoue, une entrée de log devrait être créée contenant le message d'erreur, le stack trace, et le timestamp.
**Valide: Exigences 11.2**

#### Propriété 32: Cache des Produits Populaires
*Pour tout* moment donné, les 50 produits les plus consultés devraient être disponibles dans le cache.
**Valide: Exigences 12.1**

#### Propriété 33: TTL du Cache de Recherche
*Pour tout* résultat de recherche mis en cache, il devrait expirer et être invalidé après 5 minutes.
**Valide: Exigences 12.2**

#### Propriété 34: Performance du Cache
*Pour toute* donnée disponible dans le cache, l'accès devrait prendre moins de 50ms.
**Valide: Exigences 12.3**

#### Propriété 35: Éviction LRU du Cache
*Pour tout* cache atteignant 10MB, les entrées les moins récemment utilisées devraient être supprimées en premier jusqu'à ce que la taille soit réduite.
**Valide: Exigences 12.4**

#### Propriété 36: Invalidation du Cache lors de Modifications
*Pour toute* modification de données (ajout, mise à jour, suppression), les entrées de cache correspondantes devraient être invalidées immédiatement.
**Valide: Exigences 12.5**

#### Propriété 37: Vidage Manuel du Cache
*Pour toute* action de vidage manuel du cache par l'utilisateur, toutes les entrées du cache devraient être supprimées.
**Valide: Exigences 12.6**

#### Propriété 38: Export CSV Valide
*Pour tout* ensemble de données exporté en CSV, le fichier généré devrait être un CSV valide avec encodage UTF-8 et séparateur virgule.
**Valide: Exigences 13.1**

#### Propriété 39: Export PDF Valide
*Pour tout* ensemble de données exporté en PDF, le fichier généré devrait être un PDF valide et lisible.
**Valide: Exigences 13.2**

#### Propriété 40: Export Excel Valide
*Pour tout* ensemble de données exporté en Excel sur une plateforme supportée, le fichier généré devrait être un fichier XLSX valide.
**Valide: Exigences 13.3**

#### Propriété 41: Métadonnées dans les Exports
*Pour tout* fichier exporté (CSV, PDF, Excel), les métadonnées (date d'export, nombre d'entrées) devraient être incluses.
**Valide: Exigences 13.6**

#### Propriété 42: Génération de JSON pour Partage
*Pour tout* ensemble de prix partagé, un fichier JSON valide devrait être généré contenant toutes les données sélectionnées.
**Valide: Exigences 14.2**

#### Propriété 43: Détection de Doublons à l'Import
*Pour tout* import de données, si des doublons existent (même produit, même magasin, même date), ils devraient être détectés et signalés.
**Valide: Exigences 14.4**

#### Propriété 44: Génération de Rapport PDF
*Pour tout* ensemble de produits sélectionnés, un rapport PDF de comparaison devrait être généré avec succès.
**Valide: Exigences 15.1**

#### Propriété 45: Inclusion de Graphiques dans le Rapport
*Pour tout* rapport généré avec l'option "inclure graphiques", au moins un graphique de comparaison devrait être présent dans le PDF.
**Valide: Exigences 15.2**

#### Propriété 46: Calcul de l'Économie Totale dans le Rapport
*Pour tout* rapport généré, l'économie totale potentielle affichée devrait être égale à la somme des différences (max - min) pour chaque produit.
**Valide: Exigences 15.3**

#### Propriété 47: Inclusion des Statistiques dans le Rapport
*Pour tout* rapport généré, un résumé statistique (moyenne, médiane, écart-type) devrait être inclus pour chaque produit.
**Valide: Exigences 15.5**

#### Propriété 48: Marquage de Complétion de l'Onboarding
*Pour tout* utilisateur qui complète l'onboarding, un flag devrait être persisté localement indiquant que l'onboarding a été complété.
**Valide: Exigences 16.3**

#### Propriété 49: Persistance de l'État "Aide Vue"
*Pour toute* aide contextuelle consultée, l'état "vue" devrait être persisté et l'aide ne devrait plus s'afficher automatiquement lors des prochaines visites.
**Valide: Exigences 17.5**

#### Propriété 50: Fonctionnalité d'Annulation
*Pour toute* action récente (création, modification, suppression), l'utilisateur devrait pouvoir annuler l'action dans les 5 secondes suivant son exécution.
**Valide: Exigences 18.6**

#### Propriété 51: Validation des Prix
*Pour toute* saisie de prix, la validation devrait rejeter les valeurs non numériques, négatives ou nulles.
**Valide: Exigences 19.1**

#### Propriété 52: Validation des Noms de Produits
*Pour toute* saisie de nom de produit, la validation devrait rejeter les chaînes vides ou contenant moins de 2 caractères.
**Valide: Exigences 19.2**

#### Propriété 53: Validation des Noms de Magasins
*Pour toute* saisie de nom de magasin, la validation devrait rejeter les chaînes vides.
**Valide: Exigences 19.3**

#### Propriété 54: Blocage de Soumission avec Erreurs
*Pour tout* formulaire contenant des erreurs de validation, le bouton de soumission devrait être désactivé ou la soumission devrait être bloquée.
**Valide: Exigences 19.6**

### Cas Limites et Exemples Spécifiques

#### Exemple 1: Thème par Défaut au Premier Lancement
Au premier lancement de l'application, si le système d'exploitation a un thème défini (clair ou sombre), l'application devrait utiliser ce thème par défaut.
**Valide: Exigences 2.4**

#### Exemple 2: Autocomplétion sans Résultats
Lorsqu'une requête d'autocomplétion ne correspond à aucune entrée dans l'historique, l'utilisateur devrait pouvoir continuer la saisie libre sans restriction.
**Valide: Exigences 3.4**

#### Exemple 3: Catégorie par Défaut
Lorsqu'un produit n'a pas de catégorie assignée (categoryId est null), il devrait être affiché dans la catégorie "Autres".
**Valide: Exigences 4.4**

#### Cas Limite 1: Graphique avec Données Insuffisantes
Lorsque moins de 2 points de données sont disponibles pour un graphique, un message explicatif devrait être affiché au lieu d'un graphique vide.
**Valide: Exigences 5.6**

#### Exemple 4: Erreur OCR sans Texte
Lorsque l'OCR ne détecte aucun texte dans une image, un message d'erreur explicatif avec des suggestions d'amélioration (meilleur éclairage, recadrage) devrait être affiché.
**Valide: Exigences 9.5**

#### Exemple 5: Compaction de la Base de Données
Lorsque la taille de la base de données Hive dépasse 50MB, une opération de compaction devrait être déclenchée automatiquement.
**Valide: Exigences 10.5**

#### Exemple 6: Erreur Réseau
Lorsqu'une erreur réseau survient, un message spécifique devrait être affiché avec une option "Réessayer".
**Valide: Exigences 11.3**

#### Exemple 7: Stockage Plein
Lorsque le stockage est plein, un message devrait informer l'utilisateur et proposer de nettoyer les anciennes données.
**Valide: Exigences 11.4**

#### Exemple 8: Premier Lancement - Onboarding
Au premier lancement de l'application (flag onboardingCompleted = false), l'écran d'onboarding avec 3-5 slides devrait être affiché.
**Valide: Exigences 16.1**

#### Cas Limite 2: Avertissement Prix Élevé
Lorsqu'un utilisateur saisit un prix supérieur à 10 000 000 FCFA, un avertissement de confirmation devrait être affiché avant d'accepter la valeur.
**Valide: Exigences 19.7**

## Stratégie de Test

### Approche Duale de Test

L'application PrixIvoire utilisera une approche combinant tests unitaires et tests basés sur les propriétés (Property-Based Testing) pour assurer une couverture complète et une robustesse maximale.

#### Tests Unitaires

Les tests unitaires se concentrent sur :
- **Exemples spécifiques** : Cas d'usage concrets et scénarios réels
- **Cas limites** : Valeurs extrêmes, données vides, valeurs nulles
- **Conditions d'erreur** : Gestion des exceptions et erreurs
- **Points d'intégration** : Interactions entre composants

**Exemples de tests unitaires** :
- Tester que l'ajout d'un produit avec un prix de 1000 FCFA fonctionne correctement
- Tester que la suppression d'un favori met à jour la liste
- Tester que l'import d'un fichier JSON invalide génère une erreur appropriée
- Tester que le premier lancement affiche l'onboarding

#### Tests Basés sur les Propriétés (Property-Based Testing)

Les tests de propriétés vérifient des invariants universels sur de nombreuses entrées générées aléatoirement.

**Bibliothèque** : Nous utiliserons le package `faker` pour la génération de données et créerons un framework de PBT personnalisé pour Flutter/Dart.

**Configuration** :
- Minimum 100 itérations par test de propriété
- Génération aléatoire de données avec contraintes appropriées
- Shrinking automatique pour trouver le cas minimal d'échec

**Format de Tag** :
Chaque test de propriété doit inclure un commentaire de référence :
```dart
// Feature: prixivoire-complete-implementation, Property 13: Correction des Calculs Statistiques
test('Statistics calculations are correct for any set of prices', () {
  // Test implementation
});
```

**Exemples de tests de propriétés** :
- Pour tout ensemble de prix, la moyenne calculée devrait être correcte
- Pour toute requête d'autocomplétion, le nombre de suggestions ne devrait jamais dépasser 10
- Pour tout filtrage par catégorie, seuls les produits de cette catégorie devraient être retournés
- Pour tout export CSV, le fichier devrait être un CSV valide

### Équilibre des Tests

**Éviter trop de tests unitaires** : Les tests de propriétés couvrent déjà de nombreux cas d'entrée. Les tests unitaires doivent se concentrer sur :
- Les exemples qui illustrent clairement le comportement attendu
- Les cas limites spécifiques non couverts par les propriétés
- Les scénarios d'intégration complexes

**Complémentarité** :
- Tests unitaires : Validation de cas concrets et d'intégrations
- Tests de propriétés : Validation de règles universelles et de robustesse

### Couverture de Test

**Objectifs de couverture** :
- Modèles de données : 80% minimum
- Services : 80% minimum
- Widgets : Tests pour tous les écrans principaux
- Intégration : Tests pour les flux critiques (ajout de prix, scan OCR, export)

**Flux critiques à tester** :
1. Ajout manuel d'un prix → Sauvegarde → Récupération
2. Scan OCR → Extraction → Correction → Sauvegarde
3. Filtrage multi-critères → Affichage des résultats
4. Export CSV/PDF → Génération → Validation du fichier
5. Changement de thème → Persistance → Rechargement

### Organisation des Tests

```
test/
├── unit/
│   ├── models/
│   │   ├── product_price_test.dart
│   │   ├── statistics_test.dart
│   │   └── app_settings_test.dart
│   ├── services/
│   │   ├── storage_service_test.dart
│   │   ├── ocr_service_test.dart
│   │   ├── cache_manager_test.dart
│   │   ├── export_service_test.dart
│   │   └── statistics_engine_test.dart
│   └── utils/
│       ├── validation_service_test.dart
│       └── error_handler_test.dart
├── property/
│   ├── statistics_properties_test.dart
│   ├── filtering_properties_test.dart
│   ├── autocomplete_properties_test.dart
│   ├── validation_properties_test.dart
│   └── cache_properties_test.dart
├── widget/
│   ├── home_screen_test.dart
│   ├── add_price_screen_test.dart
│   ├── comparison_screen_test.dart
│   └── trends_screen_test.dart
└── integration/
    ├── add_price_flow_test.dart
    ├── ocr_scan_flow_test.dart
    ├── export_flow_test.dart
    └── theme_persistence_flow_test.dart
```

### Mocks et Dépendances

**Stratégie de Mocking** :
- Utiliser `mockito` pour créer des mocks des services
- Isoler les dépendances externes (Hive, OCR, système de fichiers)
- Créer des fixtures pour les données de test

**Exemples de mocks nécessaires** :
- `MockStorageService` : Pour tester sans accès réel à Hive
- `MockOCRService` : Pour tester sans traitement d'image réel
- `MockFileSystem` : Pour tester l'export sans écriture réelle de fichiers

### Performance des Tests

**Objectif** : Suite de tests complète en moins de 5 minutes

**Optimisations** :
- Parallélisation des tests indépendants
- Utilisation de mocks pour éviter les opérations I/O lentes
- Tests de propriétés avec 100 itérations (équilibre entre couverture et vitesse)
- Tests d'intégration ciblés sur les flux critiques uniquement

### Intégration Continue

**Pipeline CI/CD** :
1. Linting et formatage du code
2. Analyse statique (dart analyze)
3. Tests unitaires
4. Tests de propriétés
5. Tests de widgets
6. Tests d'intégration
7. Rapport de couverture

**Seuils de qualité** :
- Couverture minimale : 80%
- Aucun warning d'analyse statique
- Tous les tests doivent passer

## Notes d'Implémentation

### Priorités de Développement

1. **Phase 1 - Fondations** :
   - Système de thèmes
   - Optimisation du stockage Hive
   - Gestion d'erreurs robuste
   - Validation des données

2. **Phase 2 - Fonctionnalités Avancées** :
   - Autocomplétion
   - Système de catégories
   - Filtres avancés
   - Système de favoris

3. **Phase 3 - Analyse et Visualisation** :
   - Moteur de statistiques
   - Graphiques améliorés
   - Système de cache

4. **Phase 4 - OCR et Performance** :
   - Optimisation OCR
   - Prétraitement d'images
   - Performance de recherche

5. **Phase 5 - Export et Partage** :
   - Export multi-formats
   - Génération de rapports
   - Partage de données

6. **Phase 6 - Expérience Utilisateur** :
   - Onboarding
   - Aide contextuelle
   - Feedback utilisateur amélioré

### Considérations Techniques

**Performance** :
- Utiliser `compute()` pour les opérations lourdes (OCR, statistiques sur grands ensembles)
- Implémenter le lazy loading avec `ListView.builder`
- Optimiser les requêtes Hive avec des index appropriés
- Utiliser `const` constructors pour les widgets statiques

**Accessibilité** :
- Définir `semanticsLabel` pour tous les widgets interactifs
- Supporter la navigation au clavier
- Tester avec TalkBack (Android) et VoiceOver (iOS)
- Respecter les tailles de police système

**Internationalisation** :
- Préparer l'architecture pour le support multi-langues (même si initialement en français)
- Utiliser le package `intl` pour les formats de date et nombres
- Externaliser toutes les chaînes de caractères

**Sécurité** :
- Valider toutes les entrées utilisateur
- Sanitiser les données avant l'export
- Gérer les permissions de manière appropriée (stockage, caméra)
- Ne pas logger d'informations sensibles

**Maintenabilité** :
- Suivre les principes SOLID
- Documenter les fonctions complexes
- Utiliser des noms de variables descriptifs
- Maintenir une architecture en couches claire

