@echo off
echo ========================================
echo Regeneration du Gradle Wrapper
echo ========================================
echo.

echo ATTENTION: Fermez tous les processus Gradle et Android Studio avant de continuer!
echo.
pause

echo Etape 1: Suppression de l'ancien wrapper...
if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    del /f /q "android\gradle\wrapper\gradle-wrapper.jar"
    echo Fichier supprime.
) else (
    echo Le fichier n'existe pas.
)
echo.

echo Etape 2: Telechargement du nouveau wrapper...
cd android
echo Telechargement de Gradle Wrapper 8.14...
echo URL: https://services.gradle.org/distributions/gradle-8.14-bin.zip
echo.
powershell -Command "$ErrorActionPreference='Stop'; try { $url = 'https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar'; $outFile = 'gradle\wrapper\gradle-wrapper.jar'; Write-Host 'Telechargement depuis:' $url; Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing; Write-Host 'Telechargement reussi!' } catch { Write-Host 'Erreur:' $_.Exception.Message; Write-Host ''; Write-Host 'Tentative avec URL alternative...'; try { $url2 = 'https://github.com/gradle/gradle/raw/v8.14.0/gradle/wrapper/gradle-wrapper.jar'; Invoke-WebRequest -Uri $url2 -OutFile $outFile -UseBasicParsing; Write-Host 'Telechargement reussi avec URL alternative!' } catch { Write-Host 'Echec avec les deux URLs.'; exit 1 } }"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERREUR: Impossible de telecharger le wrapper automatiquement.
    echo.
    echo Solution alternative:
    echo 1. Telechargez manuellement depuis:
    echo    https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar
    echo 2. Placez-le dans: android\gradle\wrapper\gradle-wrapper.jar
    echo 3. Ou ouvrez le projet dans Android Studio
    echo.
    cd ..
    pause
    exit /b 1
)
cd ..
echo.

echo Etape 3: Verification du wrapper...
cd android
call gradlew.bat --version
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERREUR: Le wrapper ne fonctionne toujours pas.
    echo.
    echo Verifiez:
    echo 1. Java est installe: java -version
    echo 2. Tous les processus Gradle sont fermes
    echo 3. Le fichier gradle-wrapper.jar existe et n'est pas corrompu
    echo.
    cd ..
    pause
    exit /b 1
)
cd ..
echo.
echo ========================================
echo SUCCES: Le Gradle Wrapper a ete regenere!
echo ========================================
echo.
pause
