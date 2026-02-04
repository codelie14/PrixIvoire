import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/app_settings.dart';

/// Gestionnaire de thèmes pour l'application PrixIvoire
/// 
/// Responsabilités:
/// - Charger le thème sauvegardé au démarrage
/// - Persister les changements de thème
/// - Fournir les configurations de thème Material Design 3
class ThemeManager {
  static const String _settingsBoxName = 'app_settings';
  static const String _settingsKey = 'settings';
  
  Box<AppSettings>? _settingsBox;
  AppSettings? _currentSettings;

  /// Charge le thème sauvegardé depuis Hive
  /// 
  /// Retourne le ThemeMode correspondant au thème sauvegardé
  /// ou ThemeMode.system par défaut
  Future<ThemeMode> loadTheme() async {
    try {
      // Ouvrir la box si elle n'est pas déjà ouverte
      if (_settingsBox == null || !_settingsBox!.isOpen) {
        _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
      }

      // Récupérer les paramètres
      _currentSettings = _settingsBox!.get(_settingsKey);
      
      // Si aucun paramètre n'existe, créer les paramètres par défaut
      if (_currentSettings == null) {
        _currentSettings = AppSettings.defaultSettings();
        await _settingsBox!.put(_settingsKey, _currentSettings!);
      }

      // Convertir la chaîne en ThemeMode
      return _themeModeFromString(_currentSettings!.themeMode);
    } catch (e) {
      // En cas d'erreur, retourner le thème système par défaut
      debugPrint('Erreur lors du chargement du thème: $e');
      return ThemeMode.system;
    }
  }

  /// Sauvegarde le choix de thème
  /// 
  /// [mode] Le mode de thème à sauvegarder
  Future<void> setTheme(ThemeMode mode) async {
    try {
      // S'assurer que la box est ouverte
      if (_settingsBox == null || !_settingsBox!.isOpen) {
        _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
      }

      // Récupérer ou créer les paramètres
      _currentSettings ??= _settingsBox!.get(_settingsKey) ?? AppSettings.defaultSettings();

      // Mettre à jour le mode de thème directement
      final modeString = _themeModeToString(mode);
      _currentSettings!.themeMode = modeString;
      
      // Sauvegarder dans Hive
      await _settingsBox!.put(_settingsKey, _currentSettings!);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème: $e');
      rethrow;
    }
  }

  /// Retourne le ThemeData pour le mode clair avec Material Design 3
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _getLightColorScheme(),
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _getLightColorScheme().surface,
        foregroundColor: _getLightColorScheme().onSurface,
      ),
      
      // Cards
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _getLightColorScheme().surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _getLightColorScheme().primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _getLightColorScheme().error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Retourne le ThemeData pour le mode sombre avec Material Design 3
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _getDarkColorScheme(),
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _getDarkColorScheme().surface,
        foregroundColor: _getDarkColorScheme().onSurface,
      ),
      
      // Cards
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _getDarkColorScheme().surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _getDarkColorScheme().primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: _getDarkColorScheme().error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Retourne le ColorScheme pour le mode clair
  /// Respecte les contrastes WCAG AA
  ColorScheme _getLightColorScheme() {
    return ColorScheme.light(
      primary: const Color(0xFFFF6B35), // Orange vif
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFDAD1),
      onPrimaryContainer: const Color(0xFF3D0900),
      
      secondary: const Color(0xFF775651),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFDAD1),
      onSecondaryContainer: const Color(0xFF2C1512),
      
      tertiary: const Color(0xFF6B5E2F),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFF5E2A7),
      onTertiaryContainer: const Color(0xFF231B00),
      
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      
      surface: const Color(0xFFFFFBFF),
      onSurface: const Color(0xFF201A19),
      surfaceContainerHighest: const Color(0xFFE7E0DE),
      
      outline: const Color(0xFF857370),
      outlineVariant: const Color(0xFFD8C2BE),
      
      shadow: Colors.black,
      scrim: Colors.black,
      
      inverseSurface: const Color(0xFF362F2D),
      onInverseSurface: const Color(0xFFFBEEEB),
      inversePrimary: const Color(0xFFFFB59D),
    );
  }

  /// Retourne le ColorScheme pour le mode sombre
  /// Respecte les contrastes WCAG AA
  ColorScheme _getDarkColorScheme() {
    return ColorScheme.dark(
      primary: const Color(0xFFFFB59D),
      onPrimary: const Color(0xFF5F1600),
      primaryContainer: const Color(0xFF852200),
      onPrimaryContainer: const Color(0xFFFFDAD1),
      
      secondary: const Color(0xFFE7BDB6),
      onSecondary: const Color(0xFF442925),
      secondaryContainer: const Color(0xFF5D3F3B),
      onSecondaryContainer: const Color(0xFFFFDAD1),
      
      tertiary: const Color(0xFFD8C68D),
      onTertiary: const Color(0xFF3B2F05),
      tertiaryContainer: const Color(0xFF52461A),
      onTertiaryContainer: const Color(0xFFF5E2A7),
      
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      
      surface: const Color(0xFF181211),
      onSurface: const Color(0xFFEDE0DD),
      surfaceContainerHighest: const Color(0xFF3A3331),
      
      outline: const Color(0xFFA08C89),
      outlineVariant: const Color(0xFF534341),
      
      shadow: Colors.black,
      scrim: Colors.black,
      
      inverseSurface: const Color(0xFFEDE0DD),
      onInverseSurface: const Color(0xFF362F2D),
      inversePrimary: const Color(0xFFAC3100),
    );
  }

  /// Convertit une chaîne en ThemeMode
  ThemeMode _themeModeFromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Convertit un ThemeMode en chaîne
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Ferme la box Hive
  Future<void> dispose() async {
    await _settingsBox?.close();
  }
}
