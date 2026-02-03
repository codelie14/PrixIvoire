import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'adapters/product_price_adapter.dart';
import 'adapters/price_alert_adapter.dart';

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

  // Initialiser les services
  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService(storageService);
  await notificationService.init();

  // Nettoyer les données anciennes
  await storageService.cleanOldData();

  runApp(PrixIvoireApp(
    storageService: storageService,
    notificationService: notificationService,
  ));
}

class PrixIvoireApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;

  const PrixIvoireApp({
    super.key,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrixIvoire',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: HomeScreen(storageService: storageService),
      debugShowCheckedModeBanner: false,
    );
  }
}
