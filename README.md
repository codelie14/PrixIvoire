# PrixIvoire

Application Flutter pour comparer les prix des produits en Côte d'Ivoire.

## Fonctionnalités

- ✅ Saisie manuelle des prix
- ✅ Scan OCR pour extraire les prix depuis les images
- ✅ Stockage local avec Hive
- ✅ Comparaison des prix entre magasins
- ✅ Visualisation des tendances avec graphiques
- ✅ Alertes personnalisées
- ✅ Export/Import CSV

## Installation

1. Installer les dépendances :
```bash
flutter pub get
```

2. Si vous rencontrez une erreur Gradle Wrapper :
   - Exécutez le script `fix_gradle.bat` (Windows)
   - Ou suivez les instructions dans `TROUBLESHOOTING.md`

3. Lancer l'application :
```bash
flutter run
```

### Résolution des problèmes Gradle

Si vous voyez l'erreur `impossible de trouver ou de charger la classe principale org.gradle.wrapper.GradleWrapperMain` :

**⚠️ IMPORTANT : Fermez Android Studio et tous les processus Gradle avant !**

**Solution rapide (Windows) :**
```cmd
fix_wrapper_complete.bat
```

Ce script vérifie et répare automatiquement le wrapper.

**Puis :**
```cmd
flutter run
```

**Solutions alternatives :**
- Voir `SOLUTION_GRADLE.md` pour le guide complet
- Voir `TROUBLESHOOTING.md` pour d'autres problèmes

## Structure du projet

```
lib/
├── adapters/          # Adaptateurs Hive
├── models/            # Modèles de données
├── screens/           # Écrans de l'application
├── services/          # Services (stockage, OCR, notifications, CSV)
└── main.dart         # Point d'entrée
```

## Technologies utilisées

- Flutter
- Hive (stockage local)
- Google ML Kit (OCR)
- fl_chart (graphiques)
- flutter_local_notifications (notifications)

## Notes

- L'application fonctionne entièrement hors ligne
- Les données sont stockées localement sur l'appareil
- Compatible Android 6.0+
