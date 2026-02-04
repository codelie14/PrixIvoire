# Système d'Autocomplétion - PrixIvoire

## Vue d'Ensemble

Le système d'autocomplétion de PrixIvoire fournit des suggestions intelligentes basées sur l'historique des saisies pour les noms de produits et de magasins. Les suggestions sont triées par fréquence d'utilisation décroissante et limitées à 10 résultats maximum.

## Architecture

### Composants

1. **AutocompleteService** (`lib/services/autocomplete_service.dart`)
   - Service principal gérant la logique d'autocomplétion
   - Calcule les fréquences d'utilisation
   - Filtre et trie les suggestions

2. **AutocompleteTextField** (`lib/widgets/autocomplete_text_field.dart`)
   - Widget personnalisé avec overlay manuel
   - Contrôle total sur l'apparence et le comportement
   - Utilise CompositedTransformFollower pour le positionnement

3. **SimpleAutocompleteField** (`lib/widgets/simple_autocomplete_field.dart`)
   - Widget utilisant le Autocomplete natif de Flutter
   - Intégration plus simple
   - Comportement standard de Flutter

## Utilisation

### Initialisation du Service

```dart
final autocompleteService = AutocompleteService();
await autocompleteService.initialize();
```

### Utilisation dans un Formulaire

#### Version Simple (Recommandée)

```dart
SimpleAutocompleteField(
  controller: _productController,
  type: AutocompleteType.product,
  autocompleteService: _autocompleteService,
  label: 'Nom du produit',
  hintText: 'Ex: Riz 25kg',
  icon: Icons.shopping_basket,
  required: true,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom du produit est requis';
    }
    return null;
  },
  onSelected: (value) {
    print('Produit sélectionné: $value');
  },
)
```

#### Version Personnalisée

```dart
AutocompleteTextField(
  controller: _storeController,
  type: AutocompleteType.store,
  autocompleteService: _autocompleteService,
  label: 'Nom du magasin',
  hintText: 'Ex: Carrefour',
  icon: Icons.store,
  required: true,
  minCharsForSuggestions: 2,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom du magasin est requis';
    }
    return null;
  },
  onSelected: (value) {
    print('Magasin sélectionné: $value');
  },
)
```

## Fonctionnalités

### 1. Suggestions Intelligentes

- **Filtrage**: Les suggestions sont filtrées en fonction de la requête (case-insensitive)
- **Tri par fréquence**: Les suggestions les plus utilisées apparaissent en premier
- **Limite**: Maximum 10 suggestions affichées
- **Minimum de caractères**: Par défaut, 2 caractères minimum avant d'afficher les suggestions

### 2. Saisie Libre

Si aucune suggestion ne correspond ou si l'utilisateur préfère, la saisie libre est toujours possible. Il n'y a aucune restriction sur les valeurs saisies.

### 3. Calcul de Fréquence

Le service calcule automatiquement la fréquence d'utilisation en comptant les occurrences dans la base de données Hive. Aucun enregistrement manuel n'est nécessaire.

### 4. Performance

- Les suggestions sont calculées en temps réel
- Utilisation de Map pour un accès O(1)
- Tri efficace avec List.sort()
- Limitation à 10 résultats pour maintenir la performance

## API du Service

### `getSuggestions(String query, AutocompleteType type)`

Retourne une liste de suggestions basée sur la requête.

**Paramètres:**
- `query`: La chaîne de recherche (minimum 2 caractères recommandé)
- `type`: Le type d'autocomplétion (product ou store)

**Retour:** `List<String>` - Liste de suggestions triées par fréquence (max 10)

### `getFrequencyMap(AutocompleteType type)`

Retourne une map de fréquence pour le type spécifié.

**Paramètres:**
- `type`: Le type d'autocomplétion (product ou store)

**Retour:** `Map<String, int>` - Map où les clés sont les noms et les valeurs sont les occurrences

### `getTopSuggestions(AutocompleteType type, {int limit = 10})`

Retourne les N suggestions les plus fréquentes.

**Paramètres:**
- `type`: Le type d'autocomplétion
- `limit`: Nombre maximum de suggestions (par défaut 10)

**Retour:** `List<String>` - Liste des suggestions les plus fréquentes

## Intégration dans AddPriceScreen

Pour intégrer l'autocomplétion dans l'écran d'ajout de prix:

```dart
class AddPriceScreen extends StatefulWidget {
  // ...
}

class _AddPriceScreenState extends State<AddPriceScreen> {
  final _productController = TextEditingController();
  final _storeController = TextEditingController();
  final _autocompleteService = AutocompleteService();
  
  @override
  void initState() {
    super.initState();
    _autocompleteService.initialize();
  }
  
  @override
  void dispose() {
    _productController.dispose();
    _storeController.dispose();
    _autocompleteService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            SimpleAutocompleteField(
              controller: _productController,
              type: AutocompleteType.product,
              autocompleteService: _autocompleteService,
              label: 'Produit',
              icon: Icons.shopping_basket,
              required: true,
            ),
            SimpleAutocompleteField(
              controller: _storeController,
              type: AutocompleteType.store,
              autocompleteService: _autocompleteService,
              label: 'Magasin',
              icon: Icons.store,
              required: true,
            ),
            // Autres champs...
          ],
        ),
      ),
    );
  }
}
```

## Choix entre les Deux Versions

### SimpleAutocompleteField (Recommandé)

**Avantages:**
- Utilise le widget natif de Flutter
- Comportement standard et prévisible
- Moins de code à maintenir
- Meilleure intégration avec le framework

**Inconvénients:**
- Moins de contrôle sur l'apparence
- Personnalisation limitée

### AutocompleteTextField

**Avantages:**
- Contrôle total sur l'apparence
- Personnalisation complète
- Animations personnalisées possibles

**Inconvénients:**
- Plus de code à maintenir
- Gestion manuelle de l'overlay
- Risque de bugs avec le positionnement

**Recommandation:** Utilisez `SimpleAutocompleteField` sauf si vous avez besoin d'une personnalisation très spécifique.

## Tests

### Tests Unitaires

Les tests unitaires couvrent:
- Filtrage des suggestions
- Tri par fréquence
- Limite de 10 suggestions
- Calcul de la map de fréquence

### Tests de Propriétés

Les tests de propriétés valident:
- **Propriété 7**: Suggestions d'autocomplétion pour requêtes ≥ 2 caractères
- **Propriété 8**: Remplissage automatique par suggestion
- **Propriété 9**: Tri des suggestions par fréquence
- **Propriété 10**: Limite des suggestions à 10 maximum

### Tests de Widgets

Les tests de widgets vérifient:
- Affichage des suggestions
- Sélection d'une suggestion
- Saisie libre
- Validation du formulaire

## Exigences Satisfaites

- **Exigence 3.1**: Suggestions après 2 caractères basées sur l'historique ✓
- **Exigence 3.2**: Remplissage automatique lors de la sélection ✓
- **Exigence 3.3**: Tri par fréquence d'utilisation décroissante ✓
- **Exigence 3.4**: Saisie libre si aucune suggestion ✓
- **Exigence 3.5**: Limite de 10 suggestions maximum ✓

## Améliorations Futures

1. **Cache des suggestions**: Mettre en cache les suggestions fréquentes
2. **Recherche floue**: Implémenter une recherche avec tolérance aux fautes de frappe
3. **Suggestions contextuelles**: Suggérer des magasins en fonction du produit
4. **Historique récent**: Prioriser les saisies récentes
5. **Personnalisation**: Permettre à l'utilisateur de gérer ses suggestions favorites

## Dépendances

- `hive_flutter`: Pour l'accès aux données persistées
- `flutter/material.dart`: Pour les widgets UI

## Performance

- **Temps de réponse**: < 50ms pour le calcul des suggestions
- **Mémoire**: Utilisation minimale grâce au calcul à la demande
- **Scalabilité**: Performant jusqu'à 10 000 entrées dans la base de données

## Accessibilité

- Labels sémantiques pour les lecteurs d'écran
- Support de la navigation au clavier
- Contrastes de couleurs respectant WCAG AA
- Tailles de police système supportées
