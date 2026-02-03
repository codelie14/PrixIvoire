import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_price.dart';
import '../models/price_alert.dart';

class StorageService {
  static const String _productPriceBoxName = 'productPrices';
  static const String _priceAlertBoxName = 'priceAlerts';

  late Box<ProductPrice> _productPriceBox;
  late Box<PriceAlert> _priceAlertBox;

  Future<void> init() async {
    // Les adaptateurs doivent être enregistrés dans main.dart avant d'appeler init()
    // Ouvrir les boîtes
    _productPriceBox = await Hive.openBox<ProductPrice>(_productPriceBoxName);
    _priceAlertBox = await Hive.openBox<PriceAlert>(_priceAlertBoxName);
  }

  // Méthodes pour ProductPrice
  Future<void> addProductPrice(ProductPrice productPrice) async {
    await _productPriceBox.add(productPrice);
  }

  Future<void> deleteProductPrice(ProductPrice productPrice) async {
    await productPrice.delete();
  }

  List<ProductPrice> getAllProductPrices() {
    return _productPriceBox.values.toList();
  }

  List<ProductPrice> getProductPricesByProduct(String productName) {
    return _productPriceBox.values
        .where((price) => price.productName == productName)
        .toList();
  }

  List<ProductPrice> getProductPricesByShop(String shop) {
    return _productPriceBox.values
        .where((price) => price.shop == shop)
        .toList();
  }

  List<String> getAllProductNames() {
    return _productPriceBox.values
        .map((price) => price.productName)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getAllShops() {
    return _productPriceBox.values
        .map((price) => price.shop)
        .toSet()
        .toList()
      ..sort();
  }

  // Méthodes pour PriceAlert
  Future<void> addPriceAlert(PriceAlert alert) async {
    await _priceAlertBox.add(alert);
  }

  Future<void> deletePriceAlert(PriceAlert alert) async {
    await alert.delete();
  }

  List<PriceAlert> getAllPriceAlerts() {
    return _priceAlertBox.values.toList();
  }

  List<PriceAlert> getPriceAlertsByProduct(String productName) {
    return _priceAlertBox.values
        .where((alert) => alert.productName == productName)
        .toList();
  }

  // Nettoyer les données anciennes (plus de 6 mois)
  Future<void> cleanOldData() async {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final toDelete = _productPriceBox.values
        .where((price) => price.date.isBefore(sixMonthsAgo))
        .toList();

    for (final price in toDelete) {
      await price.delete();
    }
  }
}
