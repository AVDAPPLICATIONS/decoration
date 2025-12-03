import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppColors {
  static const Color primary = Color(0xFF9A3F3F); // Deep maroon
  static const Color secondary = Color(0xFFC1856D); // Warm brown/terracotta
  static const Color background = Color(0xFFFBF9D1); // Pale cream
  static const Color accentIcon = Color(0xFFE6CFA9); // Light beige for icons
  static const Color chartDivider =
      Color(0xFFC1856D); // Warm brown for chart dividers
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorSchemes.lightColorScheme,
    primaryColor: ColorSchemes.lightColorScheme.primary,
    scaffoldBackgroundColor: ColorSchemes.lightColorScheme.surface,
    hintColor: ColorSchemes.lightColorScheme.primary,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorSchemes.lightColorScheme.primary,
      foregroundColor: ColorSchemes.lightColorScheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorSchemes.lightColorScheme.primary,
        foregroundColor: ColorSchemes.lightColorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorSchemes.darkColorScheme,
    primaryColor: ColorSchemes.darkColorScheme.primary,
    scaffoldBackgroundColor: ColorSchemes.darkColorScheme.surface,
    hintColor: ColorSchemes.darkColorScheme.secondary,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorSchemes.darkColorScheme.primary,
      foregroundColor: ColorSchemes.darkColorScheme.onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorSchemes.darkColorScheme.primary,
        foregroundColor: ColorSchemes.darkColorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
