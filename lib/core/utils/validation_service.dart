/// Service de validation des données utilisateur
///
/// Fournit des méthodes de validation pour les différents champs de saisie
/// de l'application PrixIvoire.
class ValidationService {
  /// Valide un prix saisi par l'utilisateur
  ///
  /// Règles de validation:
  /// - Doit être un nombre valide
  /// - Doit être positif (> 0)
  /// - Maximum: 10 000 000 FCFA
  /// - Maximum 2 décimales
  ///
  /// Retourne un [ValidationResult] avec isValid et errorMessage
  ValidationResult validatePrice(String input) {
    // Vérifier que l'entrée n'est pas vide
    if (input.trim().isEmpty) {
      return ValidationResult.error('Le prix ne peut pas être vide');
    }

    // Tenter de parser le nombre
    final double? price = double.tryParse(input.trim());

    // Vérifier que c'est un nombre valide
    if (price == null) {
      return ValidationResult.error('Le prix doit être un nombre valide');
    }

    // Vérifier que le prix est positif
    if (price <= 0) {
      return ValidationResult.error('Le prix doit être supérieur à 0');
    }

    // Vérifier le maximum (10 000 000 FCFA)
    if (price > 10000000) {
      return ValidationResult.error(
        'Le prix ne peut pas dépasser 10 000 000 FCFA',
      );
    }

    // Vérifier le nombre de décimales (maximum 2)
    final parts = input.trim().split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return ValidationResult.error(
        'Le prix ne peut avoir que 2 décimales maximum',
      );
    }

    return ValidationResult.success();
  }

  /// Valide un nom de produit saisi par l'utilisateur
  ///
  /// Règles de validation:
  /// - Non vide
  /// - Minimum 2 caractères
  /// - Maximum 100 caractères
  ///
  /// Retourne un [ValidationResult] avec isValid et errorMessage
  ValidationResult validateProductName(String input) {
    final trimmed = input.trim();

    // Vérifier que le nom n'est pas vide
    if (trimmed.isEmpty) {
      return ValidationResult.error('Le nom du produit ne peut pas être vide');
    }

    // Vérifier la longueur minimale
    if (trimmed.length < 2) {
      return ValidationResult.error(
        'Le nom du produit doit contenir au moins 2 caractères',
      );
    }

    // Vérifier la longueur maximale
    if (trimmed.length > 100) {
      return ValidationResult.error(
        'Le nom du produit ne peut pas dépasser 100 caractères',
      );
    }

    return ValidationResult.success();
  }

  /// Valide un nom de magasin saisi par l'utilisateur
  ///
  /// Règles de validation:
  /// - Non vide
  /// - Maximum 50 caractères
  ///
  /// Retourne un [ValidationResult] avec isValid et errorMessage
  ValidationResult validateStoreName(String input) {
    final trimmed = input.trim();

    // Vérifier que le nom n'est pas vide
    if (trimmed.isEmpty) {
      return ValidationResult.error('Le nom du magasin ne peut pas être vide');
    }

    // Vérifier la longueur maximale
    if (trimmed.length > 50) {
      return ValidationResult.error(
        'Le nom du magasin ne peut pas dépasser 50 caractères',
      );
    }

    return ValidationResult.success();
  }
}

/// Résultat d'une validation
///
/// Contient un indicateur de validité et un message d'erreur optionnel
class ValidationResult {
  /// Indique si la validation a réussi
  final bool isValid;

  /// Message d'erreur en cas d'échec de validation
  final String? errorMessage;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  /// Crée un résultat de validation réussi
  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  /// Crée un résultat de validation échoué avec un message d'erreur
  factory ValidationResult.error(String message) {
    return ValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}
