import 'package:flutter/material.dart';
import 'theme_manager.dart';

/// Provider pour gérer l'état du thème de l'application
/// 
/// Utilise ChangeNotifier pour notifier les widgets des changements de thème
class ThemeProvider extends ChangeNotifier {
  final ThemeManager _themeManager = ThemeManager();
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Initialise le provider en chargeant le thème sauvegardé
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _themeMode = await _themeManager.loadTheme();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du thème: $e');
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Change le mode de thème et le sauvegarde
  /// 
  /// [mode] Le nouveau mode de thème
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    try {
      // Mettre à jour l'état immédiatement pour un feedback rapide
      _themeMode = mode;
      notifyListeners();
      
      // Sauvegarder de manière asynchrone
      await _themeManager.setTheme(mode);
    } catch (e) {
      debugPrint('Erreur lors du changement de thème: $e');
      // En cas d'erreur, on garde le nouveau thème en mémoire
      // mais on informe l'utilisateur que la sauvegarde a échoué
      rethrow;
    }
  }

  /// Retourne le ThemeData pour le mode clair
  ThemeData get lightTheme => _themeManager.getLightTheme();

  /// Retourne le ThemeData pour le mode sombre
  ThemeData get darkTheme => _themeManager.getDarkTheme();

  /// Nettoie les ressources
  @override
  void dispose() {
    _themeManager.dispose();
    super.dispose();
  }
}
