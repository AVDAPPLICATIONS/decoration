import 'package:flutter/material.dart';

import '../../utils/responsive_text_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleVisibility,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use proper color scheme colors for better visibility and consistency
    final fieldBackground = isDark
        ? theme.colorScheme.surface.withOpacity(0.95) // Use theme surface color
        : theme.colorScheme.surface.withOpacity(0.9); // Use theme surface color

    final fieldBorder = isDark
        ? theme.colorScheme.outline.withOpacity(0.6) // More visible border
        : theme.colorScheme.outline.withOpacity(0.5); // More visible border

    final fieldText = theme.colorScheme.onSurface; // Use theme text color
    final fieldLabel = theme.colorScheme.primary; // Use theme primary color

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : theme.colorScheme.shadow.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        validator: validator,
        style: TextStyle(
          color: fieldText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: fieldLabel,
            size: 22,
          ),
          labelText: label,
          labelStyle: ResponsiveTextStyle.body(context).copyWith(
            color: fieldLabel,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: fieldText.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: fieldBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: fieldBorder,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: fieldBorder,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: fieldLabel,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2.5,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: fieldLabel,
                    size: 22,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
