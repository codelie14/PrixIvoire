import 'package:flutter/material.dart';

/// Modèle représentant une catégorie de produit
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  /// Liste des catégories prédéfinies
  static const List<Category> predefinedCategories = [
    Category(
      id: 'food',
      name: 'Alimentaire',
      icon: Icons.restaurant,
      color: Color(0xFF4CAF50), // Vert
    ),
    Category(
      id: 'electronics',
      name: 'Électronique',
      icon: Icons.devices,
      color: Color(0xFF2196F3), // Bleu
    ),
    Category(
      id: 'hygiene',
      name: 'Hygiène',
      icon: Icons.clean_hands,
      color: Color(0xFF9C27B0), // Violet
    ),
    Category(
      id: 'clothing',
      name: 'Vêtements',
      icon: Icons.checkroom,
      color: Color(0xFFFF9800), // Orange
    ),
    Category(
      id: 'home',
      name: 'Maison',
      icon: Icons.home,
      color: Color(0xFF795548), // Marron
    ),
    Category(
      id: 'other',
      name: 'Autres',
      icon: Icons.category,
      color: Color(0xFF607D8B), // Gris bleu
    ),
  ];

  /// Récupère une catégorie par son ID
  static Category? getCategoryById(String? id) {
    if (id == null) return null;
    try {
      return predefinedCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Récupère la catégorie "Autres" par défaut
  static Category getDefaultCategory() {
    return predefinedCategories.firstWhere((cat) => cat.id == 'other');
  }

  /// Récupère une catégorie par son ID ou retourne "Autres" si non trouvée
  static Category getCategoryByIdOrDefault(String? id) {
    return getCategoryById(id) ?? getDefaultCategory();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
