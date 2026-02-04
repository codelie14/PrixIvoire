@echo off
echo ========================================
echo Fix Gradle Wrapper Complet
echo ========================================
echo.

echo Etape 1: Verification de Java...
java -version
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Java n'est pas installe!
    pause
    exit /b 1
)
echo.

echo Etape 2: Verification du fichier actuel...
if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo Le fichier existe.
    for %%A in ("android\gradle\wrapper\gradle-wrapper.jar") do (
        echo Taille: %%~zA octets
        if %%~zA LSS 50000 (
            echo ATTENTION: Le fichier semble trop petit (devrait etre ~60-70 KB)
            echo Il est probablement corrompu.
            goto :redownload
        )
    )
    echo Le fichier semble avoir une taille correcte.
    echo.
) else (
    echo Le fichier n'existe pas.
    goto :redownload
)

echo Etape 3: Test du wrapper...
cd android
call gradlew.bat --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo SUCCES: Le wrapper fonctionne!
    cd ..
    goto :success
)
cd ..
echo Le wrapper ne fonctionne pas. Tentative de reparation...
echo.

:redownload
echo ========================================
echo Telechargement du wrapper depuis plusieurs sources
echo ========================================
echo.

echo Suppression de l'ancien fichier...
if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    del /f /q "android\gradle\wrapper\gradle-wrapper.jar"
)

echo.
echo Tentative 1: GitHub (raw.githubusercontent.com)...
cd android
powershell -Command "$ErrorActionPreference='Stop'; try { $url = 'https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar'; $outFile = 'gradle\wrapper\gradle-wrapper.jar'; Write-Host 'Telechargement...'; $response = Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing; $file = Get-Item $outFile; Write-Host \"Telecharge: $($file.Length) octets\"; if ($file.Length -lt 50000) { Write-Host 'Fichier trop petit, probablement corrompu'; exit 1 } else { Write-Host 'OK' } } catch { Write-Host 'Echec:' $_.Exception.Message; exit 1 }"

if %ERRORLEVEL% EQU 0 (
    echo Telechargement reussi!
    goto :test_wrapper
)

echo.
echo Tentative 2: GitHub (github.com)...
powershell -Command "$ErrorActionPreference='Stop'; try { $url = 'https://github.com/gradle/gradle/raw/v8.14.0/gradle/wrapper/gradle-wrapper.jar'; $outFile = 'gradle\wrapper\gradle-wrapper.jar'; Write-Host 'Telechargement...'; $response = Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing; $file = Get-Item $outFile; Write-Host \"Telecharge: $($file.Length) octets\"; if ($file.Length -lt 50000) { Write-Host 'Fichier trop petit'; exit 1 } else { Write-Host 'OK' } } catch { Write-Host 'Echec:' $_.Exception.Message; exit 1 }"

if %ERRORLEVEL% EQU 0 (
    echo Telechargement reussi!
    goto :test_wrapper
)

echo.
echo ERREUR: Impossible de telecharger depuis les URLs automatiques.
echo.
echo SOLUTION MANUELLE:
echo 1. Ouvrez votre navigateur
echo 2. Allez sur: https://github.com/gradle/gradle/releases/tag/v8.14.0
echo 3. Ou telechargez directement depuis:
echo    https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar
echo 4. Enregistrez le fichier dans: android\gradle\wrapper\gradle-wrapper.jar
echo 5. Relancez ce script
echo.
cd ..
pause
exit /b 1

:test_wrapper
cd ..
echo.
echo Verification de la taille du fichier...
for %%A in ("android\gradle\wrapper\gradle-wrapper.jar") do (
    echo Taille: %%~zA octets
    if %%~zA LSS 50000 (
        echo ERREUR: Le fichier est trop petit!
        echo Il doit faire environ 60-70 KB.
        pause
        exit /b 1
    )
)
echo.

echo Test du wrapper...
cd android
call gradlew.bat --version
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERREUR: Le wrapper ne fonctionne toujours pas.
    echo.
    echo Solutions possibles:
    echo 1. Verifiez que Java 17 ou superieur est installe
    echo 2. Essayez avec Android Studio (il regenerera automatiquement)
    echo 3. Verifiez que le fichier n'est pas bloque par l'antivirus
    echo.
    cd ..
    pause
    exit /b 1
)
cd ..

:success
echo.
echo ========================================
echo SUCCES: Le Gradle Wrapper fonctionne!
echo ========================================
echo.
echo Vous pouvez maintenant lancer:
echo   flutter run
echo.
pause
