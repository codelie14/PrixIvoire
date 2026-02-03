import 'package:hive/hive.dart';

// part 'product_price.g.dart'; // Décommenter après génération avec build_runner

@HiveType(typeId: 0)
class ProductPrice extends HiveObject {
  @HiveField(0)
  final String productName; // Nom du produit (ex: "Riz 25kg")

  @HiveField(1)
  final double price; // Prix en FCFA

  @HiveField(2)
  final String shop; // Magasin ou marché (ex: "Carrefour", "Marché d'Adjamé")

  @HiveField(3)
  final DateTime date; // Date de la saisie

  ProductPrice({
    required this.productName,
    required this.price,
    required this.shop,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'shop': shop,
      'date': date.toIso8601String(),
    };
  }

  factory ProductPrice.fromMap(Map<String, dynamic> map) {
    return ProductPrice(
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      shop: map['shop'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }
}
