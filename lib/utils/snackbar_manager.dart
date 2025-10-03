import 'package:flutter/material.dart';

class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();
  factory SnackBarManager() => _instance;
  SnackBarManager._internal();

  /// Show a custom positioned snackbar using Stack overlay
  static void showCustomSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
  }) {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    // Add a delay to ensure the clear operation completes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        // Use Overlay for precise positioning
        final overlay = Overlay.of(context);
        late OverlayEntry overlayEntry;

        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            left: 16,
            right: 16,
            bottom: 100, // Position just above bottom navigation bar
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                    ],
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
                    if (action != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          action.onPressed();
                          overlayEntry.remove();
                        },
                        child: Text(
                          action.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

        overlay.insert(overlayEntry);

        // Auto remove after duration
        Future.delayed(duration, () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        });
      }
    });
  }

  /// Calculate the bottom margin for snackbar positioning
  static double _getBottomMargin(BuildContext context) {
    // Get screen height
    final screenHeight = MediaQuery.of(context).size.height;

    // For mobile devices, account for bottom navigation bar
    if (screenHeight < 768) {
      // Bottom nav height (80) + very small margin (4) = 84
      return 44;
    } else {
      // For tablet/desktop, use smaller margin
      return 40;
    }
  }

  /// Calculate the bottom margin for snackbar positioning with floating action button
  static double _getBottomMarginWithFAB(BuildContext context) {
    // Get screen height
    final screenHeight = MediaQuery.of(context).size.height;

    // For mobile devices, account for bottom navigation bar + floating action button
    if (screenHeight < 768) {
      // Bottom nav height (80) + FAB height (56) + very small margin (4) = 140
      return 140;
    } else {
      // For tablet/desktop, use smaller margin
      return 80;
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
                  4, // Extra spacing for home screen
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
                  4, // Extra spacing for home screen
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
                  4, // Extra spacing for home screen
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
                  4, // Extra spacing for home screen
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

  /// Show a success snackbar with custom positioning
  static void showSuccessCustom({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: duration,
      icon: Icons.check_circle,
    );
  }

  /// Show an error snackbar with custom positioning
  static void showErrorCustom({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: duration,
      icon: Icons.error,
    );
  }

  /// Show a warning snackbar with custom positioning
  static void showWarningCustom({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      duration: duration,
      icon: Icons.warning,
    );
  }

  /// Show an info snackbar with custom positioning
  static void showInfoCustom({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showCustomSnackBar(
      context: context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      duration: duration,
      icon: Icons.info,
    );
  }
}
