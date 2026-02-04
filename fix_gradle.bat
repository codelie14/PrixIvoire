@echo off
echo ========================================
echo Fix Gradle Wrapper - PrixIvoire
echo ========================================
echo.

echo Etape 1: Nettoyage du projet Flutter...
call flutter clean
echo.

echo Etape 2: Installation des dependances Flutter...
call flutter pub get
echo.

echo Etape 3: Verification du Gradle Wrapper...
if not exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo Le fichier gradle-wrapper.jar est manquant!
    echo.
    goto :regenerate_wrapper
)

echo Le fichier gradle-wrapper.jar existe.
echo.

echo Etape 4: Test du Gradle Wrapper...
cd android
call gradlew.bat --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERREUR: Le Gradle Wrapper ne fonctionne pas correctement.
    echo Tentative de regeneration...
    cd ..
    goto :regenerate_wrapper
)
cd ..
echo Le Gradle Wrapper fonctionne correctement!
echo.

echo Etape 5: Lancement de l'application...
call flutter run
echo.

goto :end

:regenerate_wrapper
echo.
echo ========================================
echo Regeneration du Gradle Wrapper
echo ========================================
echo.

echo Etape 1: Suppression de l'ancien wrapper...
if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    del /f /q "android\gradle\wrapper\gradle-wrapper.jar"
)
echo.

echo Etape 2: Telechargement du nouveau wrapper...
cd android
echo Telechargement de Gradle Wrapper 8.14...
powershell -Command "$ErrorActionPreference='Stop'; try { $url = 'https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar'; $outFile = 'gradle\wrapper\gradle-wrapper.jar'; Write-Host 'Telechargement depuis:' $url; Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing; Write-Host 'Telechargement reussi!' } catch { Write-Host 'Erreur:' $_.Exception.Message; Write-Host ''; Write-Host 'Tentative avec URL alternative...'; try { $url2 = 'https://github.com/gradle/gradle/raw/v8.14.0/gradle/wrapper/gradle-wrapper.jar'; Invoke-WebRequest -Uri $url2 -OutFile $outFile -UseBasicParsing; Write-Host 'Telechargement reussi avec URL alternative!' } catch { Write-Host 'Echec avec les deux URLs.'; exit 1 } }"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERREUR: Impossible de telecharger le wrapper.
    echo.
    echo Solutions alternatives:
    echo 1. Executez regenerate_wrapper.bat
    echo 2. Ouvrez le projet dans Android Studio
    echo 3. Telechargez manuellement depuis SOLUTION_GRADLE.md
    echo.
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

echo Etape 3: Verification du nouveau wrapper...
cd android
call gradlew.bat --version
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERREUR: Le wrapper regenere ne fonctionne toujours pas.
    echo.
    echo Solutions possibles:
    echo 1. Verifiez que Java est installe: java -version
    echo 2. Fermez tous les processus Gradle/Android Studio
    echo 3. Ouvrez le projet dans Android Studio pour regenerer automatiquement
    echo.
    cd ..
    pause
    exit /b 1
)
cd ..
echo Le wrapper a ete regenere avec succes!
echo.

echo Etape 4: Lancement de l'application...
call flutter run
echo.

:end
pause
