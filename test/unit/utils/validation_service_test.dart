import 'package:flutter_test/flutter_test.dart';
import 'package:prixivoire/core/utils/validation_service.dart';

void main() {
  late ValidationService validationService;

  setUp(() {
    validationService = ValidationService();
  });

  group('ValidationService - validatePrice', () {
    test('should return success for valid price', () {
      final result = validationService.validatePrice('1000');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return success for valid price with decimals', () {
      final result = validationService.validatePrice('1000.50');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return error for empty price', () {
      final result = validationService.validatePrice('');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le prix ne peut pas être vide');
    });

    test('should return error for whitespace-only price', () {
      final result = validationService.validatePrice('   ');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le prix ne peut pas être vide');
    });

    test('should return error for non-numeric price', () {
      final result = validationService.validatePrice('abc');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le prix doit être un nombre valide');
    });

    test('should return error for negative price', () {
      final result = validationService.validatePrice('-100');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le prix doit être supérieur à 0');
    });

    test('should return error for zero price', () {
      final result = validationService.validatePrice('0');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le prix doit être supérieur à 0');
    });

    test('should return error for price exceeding 10 million', () {
      final result = validationService.validatePrice('10000001');
      expect(result.isValid, false);
      expect(
        result.errorMessage,
        'Le prix ne peut pas dépasser 10 000 000 FCFA',
      );
    });

    test('should return success for price exactly 10 million', () {
      final result = validationService.validatePrice('10000000');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return error for more than 2 decimals', () {
      final result = validationService.validatePrice('100.123');
      expect(result.isValid, false);
      expect(
        result.errorMessage,
        'Le prix ne peut avoir que 2 décimales maximum',
      );
    });

    test('should return success for price with 1 decimal', () {
      final result = validationService.validatePrice('100.5');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return success for price with 2 decimals', () {
      final result = validationService.validatePrice('100.99');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('ValidationService - validateProductName', () {
    test('should return success for valid product name', () {
      final result = validationService.validateProductName('Riz');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return success for product name with spaces', () {
      final result = validationService.validateProductName('Riz Basmati');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return error for empty product name', () {
      final result = validationService.validateProductName('');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le nom du produit ne peut pas être vide');
    });

    test('should return error for whitespace-only product name', () {
      final result = validationService.validateProductName('   ');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le nom du produit ne peut pas être vide');
    });

    test('should return error for product name with less than 2 characters', () {
      final result = validationService.validateProductName('A');
      expect(result.isValid, false);
      expect(
        result.errorMessage,
        'Le nom du produit doit contenir au moins 2 caractères',
      );
    });

    test('should return success for product name with exactly 2 characters', () {
      final result = validationService.validateProductName('AB');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return error for product name exceeding 100 characters', () {
      final longName = 'A' * 101;
      final result = validationService.validateProductName(longName);
      expect(result.isValid, false);
      expect(
        result.errorMessage,
        'Le nom du produit ne peut pas dépasser 100 caractères',
      );
    });

    test('should return success for product name with exactly 100 characters', () {
      final longName = 'A' * 100;
      final result = validationService.validateProductName(longName);
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should trim whitespace before validation', () {
      final result = validationService.validateProductName('  Riz  ');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('ValidationService - validateStoreName', () {
    test('should return success for valid store name', () {
      final result = validationService.validateStoreName('Carrefour');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return success for store name with spaces', () {
      final result = validationService.validateStoreName('Super U');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should return error for empty store name', () {
      final result = validationService.validateStoreName('');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le nom du magasin ne peut pas être vide');
    });

    test('should return error for whitespace-only store name', () {
      final result = validationService.validateStoreName('   ');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Le nom du magasin ne peut pas être vide');
    });

    test('should return error for store name exceeding 50 characters', () {
      final longName = 'A' * 51;
      final result = validationService.validateStoreName(longName);
      expect(result.isValid, false);
      expect(
        result.errorMessage,
        'Le nom du magasin ne peut pas dépasser 50 caractères',
      );
    });

    test('should return success for store name with exactly 50 characters', () {
      final longName = 'A' * 50;
      final result = validationService.validateStoreName(longName);
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should trim whitespace before validation', () {
      final result = validationService.validateStoreName('  Carrefour  ');
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('ValidationResult', () {
    test('success factory should create valid result', () {
      final result = ValidationResult.success();
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('error factory should create invalid result with message', () {
      final result = ValidationResult.error('Test error');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Test error');
    });
  });
}
