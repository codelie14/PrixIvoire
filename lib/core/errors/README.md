# Système de Gestion d'Erreurs - PrixIvoire

Ce module fournit un système complet de gestion d'erreurs pour l'application PrixIvoire.

## Composants

### 1. Hiérarchie d'Exceptions (`app_exception.dart`)

Toutes les exceptions personnalisées héritent de `AppException` :

- **AppException** : Classe de base abstraite
- **StorageException** : Erreurs de stockage (Hive, fichiers)
- **OCRException** : Erreurs de reconnaissance de texte
- **ValidationException** : Erreurs de validation de données
- **NetworkException** : Erreurs réseau
- **ExportException** : Erreurs d'export de fichiers

#### Utilisation

```dart
// Lancer une exception de stockage
throw StorageException(
  'Impossible de sauvegarder le prix',
  code: 'WRITE_FAILED',
  originalError: e,
);

// Lancer une exception de validation
throw ValidationException(
  'Données invalides',
  {
    'price': 'Le prix doit être positif',
    'productName': 'Le nom est requis',
  },
);
```

### 2. Gestionnaire d'Erreurs (`error_handler.dart`)

Fournit des méthodes pour traduire les exceptions en messages utilisateur et logger les erreurs.

#### Méthodes

- `getUserFriendlyMessage(Exception error)` : Convertit une exception en message français
- `logError(Exception error, StackTrace stackTrace, {Map<String, dynamic>? context})` : Log une erreur avec contexte
- `logMessage(String message, {Map<String, dynamic>? context, StackTrace? stackTrace})` : Log un message personnalisé

#### Utilisation

```dart
try {
  // Opération risquée
  await storageService.savePrice(price);
} catch (error, stackTrace) {
  // Logger l'erreur
  ErrorHandler.logError(
    error as Exception,
    stackTrace,
    context: {'screen': 'AddPriceScreen', 'action': 'save'},
  );
  
  // Afficher un message à l'utilisateur
  final message = ErrorHandler.getUserFriendlyMessage(error as Exception);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

### 3. Exécuteur Sécurisé (`safe_executor.dart`)

Encapsule les opérations dans un try-catch avec gestion automatique du loading et des messages.

#### Méthodes

- `execute<T>()` : Exécute une opération asynchrone
- `executeSync<T>()` : Exécute une opération synchrone

#### Utilisation

```dart
// Opération asynchrone avec gestion complète
final result = await SafeExecutor.execute<ProductPrice>(
  action: () => storageService.savePrice(price),
  context: context,
  successMessage: 'Prix enregistré avec succès',
  showLoading: true,
);

if (result != null) {
  // Succès
  Navigator.pop(context);
}

// Opération synchrone
final validated = SafeExecutor.executeSync<bool>(
  action: () => validationService.validatePrice(priceText),
  context: context,
  showLoading: false,
);
```

## Codes d'Erreur

### StorageException
- `STORAGE_FULL` : Espace de stockage insuffisant
- `PERMISSION_DENIED` : Permission refusée
- `DATABASE_CORRUPTED` : Base de données corrompue
- `WRITE_FAILED` : Échec d'écriture
- `READ_FAILED` : Échec de lecture
- `DELETE_FAILED` : Échec de suppression

### OCRException
- `NO_TEXT_FOUND` : Aucun texte détecté
- `POOR_QUALITY` : Qualité d'image insuffisante
- `IMAGE_TOO_LARGE` : Image trop volumineuse
- `INVALID_IMAGE` : Format d'image invalide
- `PROCESSING_FAILED` : Échec du traitement
- `NO_PRICES_FOUND` : Aucun prix détecté

### NetworkException
- `NO_CONNECTION` : Aucune connexion internet
- `TIMEOUT` : Connexion expirée
- `SERVER_ERROR` : Erreur du serveur
- `NOT_FOUND` : Ressource introuvable

### ExportException
- `INSUFFICIENT_SPACE` : Espace de stockage insuffisant
- `PERMISSION_DENIED` : Permission refusée
- `INVALID_FORMAT` : Format d'export invalide
- `GENERATION_FAILED` : Échec de génération
- `NO_DATA` : Aucune donnée à exporter

## Bonnes Pratiques

1. **Toujours utiliser SafeExecutor** pour les opérations utilisateur
2. **Logger toutes les erreurs** avec contexte approprié
3. **Utiliser des codes d'erreur** pour faciliter le débogage
4. **Fournir des messages clairs** en français
5. **Inclure l'erreur originale** pour le débogage

## Exemple Complet

```dart
class AddPriceScreen extends StatelessWidget {
  Future<void> _savePrice() async {
    final price = ProductPrice(
      productName: _productController.text,
      price: double.parse(_priceController.text),
      storeName: _storeController.text,
      date: DateTime.now(),
    );
    
    final result = await SafeExecutor.execute<ProductPrice>(
      action: () async {
        // Valider d'abord
        final validation = validationService.validatePrice(price);
        if (!validation.isValid) {
          throw ValidationException(
            'Données invalides',
            {'price': validation.errorMessage!},
          );
        }
        
        // Sauvegarder
        return await storageService.savePrice(price);
      },
      context: context,
      successMessage: 'Prix enregistré avec succès',
      onError: (error) {
        // Action personnalisée en cas d'erreur
        if (error is StorageException && error.code == 'STORAGE_FULL') {
          _showCleanupDialog();
        }
      },
    );
    
    if (result != null) {
      Navigator.pop(context);
    }
  }
}
```
