import 'package:flutter/foundation.dart';
import 'app_exception.dart';

/// Centralized error handler for the application
/// 
/// Provides user-friendly error messages in French and logging capabilities
/// for all types of exceptions that can occur in the application.
class ErrorHandler {
  /// Converts an exception to a user-friendly message in French
  /// 
  /// Takes any [Exception] and returns a localized, human-readable
  /// error message that can be displayed to the user.
  static String getUserFriendlyMessage(Exception error) {
    if (error is StorageException) {
      return _getStorageErrorMessage(error);
    } else if (error is OCRException) {
      return _getOCRErrorMessage(error);
    } else if (error is ValidationException) {
      return _getValidationErrorMessage(error);
    } else if (error is NetworkException) {
      return _getNetworkErrorMessage(error);
    } else if (error is ExportException) {
      return _getExportErrorMessage(error);
    }
    return "Une erreur inattendue s'est produite. Veuillez réessayer.";
  }
  
  /// Returns a user-friendly message for storage exceptions
  static String _getStorageErrorMessage(StorageException error) {
    switch (error.code) {
      case 'STORAGE_FULL':
        return "Espace de stockage insuffisant. Supprimez des anciennes données pour libérer de l'espace.";
      case 'PERMISSION_DENIED':
        return "Permission refusée. Vérifiez les autorisations de l'application dans les paramètres.";
      case 'DATABASE_CORRUPTED':
        return "La base de données est corrompue. L'application va tenter de la réparer.";
      case 'WRITE_FAILED':
        return "Impossible d'enregistrer les données. Vérifiez l'espace de stockage disponible.";
      case 'READ_FAILED':
        return "Impossible de lire les données. La base de données pourrait être corrompue.";
      case 'DELETE_FAILED':
        return "Impossible de supprimer les données. Veuillez réessayer.";
      default:
        return "Erreur de stockage: ${error.message}";
    }
  }
  
  /// Returns a user-friendly message for OCR exceptions
  static String _getOCRErrorMessage(OCRException error) {
    switch (error.code) {
      case 'NO_TEXT_FOUND':
        return "Aucun texte détecté. Assurez-vous que l'image est claire et bien éclairée.";
      case 'POOR_QUALITY':
        return "Qualité d'image insuffisante. Essayez avec une meilleure photo ou améliorez l'éclairage.";
      case 'IMAGE_TOO_LARGE':
        return "L'image est trop volumineuse. Veuillez utiliser une image de moins de 5 MB.";
      case 'INVALID_IMAGE':
        return "Format d'image invalide. Utilisez une image JPEG ou PNG.";
      case 'PROCESSING_FAILED':
        return "Échec du traitement de l'image. Veuillez réessayer avec une autre photo.";
      case 'NO_PRICES_FOUND':
        return "Aucun prix détecté dans l'image. Assurez-vous que les prix sont clairement visibles.";
      default:
        return "Erreur de reconnaissance de texte: ${error.message}";
    }
  }
  
  /// Returns a user-friendly message for validation exceptions
  static String _getValidationErrorMessage(ValidationException error) {
    // Return the first field error message if available
    if (error.fieldErrors.isNotEmpty) {
      return error.fieldErrors.values.first;
    }
    return error.message;
  }
  
  /// Returns a user-friendly message for network exceptions
  static String _getNetworkErrorMessage(NetworkException error) {
    switch (error.code) {
      case 'NO_CONNECTION':
        return "Aucune connexion internet. Vérifiez votre connexion et réessayez.";
      case 'TIMEOUT':
        return "La connexion a expiré. Vérifiez votre connexion internet et réessayez.";
      case 'SERVER_ERROR':
        return "Erreur du serveur. Veuillez réessayer plus tard.";
      case 'NOT_FOUND':
        return "Ressource introuvable. Veuillez réessayer.";
      default:
        return "Erreur de connexion. Vérifiez votre connexion internet.";
    }
  }
  
  /// Returns a user-friendly message for export exceptions
  static String _getExportErrorMessage(ExportException error) {
    switch (error.code) {
      case 'INSUFFICIENT_SPACE':
        return "Espace de stockage insuffisant. Libérez de l'espace et réessayez.";
      case 'PERMISSION_DENIED':
        return "Permission refusée. Autorisez l'accès au stockage dans les paramètres.";
      case 'INVALID_FORMAT':
        return "Format d'export invalide. Veuillez choisir un autre format.";
      case 'GENERATION_FAILED':
        return "Échec de la génération du fichier. Veuillez réessayer.";
      case 'NO_DATA':
        return "Aucune donnée à exporter. Ajoutez des prix avant d'exporter.";
      default:
        return "Erreur lors de l'export: ${error.message}";
    }
  }
  
  /// Logs an error with context information
  /// 
  /// In development mode, prints to console.
  /// In production, this should send to a logging service (Firebase Crashlytics, Sentry, etc.)
  /// 
  /// Parameters:
  /// - [error]: The exception that occurred
  /// - [stackTrace]: The stack trace at the point of the error
  /// - [context]: Optional additional context information (e.g., user action, screen name)
  static void logError(
    Exception error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    
    // In development, print to console
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('ERROR LOGGED AT: $timestamp');
      debugPrint('ERROR TYPE: ${error.runtimeType}');
      debugPrint('ERROR MESSAGE: $error');
      
      if (context != null && context.isNotEmpty) {
        debugPrint('CONTEXT:');
        context.forEach((key, value) {
          debugPrint('  $key: $value');
        });
      }
      
      debugPrint('STACK TRACE:');
      debugPrint(stackTrace.toString());
      debugPrint('═══════════════════════════════════════════════════════');
    }
    
    // In production, send to logging service
    // TODO: Integrate with Firebase Crashlytics or Sentry
    // Example:
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, context: context);
  }
  
  /// Logs an error with a custom message and context
  /// 
  /// Useful for logging errors that don't have an exception object
  static void logMessage(
    String message, {
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('LOG MESSAGE AT: $timestamp');
      debugPrint('MESSAGE: $message');
      
      if (context != null && context.isNotEmpty) {
        debugPrint('CONTEXT:');
        context.forEach((key, value) {
          debugPrint('  $key: $value');
        });
      }
      
      if (stackTrace != null) {
        debugPrint('STACK TRACE:');
        debugPrint(stackTrace.toString());
      }
      debugPrint('═══════════════════════════════════════════════════════');
    }
    
    // In production, send to logging service
    // TODO: Integrate with Firebase Crashlytics or Sentry
  }
}
