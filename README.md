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

2. Lancer l'application :
```bash
flutter run
```

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
