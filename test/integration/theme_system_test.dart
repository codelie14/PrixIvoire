import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:prixivoire/core/theme/theme_manager.dart';
import 'package:prixivoire/core/theme/theme_provider.dart';
import 'package:prixivoire/adapters/app_settings_adapter.dart';
import 'dart:io';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Créer un répertoire temporaire pour les tests
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    
    // Initialiser Hive avec le répertoire temporaire
    Hive.init(tempDir.path);
    
    // Enregistrer l'adaptateur AppSettings
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
  });

  tearDownAll(() async {
    // Nettoyer le répertoire temporaire
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  tearDown(() async {
    // Fermer toutes les boxes ouvertes
    await Hive.close();
  });

  group('ThemeManager Tests', () {
    test('loadTheme returns system theme by default', () async {
      final themeManager = ThemeManager();
      final themeMode = await themeManager.loadTheme();
      
      expect(themeMode, ThemeMode.system);
      await themeManager.dispose();
    });

    test('setTheme saves and loads theme correctly', () async {
      final themeManager = ThemeManager();
      
      // Sauvegarder le thème clair
      await themeManager.setTheme(ThemeMode.light);
      
      // Créer une nouvelle instance pour vérifier la persistance
      final themeManager2 = ThemeManager();
      final loadedTheme = await themeManager2.loadTheme();
      
      expect(loadedTheme, ThemeMode.light);
      
      await themeManager.dispose();
      await themeManager2.dispose();
    });

    test('setTheme persists dark theme', () async {
      final themeManager = ThemeManager();
      
      await themeManager.setTheme(ThemeMode.dark);
      
      final themeManager2 = ThemeManager();
      final loadedTheme = await themeManager2.loadTheme();
      
      expect(loadedTheme, ThemeMode.dark);
      
      await themeManager.dispose();
      await themeManager2.dispose();
    });

    test('getLightTheme returns valid ThemeData', () {
      final themeManager = ThemeManager();
      final lightTheme = themeManager.getLightTheme();
      
      expect(lightTheme, isA<ThemeData>());
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.useMaterial3, true);
    });

    test('getDarkTheme returns valid ThemeData', () {
      final themeManager = ThemeManager();
      final darkTheme = themeManager.getDarkTheme();
      
      expect(darkTheme, isA<ThemeData>());
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.useMaterial3, true);
    });

    test('light theme has proper color scheme', () {
      final themeManager = ThemeManager();
      final lightTheme = themeManager.getLightTheme();
      
      expect(lightTheme.colorScheme.primary, isNotNull);
      expect(lightTheme.colorScheme.onPrimary, isNotNull);
      expect(lightTheme.colorScheme.surface, isNotNull);
      expect(lightTheme.colorScheme.onSurface, isNotNull);
    });

    test('dark theme has proper color scheme', () {
      final themeManager = ThemeManager();
      final darkTheme = themeManager.getDarkTheme();
      
      expect(darkTheme.colorScheme.primary, isNotNull);
      expect(darkTheme.colorScheme.onPrimary, isNotNull);
      expect(darkTheme.colorScheme.surface, isNotNull);
      expect(darkTheme.colorScheme.onSurface, isNotNull);
    });
  });

  group('ThemeProvider Tests', () {
    test('initialize loads theme correctly', () async {
      final themeProvider = ThemeProvider();
      
      await themeProvider.initialize();
      
      expect(themeProvider.isInitialized, true);
      expect(themeProvider.themeMode, isA<ThemeMode>());
      
      themeProvider.dispose();
    });

    test('setThemeMode updates theme and notifies listeners', () async {
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      bool listenerCalled = false;
      themeProvider.addListener(() {
        listenerCalled = true;
      });
      
      // Change to a different theme to trigger notification
      final initialMode = themeProvider.themeMode;
      final newMode = initialMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      
      await themeProvider.setThemeMode(newMode);
      
      expect(themeProvider.themeMode, newMode);
      expect(listenerCalled, true);
      
      themeProvider.dispose();
    });

    test('lightTheme returns valid ThemeData', () async {
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      final lightTheme = themeProvider.lightTheme;
      
      expect(lightTheme, isA<ThemeData>());
      expect(lightTheme.brightness, Brightness.light);
      
      themeProvider.dispose();
    });

    test('darkTheme returns valid ThemeData', () async {
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      final darkTheme = themeProvider.darkTheme;
      
      expect(darkTheme, isA<ThemeData>());
      expect(darkTheme.brightness, Brightness.dark);
      
      themeProvider.dispose();
    });

    test('theme persists across provider instances', () async {
      // Premier provider: définir le thème
      final themeProvider1 = ThemeProvider();
      await themeProvider1.initialize();
      await themeProvider1.setThemeMode(ThemeMode.light);
      // Ne pas disposer pour garder la box ouverte
      
      // Deuxième provider: vérifier la persistance
      final themeProvider2 = ThemeProvider();
      await themeProvider2.initialize();
      
      expect(themeProvider2.themeMode, ThemeMode.light);
      
      themeProvider1.dispose();
      themeProvider2.dispose();
    });
  });
}
