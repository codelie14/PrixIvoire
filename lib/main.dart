import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'adapters/product_price_adapter.dart';
import 'adapters/price_alert_adapter.dart';
import 'adapters/search_history_adapter.dart';
import 'adapters/app_settings_adapter.dart';
import 'services/cache_service.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive
  await Hive.initFlutter();

  // Enregistrer les adaptateurs Hive
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductPriceAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PriceAlertAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SearchHistoryAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(AppSettingsAdapter());
  }

  // Initialiser les services
  final storageService = StorageService();
  await storageService.init();

  final cacheService = CacheService();
  await cacheService.init();
  await cacheService.cleanExpiredCache();

  final notificationService = NotificationService(storageService);
  await notificationService.init();

  // Nettoyer les données anciennes
  await storageService.cleanOldData();

  // Initialiser le ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: PrixIvoireApp(
        storageService: storageService,
        notificationService: notificationService,
        cacheService: cacheService,
      ),
    ),
  );
}

class PrixIvoireApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;
  final CacheService cacheService;

  const PrixIvoireApp({
    super.key,
    required this.storageService,
    required this.notificationService,
    required this.cacheService,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'PrixIvoire',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: HomeScreen(
            storageService: storageService,
            cacheService: cacheService,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
