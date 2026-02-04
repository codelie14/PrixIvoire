// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prixivoire/main.dart';
import 'package:prixivoire/services/storage_service.dart';
import 'package:prixivoire/services/notification_service.dart';
import 'package:prixivoire/services/cache_service.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Initialiser Hive pour les tests
    await Hive.initFlutter();
    
    // Initialiser les services
    final storageService = StorageService();
    await storageService.init();
    
    final notificationService = NotificationService(storageService);
    await notificationService.init();

    final cacheService = CacheService();
    await cacheService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      PrixIvoireApp(
        storageService: storageService,
        notificationService: notificationService,
        cacheService: cacheService,
      ),
    );

    // Vérifier que l'application se construit correctement
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
