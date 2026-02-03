import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/product_price.dart';
import 'storage_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StorageService _storageService;

  NotificationService(this._storageService);

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Demander les permissions pour Android 13+
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer le tap sur la notification si nécessaire
  }

  Future<void> checkPriceAlerts(ProductPrice newPrice) async {
    final alerts = _storageService.getPriceAlertsByProduct(newPrice.productName);

    for (final alert in alerts) {
      bool shouldNotify = false;
      String message = '';

      if (alert.isAbove && newPrice.price > alert.threshold) {
        shouldNotify = true;
        message =
            '${newPrice.productName} : Prix au-dessus du seuil (${newPrice.price.toStringAsFixed(0)} FCFA > ${alert.threshold.toStringAsFixed(0)} FCFA)';
      } else if (!alert.isAbove && newPrice.price < alert.threshold) {
        shouldNotify = true;
        message =
            '${newPrice.productName} : Prix en-dessous du seuil (${newPrice.price.toStringAsFixed(0)} FCFA < ${alert.threshold.toStringAsFixed(0)} FCFA)';
      }

      if (shouldNotify) {
        await showNotification(
          title: 'Alerte Prix',
          body: message,
        );
      }
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'price_alerts',
      'Alertes de Prix',
      channelDescription: 'Notifications pour les alertes de prix',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }
}
