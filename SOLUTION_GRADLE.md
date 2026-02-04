# Solution au problème Gradle Wrapper

## Problème identifié

L'erreur `impossible de trouver ou de charger la classe principale org.gradle.wrapper.GradleWrapperMain` indique que le fichier `gradle-wrapper.jar` est corrompu ou manquant.

## Solutions

### Solution 1 : Script automatique (Recommandé)

1. **Fermez tous les processus Gradle et Android Studio**
   - Vérifiez le Gestionnaire des tâches Windows
   - Fermez tous les processus `java.exe` liés à Gradle

2. **Exécutez le script de régénération** :
   ```cmd
   regenerate_wrapper.bat
   ```

### Solution 2 : Script de réparation complet

Utilisez le script amélioré qui vérifie et répare automatiquement :

```cmd
fix_wrapper_complete.bat
```

Ce script :
- Vérifie la taille du fichier (doit faire ~60-70 KB)
- Télécharge depuis plusieurs sources si nécessaire
- Teste le wrapper après téléchargement

### Solution 3 : Téléchargement manuel

1. **Téléchargez le fichier** depuis :
   - https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar
   - Ou depuis : https://github.com/gradle/gradle/raw/v8.14.0/gradle/wrapper/gradle-wrapper.jar

2. **Vérifiez la taille** : Le fichier doit faire environ **60-70 KB** (pas moins de 50 KB)

3. **Placez-le dans** :
   ```
   android\gradle\wrapper\gradle-wrapper.jar
   ```

4. **Vérifiez** :
   ```cmd
   cd android
   gradlew.bat --version
   ```

### Solution 4 : Utiliser Android Studio

1. Ouvrez le projet dans Android Studio
2. Android Studio détectera le problème et proposera de régénérer le wrapper
3. Acceptez la régénération automatique

### Solution 5 : Utiliser Gradle directement (si installé)

Si vous avez Gradle installé globalement :

```cmd
cd android
gradle wrapper --gradle-version 8.14
cd ..
```

### Solution 6 : Problème de compatibilité Java 25

**⚠️ IMPORTANT** : Vous utilisez **Java 25**, qui est très récent. 

Gradle 8.14 supporte officiellement Java 8-21. Java 25 peut causer des problèmes de compatibilité.

**Solutions :**
1. **Utilisez Java 17 ou 21 LTS** (recommandé) - Voir `PROBLEME_JAVA25.md`
2. **Mettez à jour Gradle** vers 8.10+ qui supporte mieux Java 25
3. **Utilisez Android Studio** qui gère automatiquement Java

Voir `PROBLEME_JAVA25.md` pour les détails complets.

Assurez-vous que Java est correctement installé :

```cmd
java -version
```

Vous devriez voir quelque chose comme :
```
openjdk version "25.0.2" 2026-01-20 LTS
```

Si Java n'est pas installé, téléchargez-le depuis :
- [Adoptium (OpenJDK)](https://adoptium.net/)
- [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)

## Vérification après correction

Après avoir régénéré le wrapper, testez :

```cmd
cd android
gradlew.bat --version
```

Vous devriez voir :
```
------------------------------------------------------------
Gradle 8.14
------------------------------------------------------------
```

Si cela fonctionne, retournez à la racine et lancez :

```cmd
cd ..
flutter run
```

## Notes importantes

- **Fermez toujours Android Studio** avant de modifier les fichiers Gradle
- Le cache Gradle verrouillé est normal si Android Studio est ouvert
- Si le problème persiste, supprimez le dossier `.gradle` dans votre répertoire utilisateur (après avoir fermé tous les processus)
