import 'package:hive/hive.dart';

// part 'app_settings.g.dart'; // Décommenter après génération avec build_runner

@HiveType(typeId: 10)
class AppSettings extends HiveObject {
  @HiveField(0)
  String themeMode; // 'light', 'dark', 'system'

  @HiveField(1)
  bool onboardingCompleted;

  @HiveField(2)
  List<String> viewedTooltips;

  @HiveField(3)
  String defaultCurrency;

  @HiveField(4)
  int maxHistoryEntries;

  @HiveField(5)
  bool enableNotifications;

  AppSettings({
    this.themeMode = 'system',
    this.onboardingCompleted = false,
    List<String>? viewedTooltips,
    this.defaultCurrency = 'FCFA',
    this.maxHistoryEntries = 1000,
    this.enableNotifications = true,
  }) : viewedTooltips = viewedTooltips ?? [];

  /// Crée une instance avec les paramètres par défaut
  factory AppSettings.defaultSettings() {
    return AppSettings(
      themeMode: 'system',
      onboardingCompleted: false,
      viewedTooltips: [],
      defaultCurrency: 'FCFA',
      maxHistoryEntries: 1000,
      enableNotifications: true,
    );
  }

  /// Marque l'onboarding comme complété
  void markOnboardingComplete() {
    onboardingCompleted = true;
    save();
  }

  /// Marque un tooltip comme vu
  void markTooltipViewed(String tooltipId) {
    if (!viewedTooltips.contains(tooltipId)) {
      viewedTooltips.add(tooltipId);
      save();
    }
  }

  /// Vérifie si un tooltip a été vu
  bool hasViewedTooltip(String tooltipId) {
    return viewedTooltips.contains(tooltipId);
  }

  /// Met à jour le mode de thème
  void updateThemeMode(String mode) {
    if (['light', 'dark', 'system'].contains(mode)) {
      themeMode = mode;
      save();
    }
  }

  /// Crée une copie avec des modifications
  AppSettings copyWith({
    String? themeMode,
    bool? onboardingCompleted,
    List<String>? viewedTooltips,
    String? defaultCurrency,
    int? maxHistoryEntries,
    bool? enableNotifications,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      viewedTooltips: viewedTooltips ?? List.from(this.viewedTooltips),
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      maxHistoryEntries: maxHistoryEntries ?? this.maxHistoryEntries,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode,
      'onboardingCompleted': onboardingCompleted,
      'viewedTooltips': viewedTooltips,
      'defaultCurrency': defaultCurrency,
      'maxHistoryEntries': maxHistoryEntries,
      'enableNotifications': enableNotifications,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: map['themeMode'] ?? 'system',
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      viewedTooltips: List<String>.from(map['viewedTooltips'] ?? []),
      defaultCurrency: map['defaultCurrency'] ?? 'FCFA',
      maxHistoryEntries: map['maxHistoryEntries'] ?? 1000,
      enableNotifications: map['enableNotifications'] ?? true,
    );
  }
}
