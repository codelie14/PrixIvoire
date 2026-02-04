import 'package:flutter/material.dart';
import '../errors/error_handler.dart';

/// Utility class for safely executing operations with error handling
/// 
/// Wraps operations in try-catch blocks, handles loading indicators,
/// and displays user-friendly error messages via SnackBars.
class SafeExecutor {
  /// Executes an asynchronous operation with comprehensive error handling
  /// 
  /// This method wraps the provided [action] in a try-catch block and:
  /// - Shows/hides a loading indicator if [showLoading] is true
  /// - Displays a success message via SnackBar if [successMessage] is provided
  /// - Displays an error message via SnackBar if an exception occurs
  /// - Logs all errors with context information
  /// - Provides a retry option for failed operations
  /// 
  /// Parameters:
  /// - [action]: The asynchronous operation to execute
  /// - [context]: BuildContext for showing SnackBars and dialogs
  /// - [successMessage]: Optional message to display on success
  /// - [showLoading]: Whether to show a loading indicator (default: true)
  /// - [onError]: Optional callback to execute when an error occurs
  /// - [retryable]: Whether to show a retry button in error SnackBar (default: true)
  /// 
  /// Returns:
  /// - The result of the [action] if successful
  /// - null if an error occurred
  /// 
  /// Example:
  /// ```dart
  /// final result = await SafeExecutor.execute<ProductPrice>(
  ///   action: () => storageService.savePrice(price),
  ///   context: context,
  ///   successMessage: 'Prix enregistré avec succès',
  /// );
  /// ```
  static Future<T?> execute<T>({
    required Future<T> Function() action,
    required BuildContext context,
    String? successMessage,
    bool showLoading = true,
    void Function(Exception error)? onError,
    bool retryable = true,
  }) async {
    // Show loading indicator if requested
    if (showLoading && context.mounted) {
      _showLoadingDialog(context);
    }
    
    try {
      // Execute the action
      final result = await action();
      
      // Hide loading indicator
      if (showLoading && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Show success message if provided
      if (successMessage != null && context.mounted) {
        _showSuccessSnackBar(context, successMessage);
      }
      
      return result;
    } catch (error, stackTrace) {
      // Hide loading indicator
      if (showLoading && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Ensure error is an Exception
      final exception = error is Exception ? error : Exception(error.toString());
      
      // Log the error with context
      ErrorHandler.logError(
        exception,
        stackTrace,
        context: {
          'action': action.runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // Call error callback if provided
      if (onError != null) {
        onError(exception);
      }
      
      // Show error message to user
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          ErrorHandler.getUserFriendlyMessage(exception),
          retryable: retryable,
          onRetry: retryable
              ? () => execute(
                    action: action,
                    context: context,
                    successMessage: successMessage,
                    showLoading: showLoading,
                    onError: onError,
                    retryable: retryable,
                  )
              : null,
        );
      }
      
      return null;
    }
  }
  
  /// Executes a synchronous operation with error handling
  /// 
  /// Similar to [execute] but for synchronous operations.
  /// Does not show loading indicators.
  static T? executeSync<T>({
    required T Function() action,
    required BuildContext context,
    String? successMessage,
    void Function(Exception error)? onError,
    bool retryable = true,
  }) {
    try {
      // Execute the action
      final result = action();
      
      // Show success message if provided
      if (successMessage != null && context.mounted) {
        _showSuccessSnackBar(context, successMessage);
      }
      
      return result;
    } catch (error, stackTrace) {
      // Ensure error is an Exception
      final exception = error is Exception ? error : Exception(error.toString());
      
      // Log the error
      ErrorHandler.logError(
        exception,
        stackTrace,
        context: {
          'action': action.runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // Call error callback if provided
      if (onError != null) {
        onError(exception);
      }
      
      // Show error message to user
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          ErrorHandler.getUserFriendlyMessage(exception),
          retryable: retryable,
          onRetry: retryable
              ? () => executeSync(
                    action: action,
                    context: context,
                    successMessage: successMessage,
                    onError: onError,
                    retryable: retryable,
                  )
              : null,
        );
      }
      
      return null;
    }
  }
  
  /// Shows a loading dialog with a circular progress indicator
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Shows a success SnackBar with a green background
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Shows an error SnackBar with a red background and optional retry button
  static void _showErrorSnackBar(
    BuildContext context,
    String message, {
    bool retryable = true,
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: retryable && onRetry != null
            ? SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
