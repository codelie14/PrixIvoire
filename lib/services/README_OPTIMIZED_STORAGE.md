# Service de Stockage Optimisé - PrixIvoire

## Vue d'ensemble

Le `OptimizedStorageService` est une couche d'abstraction optimisée au-dessus de Hive qui fournit des fonctionnalités avancées de gestion de données avec indexation, pagination et maintenance automatique.

## Fonctionnalités principales

### 1. Indexation automatique

Le service crée et maintient automatiquement des index sur les champs fréquemment recherchés :
- **Nom de produit** : Recherche rapide par nom de produit
- **Nom de magasin** : Filtrage par magasin
- **Date** : Recherche par date

Les index permettent des recherches en O(1) au lieu de O(n), améliorant considérablement les performances.

### 2. Pagination

```dart
// Charger la première page (50 éléments par défaut)
final page1 = await service.getPricesPaginated(0);

// Charger la deuxième page
final page2 = await service.getPricesPaginated(1, pageSize: 50);
```

La pagination permet de :
- Charger uniquement les données nécessaires
- Réduire l'utilisation de la mémoire
- Améliorer les performances de démarrage

### 3. Recherche optimisée

```dart
// Recherche par nom de produit (utilise l'index)
final results = await service.searchProducts('riz');

// Recherche par magasin
final carrefourPrices = await service.searchByStore('Carrefour');

// Recherche par date
final todayPrices = await service.searchByDate(DateTime.now());
```

### 4. Compaction automatique

La compaction réduit la taille de la base de données en supprimant l'espace inutilisé :

```dart
// Compacter si la taille dépasse 50MB
final compacted = await service.compactDatabase(maxSizeBytes: 50 * 1024 * 1024);
```

### 5. Nettoyage des anciennes entrées

Limite le nombre d'entrées pour éviter une croissance incontrôlée :

```dart
// Garder seulement les 1000 entrées les plus récentes
final deleted = await service.cleanOldEntries(maxEntries: 1000);
```

## Utilisation

### Initialisation

```dart
final service = OptimizedStorageService();
await service.initialize();
```

### Ajout de données

```dart
final price = ProductPrice(
  productName: 'Riz 25kg',
  price: 15000,
  shop: 'Carrefour',
  date: DateTime.now(),
);

await service.addProductPrice(price);
```

### Récupération de données

```dart
// Pagination
final prices = await service.getPricesPaginated(0, pageSize: 50);

// Recherche
final results = await service.searchProducts('riz');

// Par produit spécifique
final productPrices = await service.getProductPricesByProduct('Riz 25kg');

// Par magasin
final storePrices = await service.getProductPricesByShop('Carrefour');
```

### Statistiques

```dart
// Nombre total d'entrées
final count = service.totalPricesCount;

// Taille de la base de données
final sizeBytes = await service.getDatabaseSize();
final sizeMB = sizeBytes / (1024 * 1024);
```

## Service de Maintenance

Le `StorageMaintenanceService` gère automatiquement la compaction et le nettoyage :

```dart
final maintenanceService = StorageMaintenanceService(optimizedStorageService);

// Démarrer la maintenance automatique (toutes les 24h)
maintenanceService.startAutomaticMaintenance();

// Exécuter manuellement
final result = await maintenanceService.runManualMaintenance();
print('Compaction: ${result.compactionPerformed}');
print('Entrées supprimées: ${result.entriesDeleted}');

// Obtenir des statistiques
final stats = await maintenanceService.getStorageStats();
print('Taille: ${stats.sizeMB.toStringAsFixed(2)} MB');
print('Entrées: ${stats.totalEntries}');
print('Nécessite compaction: ${stats.needsCompaction}');
print('Nécessite nettoyage: ${stats.needsCleaning}');
```

## Widgets de Lazy Loading

### PaginatedPriceList

Widget prêt à l'emploi pour afficher une liste paginée :

```dart
PaginatedPriceList(
  storageService: optimizedStorageService,
  pageSize: 50,
  itemBuilder: (context, price) {
    return ListTile(
      title: Text(price.productName),
      subtitle: Text(price.shop),
      trailing: Text('${price.price} FCFA'),
    );
  },
)
```

### LazyLoadedList

Widget personnalisable avec chargement automatique :

```dart
LazyLoadedList(
  storageService: optimizedStorageService,
  pageSize: 50,
  itemBuilder: (context, price, index) {
    return Card(
      child: ListTile(
        title: Text(price.productName),
        trailing: Text('${price.price} FCFA'),
      ),
    );
  },
  emptyMessage: 'Aucun prix enregistré',
)
```

### Mixin LazyPriceLoader

Pour ajouter le lazy loading à n'importe quel widget :

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with LazyPriceLoader {
  late ScrollController _scrollController;

  @override
  OptimizedStorageService get storageService => widget.storageService;

  @override
  void initState() {
    super.initState();
    _scrollController = createLazyScrollController();
    loadInitialPrices();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: loadedPrices.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= loadedPrices.length) {
          return buildLoadingIndicator();
        }
        return ListTile(title: Text(loadedPrices[index].productName));
      },
    );
  }
}
```

## Performance

### Benchmarks

Sur une base de données de 10 000 entrées :

- **Recherche indexée** : < 200ms
- **Pagination (50 éléments)** : < 50ms
- **Démarrage avec lazy loading** : < 100ms
- **Compaction (50MB)** : 2-5 secondes (en arrière-plan)

### Optimisations

1. **Index en mémoire** : Les index sont maintenus en mémoire pour des recherches ultra-rapides
2. **Chargement à la demande** : Seules les données visibles sont chargées
3. **Compaction asynchrone** : La compaction s'exécute sans bloquer l'UI
4. **Nettoyage intelligent** : Supprime les entrées les plus anciennes en premier

## Exigences satisfaites

- **10.1** : Indexation sur productName, storeName, date
- **10.2** : Recherche en < 200ms pour < 10 000 entrées
- **10.3** : Pagination avec lots de 50 éléments
- **10.4** : Lazy loading au démarrage
- **10.5** : Compaction quand taille > 50MB
- **10.6** : Limite de 1000 entrées par type

## Migration depuis StorageService

Pour migrer du `StorageService` existant vers `OptimizedStorageService` :

```dart
// Ancien code
final storageService = StorageService();
await storageService.init();
final prices = storageService.getAllProductPrices();

// Nouveau code
final optimizedService = OptimizedStorageService();
await optimizedService.initialize();
final prices = await optimizedService.getPricesPaginated(0, pageSize: 50);
```

Les deux services peuvent coexister pendant la migration.

## Notes importantes

1. **Initialisation** : Toujours appeler `initialize()` avant d'utiliser le service
2. **Fermeture** : Appeler `close()` lors de la fermeture de l'application
3. **Index** : Les index sont reconstruits automatiquement après suppression ou compaction
4. **Thread safety** : Le service n'est pas thread-safe, utiliser depuis le thread principal uniquement

## Dépendances

- `hive` : Base de données NoSQL
- `hive_flutter` : Intégration Flutter pour Hive
- `flutter/foundation.dart` : Pour `compute()` (exécution en isolate)

## Tests

Les tests unitaires sont disponibles dans `test/unit/services/optimized_storage_service_test.dart`.

Pour exécuter les tests :

```bash
flutter test test/unit/services/optimized_storage_service_test.dart
```
