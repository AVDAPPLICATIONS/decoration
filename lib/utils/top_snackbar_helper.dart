import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showSuccessTopSnackBar(BuildContext context, String message) {
  final colorScheme = Theme.of(context).colorScheme;

  showTopSnackBar(
    Overlay.of(context),
    Material(
      borderRadius: BorderRadius.circular(10),
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Text(
          message,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
  );
}

void showErrorTopSnackBar(BuildContext context, String message) {
  final colorScheme = Theme.of(context).colorScheme;

  showTopSnackBar(
    Overlay.of(context),
    Material(
      borderRadius: BorderRadius.circular(10),
      color: colorScheme.error,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Text(
          message,
          style: TextStyle(
            color: colorScheme.onError,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 3),
  );
}

/// ✅ Info snackbar (for actions like "Creating...", "Loading...", etc.)
void showInfoTopSnackBar(BuildContext context, String message) {
  final colorScheme = Theme.of(context).colorScheme;

  showTopSnackBar(
    Overlay.of(context),
    Material(
      borderRadius: BorderRadius.circular(10),
      color: colorScheme.secondaryContainer, // soft neutral tone
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Text(
          message,
          style: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
  );
}
