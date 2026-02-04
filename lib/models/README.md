# Modèles de Données - PrixIvoire

Ce dossier contient tous les modèles de données utilisés dans l'application PrixIvoire.

## Modèles Implémentés

### ProductPrice (Étendu)
**Fichier**: `product_price.dart`

Modèle principal représentant un prix de produit avec les champs suivants:
- `productName`: Nom du produit
- `price`: Prix en FCFA
- `shop`: Nom du magasin
- `date`: Date de saisie
- `categoryId`: ID de la catégorie (nouveau)
- `isFavorite`: Indicateur de favori (nouveau)
- `notes`: Notes optionnelles (nouveau)
- `imageUrl`: Référence à l'image du ticket (nouveau)

**Adaptateur Hive**: `../adapters/product_price_adapter.dart` (typeId: 0)
- Support de la migration des données existantes
- Compatibilité ascendante avec les anciennes versions

### Category
**Fichier**: `category.dart`

Modèle représentant une catégorie de produit avec:
- `id`: Identifiant unique
- `name`: Nom de la catégorie
- `icon`: Icône Material
- `color`: Couleur associée

**Catégories prédéfinies**:
1. Alimentaire (food) - Vert
2. Électronique (electronics) - Bleu
3. Hygiène (hygiene) - Violet
4. Vêtements (clothing) - Orange
5. Maison (home) - Marron
6. Autres (other) - Gris bleu

**Méthodes utilitaires**:
- `getCategoryById()`: Récupère une catégorie par ID
- `getDefaultCategory()`: Retourne la catégorie "Autres"
- `getCategoryByIdOrDefault()`: Récupère une catégorie ou retourne "Autres"

### AppSettings
**Fichier**: `app_settings.dart`

Modèle pour les paramètres de l'application:
- `themeMode`: Mode de thème ('light', 'dark', 'system')
- `onboardingCompleted`: Indicateur de complétion de l'onboarding
- `viewedTooltips`: Liste des tooltips vus
- `defaultCurrency`: Devise par défaut (FCFA)
- `maxHistoryEntries`: Nombre maximum d'entrées d'historique
- `enableNotifications`: Activation des notifications

**Adaptateur Hive**: `../adapters/app_settings_adapter.dart` (typeId: 10)

**Méthodes utilitaires**:
- `markOnboardingComplete()`: Marque l'onboarding comme complété
- `markTooltipViewed()`: Marque un tooltip comme vu
- `hasViewedTooltip()`: Vérifie si un tooltip a été vu
- `updateThemeMode()`: Met à jour le mode de thème

### Statistics
**Fichier**: `statistics.dart`

Modèle pour les statistiques calculées sur un ensemble de prix:
- `mean`: Moyenne des prix
- `median`: Médiane des prix
- `standardDeviation`: Écart-type
- `min`: Prix minimum
- `max`: Prix maximum
- `minStore`: Magasin avec le prix minimum
- `maxStore`: Magasin avec le prix maximum
- `sampleSize`: Nombre de prix dans l'échantillon
- `potentialSavings`: Économie potentielle (max - min)

**Propriétés calculées**:
- `isValid`: Vérifie si les statistiques sont valides
- `hasStandardDeviation`: Vérifie si l'écart-type est disponible
- `savingsPercentage`: Pourcentage d'économie potentielle

## Modèles Existants

### PriceAlert
**Fichier**: `price_alert.dart`
Modèle pour les alertes de prix (typeId: 1)

### SearchHistory
**Fichier**: `search_history.dart`
Modèle pour l'historique de recherche (typeId: 2)

### ScrapedProduct
**Fichier**: `scraped_product.dart`
Modèle pour les produits scrapés du web

## Migration des Données

Les adaptateurs Hive ont été mis à jour pour supporter la migration automatique:
- Les anciennes données ProductPrice seront automatiquement migrées
- Les nouveaux champs auront des valeurs par défaut appropriées
- Aucune perte de données lors de la mise à jour

## Utilisation

```dart
// Créer un nouveau prix avec catégorie
final price = ProductPrice(
  productName: 'Riz 25kg',
  price: 15000,
  shop: 'Carrefour',
  date: DateTime.now(),
  categoryId: 'food',
  isFavorite: true,
);

// Récupérer une catégorie
final category = Category.getCategoryById('food');

// Créer des paramètres par défaut
final settings = AppSettings.defaultSettings();

// Créer des statistiques
final stats = Statistics(
  mean: 12500,
  median: 12000,
  standardDeviation: 1500,
  min: 10000,
  max: 15000,
  minStore: 'Marché',
  maxStore: 'Supermarché',
  sampleSize: 10,
  potentialSavings: 5000,
);
```
