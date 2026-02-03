# Instructions d'installation - PrixIvoire

## Étapes pour lancer l'application

### 1. Installer les dépendances Flutter

Exécutez la commande suivante dans le terminal à la racine du projet :

```bash
flutter pub get
```

### 2. Vérifier la configuration Android

Les permissions nécessaires ont déjà été ajoutées dans `android/app/src/main/AndroidManifest.xml` :
- Permission caméra
- Permission de lecture/écriture du stockage

### 3. Lancer l'application

Pour Android :
```bash
flutter run
```

Ou depuis Android Studio / VS Code, utilisez le bouton "Run".

## Structure de l'application

L'application est organisée comme suit :

- **lib/models/** : Modèles de données (ProductPrice, PriceAlert)
- **lib/services/** : Services métier
  - `storage_service.dart` : Gestion du stockage Hive
  - `ocr_service.dart` : Extraction de texte depuis les images
  - `notification_service.dart` : Gestion des notifications
  - `csv_service.dart` : Export/Import CSV
- **lib/screens/** : Écrans de l'application
  - `home_screen.dart` : Écran d'accueil
  - `add_price_screen.dart` : Saisie manuelle des prix
  - `scan_screen.dart` : Scan OCR
  - `price_comparison_screen.dart` : Comparaison des prix
  - `trends_screen.dart` : Graphiques de tendances
  - `alerts_screen.dart` : Gestion des alertes
  - `export_import_screen.dart` : Export/Import CSV
- **lib/adapters/** : Adaptateurs Hive pour la sérialisation

## Fonctionnalités implémentées

✅ Toutes les fonctionnalités du cahier des charges sont implémentées :
- Saisie manuelle des prix
- Scan OCR pour extraire les prix
- Stockage local avec Hive
- Comparaison des prix avec filtres
- Graphiques de tendances (fl_chart)
- Système d'alertes avec notifications
- Export/Import CSV

## Notes importantes

- L'application fonctionne entièrement hors ligne
- Les données sont stockées localement sur l'appareil
- Compatible Android 6.0+ (API 23+)
- Les adaptateurs Hive sont créés manuellement (pas besoin de build_runner)

## Prochaines étapes (optionnel)

Si vous souhaitez améliorer l'application :

1. **Générer les adaptateurs Hive automatiquement** :
   - Décommenter les lignes `part` dans les modèles
   - Exécuter `flutter pub run build_runner build`
   - Supprimer les adaptateurs manuels dans `lib/adapters/`

2. **Améliorer l'OCR** :
   - Ajouter la détection automatique des produits et magasins
   - Améliorer l'extraction des prix depuis le texte OCR

3. **Ajouter l'autocomplétion** :
   - Implémenter l'autocomplétion dans les champs de saisie
   - Utiliser les produits et magasins existants

4. **Améliorer l'import CSV** :
   - Ajouter un sélecteur de fichier pour l'import
   - Valider le format CSV avant l'import
