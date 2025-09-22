import 'package:flutter/material.dart';

class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();
  factory SnackBarManager() => _instance;
  SnackBarManager._internal();

  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
  
  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey => _scaffoldMessengerKey;
  
  static int _snackBarCounter = 0;

  /// Show a SnackBar with a unique key to prevent Hero tag conflicts
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    SnackBarBehavior? behavior,
    EdgeInsetsGeometry? margin,
    ShapeBorder? shape,
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Generate a unique key for this SnackBar
    final uniqueKey = 'snackbar_${++_snackBarCounter}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Add a small delay to ensure the clear operation completes
    Future.delayed(const Duration(milliseconds: 50), () {
      if (context.mounted) {
        // Show the SnackBar with unique key
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: ValueKey(uniqueKey),
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: duration,
            action: action,
            behavior: behavior,
            margin: margin,
            shape: shape,
          ),
        );
      }
    });
  }

  /// Show a success SnackBar
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Show an error SnackBar
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Show a warning SnackBar
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Show an info SnackBar
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Clear all SnackBars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
