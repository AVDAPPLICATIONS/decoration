import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

class ResponsiveTextStyle {
  static TextStyle heading(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      return const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    } else {
      return const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
    }
  }

  static TextStyle subHeading(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    } else {
      return const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    }
  }

  static TextStyle body(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      return const TextStyle(fontSize: 14);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return const TextStyle(fontSize: 16);
    } else {
      return const TextStyle(fontSize: 18);
    }
  }

  static TextStyle caption(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      return const TextStyle(fontSize: 12, color: Colors.grey);
    } else {
      return const TextStyle(fontSize: 14, color: Colors.grey);
    }
  }
}
