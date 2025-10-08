import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Custom AppBar with optional curved bottom and back button control
/// 
/// Usage examples:
/// ```dart
/// // Basic app bar with back button
/// CustomAppBar(
///   title: 'My Screen',
///   showBackButton: true,
///   curvedBottom: false,
/// )
/// 
/// // App bar without back button
/// CustomAppBar(
///   title: 'Home Screen',
///   showBackButton: false,
///   curvedBottom: false,
/// )
/// 
/// // App bar with curved bottom
/// CustomAppBar(
///   title: 'Curved Screen',
///   showBackButton: true,
///   curvedBottom: true,
///   borderRadius: 25.0, // Optional custom radius
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? toolbarHeight;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final String? backTooltip;
  final bool showBackButton;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? titleColor;
  final bool curvedBottom;
  final double? borderRadius;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.shadowColor = Colors.transparent,
    this.surfaceTintColor = Colors.transparent,
    this.toolbarHeight,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.backTooltip = 'Back',
    this.showBackButton = true,
    this.mobileFontSize = 20.0,
    this.tabletFontSize = 22.0,
    this.desktopFontSize = 24.0,
    this.fontWeight = FontWeight.bold,
    this.titleColor,
    this.curvedBottom = false,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
    final effectiveTitleColor = titleColor ?? colorScheme.onPrimary;

    if (curvedBottom) {
      return Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius ?? 20.0),
            bottomRight: Radius.circular(borderRadius ?? 20.0),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: effectiveForegroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: toolbarHeight ?? context.responsive(
            mobile: 56.0,
            tablet: 64.0,
            desktop: 72.0,
          ),
          centerTitle: centerTitle,
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: _buildLeading(context, effectiveForegroundColor),
          title: ResponsiveText(
            title,
            mobileFontSize: mobileFontSize!,
            tabletFontSize: tabletFontSize!,
            desktopFontSize: desktopFontSize!,
            fontWeight: fontWeight,
            color: effectiveTitleColor,
          ),
          actions: actions,
        ),
      );
    }

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      toolbarHeight: toolbarHeight ?? context.responsive(
        mobile: 56.0,
        tablet: 64.0,
        desktop: 72.0,
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context, effectiveForegroundColor),
      title: ResponsiveText(
        title,
        mobileFontSize: mobileFontSize!,
        tabletFontSize: tabletFontSize!,
        desktopFontSize: desktopFontSize!,
        fontWeight: fontWeight,
        color: effectiveTitleColor,
      ),
      actions: actions,
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) {
      return leading;
    }

    if (!showBackButton) {
      return null;
    }

    return IconButton(
      onPressed: onBackPressed ?? () {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          Navigator.of(context).pop();
        }
      },
      icon: Icon(
        Icons.arrow_back,
        color: foregroundColor,
      ),
      tooltip: backTooltip,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    toolbarHeight ?? 56.0, // Default height
  );
}

/// Custom AppBar with loading indicator
class CustomAppBarWithLoading extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? toolbarHeight;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final String? backTooltip;
  final bool showBackButton;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? titleColor;
  final bool isLoading;
  final double? loadingIndicatorSize;
  final double? loadingIndicatorStrokeWidth;
  final bool curvedBottom;
  final double? borderRadius;

  const CustomAppBarWithLoading({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.shadowColor = Colors.transparent,
    this.surfaceTintColor = Colors.transparent,
    this.toolbarHeight,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.backTooltip = 'Back',
    this.showBackButton = false,
    this.mobileFontSize = 20.0,
    this.tabletFontSize = 22.0,
    this.desktopFontSize = 24.0,
    this.fontWeight = FontWeight.bold,
    this.titleColor,
    this.isLoading = false,
    this.loadingIndicatorSize = 20.0,
    this.loadingIndicatorStrokeWidth = 2.0,
    this.curvedBottom = false,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
    final effectiveTitleColor = titleColor ?? colorScheme.onPrimary;

    final List<Widget> effectiveActions = [
      if (isLoading)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: loadingIndicatorSize,
            height: loadingIndicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: loadingIndicatorStrokeWidth!,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
            ),
          ),
        ),
      if (actions != null) ...actions!,
    ];

    if (curvedBottom) {
      return Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius ?? 20.0),
            bottomRight: Radius.circular(borderRadius ?? 20.0),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: effectiveForegroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: toolbarHeight ?? context.responsive(
            mobile: 56.0,
            tablet: 64.0,
            desktop: 72.0,
          ),
          centerTitle: centerTitle,
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: _buildLeading(context, effectiveForegroundColor),
          title: ResponsiveText(
            title,
            mobileFontSize: mobileFontSize!,
            tabletFontSize: tabletFontSize!,
            desktopFontSize: desktopFontSize!,
            fontWeight: fontWeight,
            color: effectiveTitleColor,
          ),
          actions: effectiveActions,
        ),
      );
    }

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      toolbarHeight: toolbarHeight ?? context.responsive(
        mobile: 56.0,
        tablet: 64.0,
        desktop: 72.0,
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context, effectiveForegroundColor),
      title: ResponsiveText(
        title,
        mobileFontSize: mobileFontSize!,
        tabletFontSize: tabletFontSize!,
        desktopFontSize: desktopFontSize!,
        fontWeight: fontWeight,
        color: effectiveTitleColor,
      ),
      actions: effectiveActions,
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) {
      return leading;
    }

    if (!showBackButton) {
      return null;
    }

    return IconButton(
      onPressed: onBackPressed ?? () {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          Navigator.of(context).pop();
        }
      },
      icon: Icon(
        Icons.arrow_back,
        color: foregroundColor,
      ),
      tooltip: backTooltip,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    toolbarHeight ?? 56.0, // Default height
  );
}

/// Custom AppBar for Tab Screens
class CustomTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab> tabs;
  final TabController? tabController;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final double? indicatorWeight;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? titleColor;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final String? backTooltip;
  final bool showBackButton;
  final bool curvedBottom;
  final double? borderRadius;

  const CustomTabAppBar({
    Key? key,
    required this.title,
    required this.tabs,
    this.tabController,
    this.backgroundColor,
    this.foregroundColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.indicatorWeight = 4.0,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.mobileFontSize = 20.0,
    this.tabletFontSize = 22.0,
    this.desktopFontSize = 24.0,
    this.fontWeight = FontWeight.bold,
    this.titleColor,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.backTooltip = 'Back',
    this.showBackButton = true,
    this.curvedBottom = false,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
    final effectiveTitleColor = titleColor ?? colorScheme.onPrimary;
    final effectiveLabelColor = labelColor ?? colorScheme.background;
    final effectiveUnselectedLabelColor = unselectedLabelColor ?? Colors.white;
    final effectiveIndicatorColor = indicatorColor ?? colorScheme.secondary;

    if (curvedBottom) {
      return Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius ?? 20.0),
            bottomRight: Radius.circular(borderRadius ?? 20.0),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: effectiveForegroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: context.responsive(
            mobile: 56.0,
            tablet: 64.0,
            desktop: 72.0,
          ),
          centerTitle: centerTitle,
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: _buildLeading(context, effectiveForegroundColor),
          title: ResponsiveText(
            title,
            mobileFontSize: mobileFontSize!,
            tabletFontSize: tabletFontSize!,
            desktopFontSize: desktopFontSize!,
            fontWeight: fontWeight,
            color: effectiveTitleColor,
          ),
          actions: actions,
          bottom: TabBar(
            controller: tabController,
            labelColor: effectiveLabelColor,
            unselectedLabelColor: effectiveUnselectedLabelColor,
            labelStyle: labelStyle ?? TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.responsive(
                mobile: 14.0,
                tablet: 16.0,
                desktop: 18.0,
              ),
            ),
            unselectedLabelStyle: unselectedLabelStyle ?? TextStyle(
              fontSize: context.responsive(
                mobile: 14.0,
                tablet: 16.0,
                desktop: 18.0,
              ),
            ),
            indicatorColor: effectiveIndicatorColor,
            indicatorWeight: indicatorWeight ?? 4.0,
            tabs: tabs,
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: context.responsive(
        mobile: 56.0,
        tablet: 64.0,
        desktop: 72.0,
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context, effectiveForegroundColor),
      title: ResponsiveText(
        title,
        mobileFontSize: mobileFontSize!,
        tabletFontSize: tabletFontSize!,
        desktopFontSize: desktopFontSize!,
        fontWeight: fontWeight,
        color: effectiveTitleColor,
      ),
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        labelColor: effectiveLabelColor,
        unselectedLabelColor: effectiveUnselectedLabelColor,
        labelStyle: labelStyle ?? TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: context.responsive(
            mobile: 14.0,
            tablet: 16.0,
            desktop: 18.0,
          ),
        ),
        unselectedLabelStyle: unselectedLabelStyle ?? TextStyle(
          fontSize: context.responsive(
            mobile: 14.0,
            tablet: 16.0,
            desktop: 18.0,
          ),
        ),
        indicatorColor: effectiveIndicatorColor,
        indicatorWeight: indicatorWeight ?? 4.0,
        tabs: tabs,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) {
      return leading;
    }

    if (!showBackButton) {
      return null;
    }

    return IconButton(
      onPressed: onBackPressed ?? () {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          Navigator.of(context).pop();
        }
      },
      icon: Icon(
        Icons.arrow_back,
        color: foregroundColor,
      ),
      tooltip: backTooltip,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(104.0); // Default AppBar + TabBar height
}
