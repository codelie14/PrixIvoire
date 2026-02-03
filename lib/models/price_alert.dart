import 'package:hive/hive.dart';

// part 'price_alert.g.dart'; // Décommenter après génération avec build_runner

@HiveType(typeId: 1)
class PriceAlert extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final double threshold; // Seuil de prix (ex: 12000 FCFA)

  @HiveField(2)
  final bool isAbove; // True = alerte si prix > seuil, False = alerte si prix < seuil

  PriceAlert({
    required this.productName,
    required this.threshold,
    required this.isAbove,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'threshold': threshold,
      'isAbove': isAbove,
    };
  }

  factory PriceAlert.fromMap(Map<String, dynamic> map) {
    return PriceAlert(
      productName: map['productName'] ?? '',
      threshold: (map['threshold'] ?? 0.0).toDouble(),
      isAbove: map['isAbove'] ?? false,
    );
  }
}
