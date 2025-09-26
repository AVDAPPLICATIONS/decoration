import 'package:flutter/material.dart';

class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();
  factory SnackBarManager() => _instance;
  SnackBarManager._internal();

  /// Calculate the bottom margin for snackbar positioning
  static double _getBottomMargin(BuildContext context) {
    // Get screen height
    final screenHeight = MediaQuery.of(context).size.height;

    // For mobile devices, account for bottom navigation bar
    if (screenHeight < 768) {
      // Bottom nav height (80) + margin (16) + padding (44) + extra spacing (40) = 180
      return 180;
    } else {
      // For tablet/desktop, use smaller margin
      return 140;
    }
  }

  /// Calculate the bottom margin for snackbar positioning with floating action button
  static double _getBottomMarginWithFAB(BuildContext context) {
    // Get screen height
    final screenHeight = MediaQuery.of(context).size.height;

    // For mobile devices, account for bottom navigation bar + floating action button
    if (screenHeight < 768) {
      // Bottom nav height (80) + margin (16) + padding (44) + FAB height (56) + extra spacing (40) = 236
      return 236;
    } else {
      // For tablet/desktop, use smaller margin
      return 180;
    }
  }

  /// Show a snackbar with proper positioning for home screen
  static void showSnackBarForHome({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    // Add a delay to ensure the clear operation completes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        // Use standard Flutter SnackBar with proper bottom positioning for home screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.primary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context) +
                  30, // Extra spacing for home screen
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            action: action,
          ),
        );
      }
    });
  }

  /// Show a success snackbar with proper positioning for home screen
  static void showSuccessForHome({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context) +
                  30, // Extra spacing for home screen
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Show an error snackbar with proper positioning for home screen
  static void showErrorForHome({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context) +
                  30, // Extra spacing for home screen
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Show a warning snackbar with proper positioning for home screen
  static void showWarningForHome({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context) +
                  30, // Extra spacing for home screen
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Show a success snackbar with proper positioning for inventory screen (with FAB)
  static void showSuccessForInventory({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMarginWithFAB(context), // Account for FAB
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Show an error snackbar with proper positioning for inventory screen (with FAB)
  static void showErrorForInventory({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMarginWithFAB(context), // Account for FAB
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      _scaffoldMessengerKey;

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

    // Add a delay to ensure the clear operation completes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        // Use standard Flutter SnackBar with proper bottom positioning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.primary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context),
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
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
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context),
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Show an error SnackBar
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context),
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Show a warning SnackBar
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context),
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Show an info SnackBar
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: _getBottomMargin(context),
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    });
  }

  /// Clear all SnackBars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
