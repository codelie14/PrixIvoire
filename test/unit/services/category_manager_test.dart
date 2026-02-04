import 'package:flutter_test/flutter_test.dart';
import 'package:prixivoire/services/category_manager.dart';
import 'package:prixivoire/models/category.dart';
import 'package:prixivoire/models/product_price.dart';

void main() {
  group('CategoryManager', () {
    late CategoryManager categoryManager;

    setUp(() {
      categoryManager = CategoryManager();
    });

    test('getAllCategories returns all predefined categories', () {
      final categories = categoryManager.getAllCategories();
      
      expect(categories.length, 6);
      expect(categories.any((c) => c.id == 'food'), true);
      expect(categories.any((c) => c.id == 'electronics'), true);
      expect(categories.any((c) => c.id == 'hygiene'), true);
      expect(categories.any((c) => c.id == 'clothing'), true);
      expect(categories.any((c) => c.id == 'home'), true);
      expect(categories.any((c) => c.id == 'other'), true);
    });

    test('getCategoryById returns correct category', () {
      final category = categoryManager.getCategoryById('food');
      
      expect(category, isNotNull);
      expect(category!.id, 'food');
      expect(category.name, 'Alimentaire');
    });

    test('getCategoryById returns null for invalid id', () {
      final category = categoryManager.getCategoryById('invalid');
      
      expect(category, isNull);
    });

    test('getCategoryByIdOrDefault returns default for null', () {
      final category = categoryManager.getCategoryByIdOrDefault(null);
      
      expect(category.id, 'other');
      expect(category.name, 'Autres');
    });

    test('getCategoryByIdOrDefault returns default for invalid id', () {
      final category = categoryManager.getCategoryByIdOrDefault('invalid');
      
      expect(category.id, 'other');
      expect(category.name, 'Autres');
    });

    test('filterByCategory filters products correctly', () {
      final prices = [
        ProductPrice(
          productName: 'Riz',
          price: 1000,
          shop: 'Shop A',
          date: DateTime.now(),
          categoryId: 'food',
        ),
        ProductPrice(
          productName: 'TV',
          price: 50000,
          shop: 'Shop B',
          date: DateTime.now(),
          categoryId: 'electronics',
        ),
        ProductPrice(
          productName: 'Pain',
          price: 200,
          shop: 'Shop C',
          date: DateTime.now(),
          categoryId: 'food',
        ),
      ];

      final filtered = categoryManager.filterByCategory(prices, 'food');
      
      expect(filtered.length, 2);
      expect(filtered.every((p) => p.categoryId == 'food'), true);
    });

    test('filterByCategory includes null categories in "other"', () {
      final prices = [
        ProductPrice(
          productName: 'Product 1',
          price: 1000,
          shop: 'Shop A',
          date: DateTime.now(),
          categoryId: null,
        ),
        ProductPrice(
          productName: 'Product 2',
          price: 2000,
          shop: 'Shop B',
          date: DateTime.now(),
          categoryId: 'other',
        ),
        ProductPrice(
          productName: 'Product 3',
          price: 3000,
          shop: 'Shop C',
          date: DateTime.now(),
          categoryId: 'food',
        ),
      ];

      final filtered = categoryManager.filterByCategory(prices, 'other');
      
      expect(filtered.length, 2);
      expect(filtered.any((p) => p.categoryId == null), true);
      expect(filtered.any((p) => p.categoryId == 'other'), true);
    });

    test('getCategoryCounts returns correct counts', () {
      final prices = [
        ProductPrice(
          productName: 'Riz',
          price: 1000,
          shop: 'Shop A',
          date: DateTime.now(),
          categoryId: 'food',
        ),
        ProductPrice(
          productName: 'TV',
          price: 50000,
          shop: 'Shop B',
          date: DateTime.now(),
          categoryId: 'electronics',
        ),
        ProductPrice(
          productName: 'Pain',
          price: 200,
          shop: 'Shop C',
          date: DateTime.now(),
          categoryId: 'food',
        ),
        ProductPrice(
          productName: 'Product',
          price: 500,
          shop: 'Shop D',
          date: DateTime.now(),
          categoryId: null,
        ),
      ];

      final counts = categoryManager.getCategoryCounts(prices);
      
      expect(counts['food'], 2);
      expect(counts['electronics'], 1);
      expect(counts['other'], 1);
      expect(counts['hygiene'], 0);
      expect(counts['clothing'], 0);
      expect(counts['home'], 0);
    });

    test('getProductNamesForCategory returns unique sorted names', () {
      final prices = [
        ProductPrice(
          productName: 'Riz',
          price: 1000,
          shop: 'Shop A',
          date: DateTime.now(),
          categoryId: 'food',
        ),
        ProductPrice(
          productName: 'Pain',
          price: 200,
          shop: 'Shop B',
          date: DateTime.now(),
          categoryId: 'food',
        ),
        ProductPrice(
          productName: 'Riz',
          price: 1100,
          shop: 'Shop C',
          date: DateTime.now(),
          categoryId: 'food',
        ),
      ];

      final names = categoryManager.getProductNamesForCategory(prices, 'food');
      
      expect(names.length, 2);
      expect(names, ['Pain', 'Riz']);
    });

    test('getMostUsedCategory returns category with most products', () {
      final prices = [
        ProductPrice(
          productName: 'Riz',
          price: 1000,
          shop: 'Shop A',
          date: DateTime.now(),
          categoryId: 'food',
        ),
        ProductPrice(
          productName: 'Pain',
          price: 200,
          shop: 'Shop B',
          date: DateTime.now(),
          categoryId: 'food',
        ),
        ProductPrice(
          productName: 'TV',
          price: 50000,
          shop: 'Shop C',
          date: DateTime.now(),
          categoryId: 'electronics',
        ),
      ];

      final category = categoryManager.getMostUsedCategory(prices);
      
      expect(category, isNotNull);
      expect(category!.id, 'food');
    });

    test('getMostUsedCategory returns null for empty list', () {
      final category = categoryManager.getMostUsedCategory([]);
      
      expect(category, isNull);
    });

    test('categoryExists returns true for valid category', () {
      expect(categoryManager.categoryExists('food'), true);
      expect(categoryManager.categoryExists('electronics'), true);
    });

    test('categoryExists returns false for invalid category', () {
      expect(categoryManager.categoryExists('invalid'), false);
      expect(categoryManager.categoryExists(null), false);
    });
  });
}
