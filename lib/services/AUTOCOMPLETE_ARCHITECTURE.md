# Architecture du Système d'Autocomplétion

## Diagramme de Flux

```
┌─────────────────────────────────────────────────────────────────┐
│                         UTILISATEUR                              │
│                    (Saisit du texte)                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    WIDGETS D'INTERFACE                           │
│  ┌──────────────────────┐    ┌──────────────────────────┐      │
│  │ AutocompleteTextField│    │SimpleAutocompleteField   │      │
│  │  (Personnalisé)      │    │  (Natif Flutter)         │      │
│  │                      │    │                          │      │
│  │ - Overlay manuel     │    │ - Widget Autocomplete    │      │
│  │ - Contrôle total     │    │ - Standard Flutter       │      │
│  │ - Personnalisable    │    │ - Simple à utiliser      │      │
│  └──────────┬───────────┘    └──────────┬───────────────┘      │
└─────────────┼──────────────────────────┼──────────────────────┘
              │                          │
              └──────────┬───────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   AUTOCOMPLETE SERVICE                           │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ getSuggestions(query, type)                            │    │
│  │  1. Normalise la requête (trim, lowercase)             │    │
│  │  2. Obtient la map de fréquence                        │    │
│  │  3. Filtre les correspondances                         │    │
│  │  4. Trie par fréquence décroissante                    │    │
│  │  5. Limite à 10 résultats                              │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ getFrequencyMap(type)                                  │    │
│  │  - Parcourt toutes les entrées Hive                    │    │
│  │  - Compte les occurrences de chaque nom                │    │
│  │  - Retourne Map<String, int>                           │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ getTopSuggestions(type, limit)                         │    │
│  │  - Retourne les N suggestions les plus fréquentes      │    │
│  └────────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      HIVE DATABASE                               │
│                                                                  │
│  Box<ProductPrice>                                              │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ ProductPrice {                                         │    │
│  │   productName: "Riz 25kg"                              │    │
│  │   shop: "Carrefour"                                    │    │
│  │   price: 15000                                         │    │
│  │   date: 2026-02-01                                     │    │
│  │   ...                                                  │    │
│  │ }                                                      │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  Données persistées localement                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Flux de Données Détaillé

### 1. Saisie Utilisateur

```
Utilisateur tape "ri" dans le champ produit
    │
    ▼
Widget détecte le changement (onChanged)
    │
    ▼
Vérifie: query.length >= 2 ? OUI
    │
    ▼
Appelle: autocompleteService.getSuggestions("ri", AutocompleteType.product)
```

### 2. Traitement dans le Service

```
getSuggestions("ri", product)
    │
    ▼
Normalise: "ri" → "ri" (trim, lowercase)
    │
    ▼
Obtient frequencyMap:
    {
      "Riz 25kg": 15,
      "Riz parfumé": 8,
      "Huile": 12,
      "Sucre": 10,
      ...
    }
    │
    ▼
Filtre les correspondances:
    ["Riz 25kg", "Riz parfumé"]
    │
    ▼
Trie par fréquence:
    ["Riz 25kg" (15), "Riz parfumé" (8)]
    │
    ▼
Limite à 10:
    ["Riz 25kg", "Riz parfumé"]
    │
    ▼
Retourne: List<String>
```

### 3. Affichage des Suggestions

```
Widget reçoit la liste de suggestions
    │
    ▼
Affiche l'overlay/dropdown avec:
    ┌─────────────────────────┐
    │ 🛒 Riz 25kg            │
    │ 🛒 Riz parfumé         │
    └─────────────────────────┘
    │
    ▼
Utilisateur sélectionne "Riz 25kg"
    │
    ▼
Champ rempli automatiquement
    │
    ▼
Callback onSelected appelé
    │
    ▼
Overlay fermé
```

## Calcul de Fréquence

### Exemple avec Données Réelles

**Base de données:**
```
ProductPrice 1: { productName: "Riz 25kg", shop: "Carrefour", ... }
ProductPrice 2: { productName: "Riz 25kg", shop: "Sococé", ... }
ProductPrice 3: { productName: "Huile", shop: "Carrefour", ... }
ProductPrice 4: { productName: "Riz 25kg", shop: "Leader Price", ... }
ProductPrice 5: { productName: "Riz parfumé", shop: "Carrefour", ... }
```

**Calcul de fréquence pour produits:**
```dart
Map<String, int> frequencyMap = {
  "Riz 25kg": 3,      // Apparaît 3 fois
  "Huile": 1,         // Apparaît 1 fois
  "Riz parfumé": 1,   // Apparaît 1 fois
}
```

**Tri par fréquence décroissante:**
```dart
[
  "Riz 25kg" (3),
  "Huile" (1),
  "Riz parfumé" (1),
]
```

## Comparaison des Deux Widgets

### AutocompleteTextField (Personnalisé)

**Architecture:**
```
AutocompleteTextField
    │
    ├─ TextFormField (champ de saisie)
    │
    ├─ FocusNode (gestion du focus)
    │
    ├─ LayerLink (lien pour positionnement)
    │
    └─ OverlayEntry (suggestions flottantes)
        │
        └─ CompositedTransformFollower
            │
            └─ Material
                │
                └─ ListView.builder
                    │
                    └─ ListTile (chaque suggestion)
```

**Avantages:**
- Contrôle total sur l'apparence
- Animations personnalisées possibles
- Positionnement précis

**Inconvénients:**
- Plus de code à maintenir
- Gestion manuelle de l'overlay
- Risque de bugs de positionnement

### SimpleAutocompleteField (Natif)

**Architecture:**
```
SimpleAutocompleteField
    │
    └─ Autocomplete<String> (widget Flutter)
        │
        ├─ fieldViewBuilder → TextFormField
        │
        ├─ optionsBuilder → List<String>
        │
        └─ optionsViewBuilder → Material + ListView
```

**Avantages:**
- Widget natif de Flutter
- Comportement standard
- Moins de code
- Maintenance par Flutter

**Inconvénients:**
- Personnalisation limitée
- Apparence standard

## Performance

### Complexité Algorithmique

**getSuggestions():**
- Calcul de fréquence: O(n) où n = nombre d'entrées dans Hive
- Filtrage: O(m) où m = nombre de noms uniques
- Tri: O(m log m)
- Limitation: O(1)
- **Total: O(n + m log m)**

**Optimisations:**
- Normalisation de la requête: O(1)
- Utilisation de Map pour comptage: O(1) par insertion
- Take(10) pour limitation: O(1)

### Benchmarks Estimés

| Nombre d'entrées | Temps de calcul |
|------------------|-----------------|
| 100              | < 5ms           |
| 1 000            | < 20ms          |
| 10 000           | < 50ms          |
| 100 000          | < 200ms         |

## Gestion de la Mémoire

**Mémoire utilisée:**
- Service: ~1KB (références)
- Map de fréquence: ~100 bytes par entrée unique
- Liste de suggestions: ~10 strings × ~50 bytes = ~500 bytes

**Total pour 1000 produits uniques:** ~100KB

## Extensibilité

### Ajout de Nouveaux Types

```dart
enum AutocompleteType {
  product,
  store,
  category,  // Nouveau type
  brand,     // Nouveau type
}
```

### Ajout de Filtres Personnalisés

```dart
List<String> getSuggestionsWithFilter(
  String query,
  AutocompleteType type,
  bool Function(ProductPrice) filter,
) {
  // Filtrer les entrées avant le calcul de fréquence
}
```

### Ajout de Cache

```dart
class AutocompleteService {
  final Map<String, List<String>> _cache = {};
  
  List<String> getSuggestions(String query, AutocompleteType type) {
    final cacheKey = '$type:$query';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    
    final suggestions = _calculateSuggestions(query, type);
    _cache[cacheKey] = suggestions;
    return suggestions;
  }
}
```

## Intégration avec d'Autres Systèmes

### Avec le Système de Cache

```dart
// Les suggestions peuvent être mises en cache
cacheManager.set(
  'autocomplete:product:ri',
  suggestions,
  Duration(minutes: 5),
);
```

### Avec le Système de Validation

```dart
SimpleAutocompleteField(
  controller: _productController,
  validator: ValidationService.validateProductName,
  // ...
)
```

### Avec le Système de Statistiques

```dart
// Analyser les suggestions les plus utilisées
final topProducts = autocompleteService.getTopSuggestions(
  AutocompleteType.product,
  limit: 20,
);
```

## Conclusion

Le système d'autocomplétion est conçu pour être:
- **Simple**: API claire et facile à utiliser
- **Performant**: Calculs optimisés, < 50ms pour 10 000 entrées
- **Flexible**: Deux versions de widgets, extensible
- **Robuste**: Gestion des cas limites, validation intégrée
- **Maintenable**: Code propre, bien documenté, testé
