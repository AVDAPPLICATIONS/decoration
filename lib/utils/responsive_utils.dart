import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen size utility class for responsive design
class ScreenUtil {
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is small (mobile)
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < Breakpoints.tablet;
  }

  /// Check if screen is medium (tablet)
  static bool isMediumScreen(BuildContext context) {
    return screenWidth(context) >= Breakpoints.tablet &&
        screenWidth(context) < Breakpoints.desktop;
  }

  /// Check if screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= Breakpoints.desktop;
  }

  /// Check if screen is extra large
  static bool isExtraLargeScreen(BuildContext context) {
    return screenWidth(context) >= Breakpoints.largeDesktop;
  }

  /// Get responsive cross axis count for grids
  static int getCrossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int largeDesktop = 4,
  }) {
    if (isSmallScreen(context)) return mobile;
    if (isMediumScreen(context)) return tablet;
    if (isExtraLargeScreen(context)) return largeDesktop;
    return desktop;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
    T? largeDesktop,
  }) {
    if (isSmallScreen(context)) return mobile;
    if (isMediumScreen(context)) return tablet ?? desktop;
    if (isExtraLargeScreen(context)) return largeDesktop ?? desktop;
    return desktop;
  }
}

/// Responsive breakpoints configuration
class Breakpoints {
  static const double mobile = 480.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
  static const double largeDesktop = 1440.0;

  /// Custom breakpoint checker
  static bool isAbove(BuildContext context, double breakpoint) {
    return ScreenUtil.screenWidth(context) > breakpoint;
  }

  /// Custom breakpoint checker
  static bool isBelow(BuildContext context, double breakpoint) {
    return ScreenUtil.screenWidth(context) < breakpoint;
  }

  /// Check if screen is between two breakpoints
  static bool isBetween(BuildContext context, double min, double max) {
    final width = ScreenUtil.screenWidth(context);
    return width >= min && width < max;
  }
}

/// Responsive builder widget that adapts UI based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.tablet) {
          return mobile;
        } else if (constraints.maxWidth < Breakpoints.desktop) {
          return tablet ?? desktop;
        } else if (constraints.maxWidth < Breakpoints.largeDesktop) {
          return desktop;
        } else {
          return largeDesktop ?? desktop;
        }
      },
    );
  }
}

/// Responsive layout wrapper that provides different layouts for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget? mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ResponsiveLayout({
    super.key,
    this.mobileBody,
    this.tabletBody,
    this.desktopBody,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Scaffold(
        appBar: appBar,
        body: mobileBody,
        drawer: drawer,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor,
      ),
      tablet: Scaffold(
        appBar: appBar,
        body: tabletBody ?? mobileBody,
        drawer: drawer,
        backgroundColor: backgroundColor,
      ),
      desktop: Scaffold(
        body: desktopBody ?? tabletBody ?? mobileBody,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

/// Responsive grid widget that automatically adjusts column count
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeDesktopColumns;
  final double? childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    this.childAspectRatio,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ScreenUtil.getCrossAxisCount(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      largeDesktop: largeDesktopColumns,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 1.0,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive wrap widget that adjusts spacing based on screen size
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double mobileSpacing;
  final double tabletSpacing;
  final double desktopSpacing;
  final double mobileRunSpacing;
  final double tabletRunSpacing;
  final double desktopRunSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.mobileSpacing = 8.0,
    this.tabletSpacing = 12.0,
    this.desktopSpacing = 16.0,
    this.mobileRunSpacing = 8.0,
    this.tabletRunSpacing = 12.0,
    this.desktopRunSpacing = 16.0,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ScreenUtil.getResponsiveValue<double>(
      context,
      mobile: mobileSpacing,
      tablet: tabletSpacing,
      desktop: desktopSpacing,
    );

    final runSpacing = ScreenUtil.getResponsiveValue<double>(
      context,
      mobile: mobileRunSpacing,
      tablet: tabletRunSpacing,
      desktop: desktopRunSpacing,
    );

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets tabletPadding;
  final EdgeInsets desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16.0),
    this.tabletPadding = const EdgeInsets.all(24.0),
    this.desktopPadding = const EdgeInsets.all(32.0),
  });

  @override
  Widget build(BuildContext context) {
    final padding = ScreenUtil.getResponsiveValue<EdgeInsets>(
      context,
      mobile: mobilePadding,
      tablet: tabletPadding,
      desktop: desktopPadding,
    );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive text widget that adjusts font size based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final double mobileFontSize;
  final double tabletFontSize;
  final double desktopFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.mobileFontSize,
    required this.tabletFontSize,
    required this.desktopFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ScreenUtil.getResponsiveValue<double>(
      context,
      mobile: mobileFontSize,
      tablet: tabletFontSize,
      desktop: desktopFontSize,
    );

    return Text(
      text,
      softWrap: true,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive container with automatic width/height adjustments
class ResponsiveContainer extends StatelessWidget {
  final Widget? child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final EdgeInsets? mobileMargin;
  final EdgeInsets? tabletMargin;
  final EdgeInsets? desktopMargin;
  final Decoration? decoration;

  const ResponsiveContainer({
    super.key,
    this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.mobileMargin,
    this.tabletMargin,
    this.desktopMargin,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final width = ScreenUtil.getResponsiveValue<double?>(
      context,
      mobile: mobileWidth,
      tablet: tabletWidth,
      desktop: desktopWidth,
    );

    final height = ScreenUtil.getResponsiveValue<double?>(
      context,
      mobile: mobileHeight,
      tablet: tabletHeight,
      desktop: desktopHeight,
    );

    final padding = ScreenUtil.getResponsiveValue<EdgeInsets?>(
      context,
      mobile: mobilePadding,
      tablet: tabletPadding,
      desktop: desktopPadding,
    );

    final margin = ScreenUtil.getResponsiveValue<EdgeInsets?>(
      context,
      mobile: mobileMargin,
      tablet: tabletMargin,
      desktop: desktopMargin,
    );

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}

/// Extension methods for BuildContext to make responsive queries easier
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ScreenUtil.isSmallScreen(this);
  bool get isTablet => ScreenUtil.isMediumScreen(this);
  bool get isDesktop => ScreenUtil.isLargeScreen(this);
  bool get isLargeDesktop => ScreenUtil.isExtraLargeScreen(this);

  double get screenWidth => ScreenUtil.screenWidth(this);
  double get screenHeight => ScreenUtil.screenHeight(this);

  T responsive<T>({
    required T mobile,
    T? tablet,
    required T desktop,
    T? largeDesktop,
  }) {
    return ScreenUtil.getResponsiveValue<T>(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}
