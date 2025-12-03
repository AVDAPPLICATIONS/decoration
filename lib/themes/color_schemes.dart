import 'package:flutter/material.dart';

class ColorSchemes {
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF8B4513), // Saddle brown - strong and readable
    onPrimary: Color(0xFFFFFFFF), // Pure white for maximum contrast
    primaryContainer: Color(0xFFE8D5C4), // Light warm beige
    onPrimaryContainer: Color(0xFF2D1810), // Very dark brown for contrast
    secondary: Color(0xFFD2691E), // Chocolate orange
    onSecondary: Color(0xFFFFFFFF), // Pure white
    secondaryContainer: Color(0xFFFFF5E6), // Very light cream
    onSecondaryContainer: Color(0xFF2D1810), // Very dark brown
    tertiary: Color(0xFFB8860B), // Dark golden rod
    onTertiary: Color(0xFFFFFFFF), // Pure white
    tertiaryContainer: Color(0xFFFFF8DC), // Cornsilk
    onTertiaryContainer: Color(0xFF2D1810), // Very dark brown
    error: Color(0xFFD32F2F), // Material red
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFFB71C1C), // Almost black for text
    surface: Color(0xFFFFFFFF), // Pure white surface
    onSurface: Color(0xFF1C1B1A), // Almost black for text
    surfaceContainerHighest: Color(0xFFF5F0EA), // Light warm gray
    onSurfaceVariant: Color(0xFF4A453E), // Medium brown for less important text
    outline: Color(0xFF8B7D71), // Warm gray outline
    shadow: Color(0xFF000000),
    inversePrimary: Color(0xFFE8D5C4),
    inverseSurface: Color(0xFF313030),
    onInverseSurface: Color(0xFFF4F0ED),
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary colors - warm beige tones
    primary: Color(0xFFD4BFA8), // Light warm beige
    onPrimary: Color(0xFF4A3426), // Medium-dark warm brown
    primaryContainer: Color(0xFF6B4B35), // Dark warm brown container
    onPrimaryContainer: Color(0xFFF2E5D4), // Very light warm cream

    // Secondary colors - rich orange-brown tones
    secondary: Color(0xFFE09660), // Warm muted orange
    onSecondary: Color(0xFF4A3426), // Medium-dark warm brown
    secondaryContainer: Color(0xFF8B5A3C), // Medium-dark orange-brown
    onSecondaryContainer: Color(0xFFF5E6D3), // Light warm cream

    // Tertiary colors - golden-brown tones
    tertiary: Color(0xFFE6C547), // Warm gold
    onTertiary: Color(0xFF4A3426), // Medium-dark warm brown
    tertiaryContainer: Color(0xFFA68B3A), // Dark golden-brown
    onTertiaryContainer: Color(0xFFF7F0C7), // Light golden cream

    // Error colors - warm red-brown tones (no black)
    error: Color(0xFFE88B7A), // Warm salmon-red
    onError: Color(0xFF4A2D28), // Dark warm brown with red undertones
    errorContainer: Color(0xFF8B453F), // Dark warm red-brown
    onErrorContainer: Color(0xFFF5DDD9), // Light warm beige text
    surface: Color(0xFF342B24), // Slightly lighter warm brown surface
    onSurface: Color(0xFFE8D5C4), // Light warm beige text

    // Surface variants - mid-tone warm browns
    surfaceContainerHighest: Color(0xFF5A4D43), // Medium warm brown
    onSurfaceVariant: Color(0xFFCDBAAA), // Light warm brown for secondary text
    outline: Color(0xFF9B8B7D), // Warm brown outline
    outlineVariant: Color(0xFF5A4D43), // Medium warm brown outline variant

    // Special colors - warm brown alternatives to black
    shadow: Color(0xFF1F1812), // Very dark warm brown instead of black
    scrim: Color(0xFF2A221C), // Same as background for consistency
    inversePrimary: Color(0xFF8B4513), // Original saddle brown
    inverseSurface: Color(0xFFE8D5C4), // Light warm surface
    onInverseSurface: Color(0xFF342B24), // Dark warm brown text

    // Surface tint for elevation
    surfaceTint: Color(0xFFD4BFA8), // Same as primary for consistency
  );
}
