/// Base exception class for all application-specific exceptions
/// 
/// All custom exceptions in the PrixIvoire application should extend this class
/// to ensure consistent error handling and logging.
abstract class AppException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// Optional error code for categorization
  final String? code;
  
  /// Original error that caused this exception (if any)
  final dynamic originalError;
  
  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Exception thrown when storage operations fail
/// 
/// This includes Hive database operations, file system access,
/// and any other data persistence operations.
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Exception thrown when OCR (Optical Character Recognition) operations fail
/// 
/// This includes image preprocessing, text extraction, and parsing errors.
class OCRException extends AppException {
  const OCRException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Exception thrown when data validation fails
/// 
/// This includes form validation, data integrity checks, and business rule violations.
class ValidationException extends AppException {
  /// Map of field names to their validation error messages
  final Map<String, String> fieldErrors;
  
  const ValidationException(
    super.message,
    this.fieldErrors, {
    super.code,
    super.originalError,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer(super.toString());
    if (fieldErrors.isNotEmpty) {
      buffer.write('\nField errors:');
      fieldErrors.forEach((field, error) {
        buffer.write('\n  - $field: $error');
      });
    }
    return buffer.toString();
  }
}

/// Exception thrown when network operations fail
/// 
/// This includes HTTP requests, connectivity issues, and timeout errors.
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// Exception thrown when export operations fail
/// 
/// This includes CSV, PDF, Excel generation, and file writing errors.
class ExportException extends AppException {
  const ExportException(
    super.message, {
    super.code,
    super.originalError,
  });
}
