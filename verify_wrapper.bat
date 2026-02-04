@echo off
echo ========================================
echo Verification du Gradle Wrapper
echo ========================================
echo.

echo Verification du fichier gradle-wrapper.jar...
if not exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo ERREUR: Le fichier gradle-wrapper.jar n'existe pas!
    echo.
    pause
    exit /b 1
)

echo Le fichier existe.
echo.

echo Taille du fichier:
for %%A in ("android\gradle\wrapper\gradle-wrapper.jar") do echo   %%~zA octets
echo.

echo Verification de Java...
java -version
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERREUR: Java n'est pas installe ou non accessible!
    pause
    exit /b 1
)
echo.

echo Test du wrapper avec Java directement...
cd android
java -jar gradle\wrapper\gradle-wrapper.jar --version
if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCES: Le wrapper fonctionne avec Java directement!
    echo Le probleme vient peut-etre du script gradlew.bat
    cd ..
    echo.
    echo Testons maintenant avec gradlew.bat...
    cd android
    call gradlew.bat --version
    cd ..
) else (
    echo.
    echo ERREUR: Le fichier jar est corrompu ou invalide.
    echo Le fichier doit etre retelecharge.
    cd ..
)
echo.

pause
