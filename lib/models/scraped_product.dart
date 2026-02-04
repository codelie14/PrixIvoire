class ScrapedProduct {
  final String name;
  final double? price;
  final String shop; // Nom du site/magasin en ligne
  final String? imageUrl;
  final String? productUrl;
  final DateTime scrapedAt;

  ScrapedProduct({
    required this.name,
    this.price,
    required this.shop,
    this.imageUrl,
    this.productUrl,
    DateTime? scrapedAt,
  }) : scrapedAt = scrapedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'shop': shop,
      'imageUrl': imageUrl,
      'productUrl': productUrl,
      'scrapedAt': scrapedAt.toIso8601String(),
    };
  }

  factory ScrapedProduct.fromMap(Map<String, dynamic> map) {
    return ScrapedProduct(
      name: map['name'] ?? '',
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      shop: map['shop'] ?? '',
      imageUrl: map['imageUrl'],
      productUrl: map['productUrl'],
      scrapedAt: map['scrapedAt'] != null
          ? DateTime.parse(map['scrapedAt'])
          : DateTime.now(),
    );
  }
}
