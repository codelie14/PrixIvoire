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

  @HiveField(4)
  final String? categoryId; // ID de la catégorie (ex: "food", "electronics")

  @HiveField(5)
  final bool isFavorite; // Indique si le produit est marqué comme favori

  @HiveField(6)
  final String? notes; // Notes optionnelles de l'utilisateur

  @HiveField(7)
  final String? imageUrl; // URL ou chemin de l'image du ticket scanné

  ProductPrice({
    required this.productName,
    required this.price,
    required this.shop,
    required this.date,
    this.categoryId,
    this.isFavorite = false,
    this.notes,
    this.imageUrl,
  });

  // Méthode pour créer une copie avec des modifications
  ProductPrice copyWith({
    String? productName,
    double? price,
    String? shop,
    DateTime? date,
    String? categoryId,
    bool? isFavorite,
    String? notes,
    String? imageUrl,
  }) {
    return ProductPrice(
      productName: productName ?? this.productName,
      price: price ?? this.price,
      shop: shop ?? this.shop,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'shop': shop,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'isFavorite': isFavorite,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  factory ProductPrice.fromMap(Map<String, dynamic> map) {
    return ProductPrice(
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      shop: map['shop'] ?? '',
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      isFavorite: map['isFavorite'] ?? false,
      notes: map['notes'],
      imageUrl: map['imageUrl'],
    );
  }
}
