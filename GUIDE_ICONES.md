# Guide de Génération des Icônes - PrixIvoire

## 📋 Ce qui a été configuré

J'ai ajouté la configuration `flutter_launcher_icons` dans votre `pubspec.yaml` pour générer automatiquement toutes les icônes nécessaires à partir de votre logo dans `assets/logo.png`.

## 🚀 Étapes pour générer les icônes

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Générer les icônes

```bash
flutter pub run flutter_launcher_icons
```

Cette commande va automatiquement :
- ✅ Créer toutes les tailles d'icônes pour **Android** (mipmap-mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Créer toutes les tailles d'icônes pour **iOS** (20x20 à 1024x1024)
- ✅ Créer les icônes pour **Web** (PWA)
- ✅ Créer les icônes pour **Windows** et **macOS**

### 3. Vérifier les résultats

Après la génération, vérifiez que les icônes ont été créées dans :

**Android :**
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

**iOS :**
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png`

**Web :**
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`
- `web/icons/Icon-maskable-192.png`
- `web/icons/Icon-maskable-512.png`

## 📝 Configuration actuelle

Votre configuration utilise :
- **Image source** : `assets/logo.png`
- **Couleur de fond Android** : Blanc (#FFFFFF)
- **Couleur de thème Web** : Bleu (#2196F3)

## 🎨 Recommandations pour votre logo

Pour de meilleurs résultats, assurez-vous que votre `assets/logo.png` :

1. **Taille minimale** : 1024x1024 pixels
2. **Format** : PNG avec transparence (canal alpha)
3. **Design** : 
   - Simple et reconnaissable
   - Évitez les détails trop fins
   - Laissez 10% de marge sur les bords (Android peut rogner)
4. **Couleurs** : Contrastées pour être visible sur tous les fonds

## 🔧 Personnalisation avancée

Si vous voulez personnaliser davantage, modifiez la section `flutter_launcher_icons` dans `pubspec.yaml` :

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/logo.png"
  
  # Pour Android - Icône adaptative
  adaptive_icon_background: "#FFFFFF"  # Changez la couleur de fond
  adaptive_icon_foreground: "assets/logo.png"
  
  # Pour Web
  web:
    generate: true
    image_path: "assets/logo.png"
    background_color: "#FFFFFF"
    theme_color: "#2196F3"  # Couleur de la barre d'adresse sur mobile
```

## 🐛 Résolution de problèmes

### Erreur : "Image not found"
- Vérifiez que `assets/logo.png` existe
- Vérifiez que le chemin est correct dans `pubspec.yaml`

### Les icônes ne changent pas après génération
- Nettoyez le build : `flutter clean`
- Reconstruisez l'app : `flutter run`
- Sur iOS, désinstallez l'app et réinstallez

### Icône floue ou pixelisée
- Utilisez une image source plus grande (minimum 1024x1024)
- Assurez-vous que votre logo est en haute résolution

## ✅ Vérification finale

Après génération, testez sur :
1. **Émulateur Android** : Vérifiez l'icône dans le lanceur
2. **Simulateur iOS** : Vérifiez l'icône sur l'écran d'accueil
3. **Navigateur Web** : Vérifiez le favicon et l'icône PWA

## 📞 Commandes utiles

```bash
# Installer les dépendances
flutter pub get

# Générer les icônes
flutter pub run flutter_launcher_icons

# Nettoyer le projet
flutter clean

# Reconstruire l'application
flutter run

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

## 🎯 Prochaines étapes

1. Exécutez `flutter pub get`
2. Exécutez `flutter pub run flutter_launcher_icons`
3. Vérifiez les icônes générées
4. Testez sur un émulateur/simulateur
5. Si tout est bon, vous êtes prêt ! 🎉

---

**Note** : Les icônes dans `assets/icons/` que vous avez ajoutées peuvent être utilisées dans l'application (par exemple, dans l'interface utilisateur). Les icônes générées par `flutter_launcher_icons` sont spécifiquement pour l'icône de l'application sur les appareils.
