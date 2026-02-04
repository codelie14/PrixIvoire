# Guide de dépannage - PrixIvoire

## Problème : Erreur Gradle Wrapper

Si vous rencontrez l'erreur :
```
Erreur : impossible de trouver ou de charger la classe principale org.gradle.wrapper.GradleWrapperMain
```

### Solutions à essayer :

#### Solution 1 : Nettoyer et reconstruire le projet

Dans le terminal PowerShell, exécutez :

```powershell
flutter clean
flutter pub get
cd android
.\gradlew.bat clean
cd ..
flutter run
```

#### Solution 2 : Vérifier Java

Assurez-vous que Java est installé et accessible :

```powershell
java -version
```

Si Java n'est pas installé, téléchargez-le depuis [Oracle](https://www.oracle.com/java/technologies/downloads/) ou utilisez [OpenJDK](https://adoptium.net/).

#### Solution 3 : Régénérer le Gradle Wrapper

Si le wrapper est corrompu, utilisez le script dédié :

```cmd
regenerate_wrapper.bat
```

Ou manuellement :

```powershell
# 1. Fermez tous les processus Gradle/Android Studio
# 2. Supprimez l'ancien wrapper
del android\gradle\wrapper\gradle-wrapper.jar

# 3. Téléchargez le nouveau wrapper
cd android
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'gradle\wrapper\gradle-wrapper.jar'"
cd ..
```

**Important** : Fermez Android Studio et tous les processus Gradle avant de régénérer le wrapper !

#### Solution 4 : Supprimer le cache Gradle

Supprimez le cache Gradle et réessayez :

```powershell
Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches
flutter clean
flutter pub get
flutter run
```

#### Solution 5 : Vérifier les permissions

Assurez-vous que les fichiers dans `android/gradle/wrapper/` ne sont pas en lecture seule :
- `gradle-wrapper.jar`
- `gradle-wrapper.properties`

#### Solution 6 : Utiliser Android Studio

Si les solutions ci-dessus ne fonctionnent pas :
1. Ouvrez le projet dans Android Studio
2. Laissez Android Studio synchroniser Gradle automatiquement
3. Exécutez l'application depuis Android Studio

#### Solution 7 : Réinitialiser le projet Flutter

En dernier recours, vous pouvez créer un nouveau projet Flutter et copier le code :

```powershell
flutter create nouveau_projet
# Copiez ensuite les fichiers de lib/, pubspec.yaml, etc.
```

## Autres problèmes courants

### Problème : Dépendances manquantes

```powershell
flutter pub get
```

### Problème : Erreurs de compilation

Vérifiez que toutes les dépendances sont compatibles avec votre version de Flutter :

```powershell
flutter doctor
flutter pub outdated
```

### Problème : Permissions Android

Assurez-vous que les permissions sont correctement configurées dans `android/app/src/main/AndroidManifest.xml`.

## Support

Si le problème persiste, vérifiez :
- Version de Flutter : `flutter --version`
- Version de Java : `java -version`
- Version de Gradle : Voir `android/gradle/wrapper/gradle-wrapper.properties`
