import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'adapters/product_price_adapter.dart';
import 'adapters/price_alert_adapter.dart';
import 'adapters/search_history_adapter.dart';
import 'services/cache_service.dart';

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

  runApp(PrixIvoireApp(
    storageService: storageService,
    notificationService: notificationService,
    cacheService: cacheService,
  ));
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
    return MaterialApp(
      title: 'PrixIvoire',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: HomeScreen(
        storageService: storageService,
        cacheService: cacheService,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
