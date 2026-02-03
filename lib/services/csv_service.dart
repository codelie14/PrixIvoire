import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product_price.dart';
import '../models/price_alert.dart';

class CSVService {
  // Exporter les prix en CSV
  Future<File> exportProductPricesToCSV(List<ProductPrice> prices) async {
    final List<List<dynamic>> rows = [
      ['Nom du produit', 'Prix (FCFA)', 'Magasin', 'Date'],
    ];

    for (final price in prices) {
      rows.add([
        price.productName,
        price.price.toStringAsFixed(0),
        price.shop,
        price.date.toIso8601String(),
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/prixivoire_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);
    return file;
  }

  // Importer les prix depuis un CSV
  Future<List<ProductPrice>> importProductPricesFromCSV(File file) async {
    final csvString = await file.readAsString();
    final rows = const CsvToListConverter().convert(csvString);

    final List<ProductPrice> prices = [];

    // Ignorer la première ligne (en-têtes)
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length >= 4) {
        try {
          final productName = row[0].toString();
          final price = double.tryParse(row[1].toString()) ?? 0.0;
          final shop = row[2].toString();
          final dateStr = row[3].toString();
          final date = DateTime.tryParse(dateStr) ?? DateTime.now();

          prices.add(ProductPrice(
            productName: productName,
            price: price,
            shop: shop,
            date: date,
          ));
        } catch (e) {
          // Ignorer les lignes invalides
          continue;
        }
      }
    }

    return prices;
  }

  // Exporter les alertes en CSV
  Future<File> exportPriceAlertsToCSV(List<PriceAlert> alerts) async {
    final List<List<dynamic>> rows = [
      ['Nom du produit', 'Seuil (FCFA)', 'Type (Au-dessus/En-dessous)'],
    ];

    for (final alert in alerts) {
      rows.add([
        alert.productName,
        alert.threshold.toStringAsFixed(0),
        alert.isAbove ? 'Au-dessus' : 'En-dessous',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/prixivoire_alertes_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);
    return file;
  }
}
