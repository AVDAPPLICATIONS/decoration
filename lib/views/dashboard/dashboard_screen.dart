import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart' show showTopSnackBar;
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';

class EventDashboardScreen extends ConsumerStatefulWidget {
  const EventDashboardScreen({super.key});

  @override
  ConsumerState<EventDashboardScreen> createState() =>
      _EventDashboardScreenState();
}

class _EventDashboardScreenState extends ConsumerState<EventDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, dashboardState, colorScheme),
      tablet: _buildTabletLayout(context, dashboardState, colorScheme),
      desktop: _buildDesktopLayout(context, dashboardState, colorScheme),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.primary,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: context.responsive(
        mobile: 56.0,
        tablet: 64.0,
        desktop: 72.0,
      ),
      title: ResponsiveText(
        'Dashboard',
        mobileFontSize: 20.0,
        tabletFontSize: 22.0,
        desktopFontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive(
              mobile: 16.0,
              tablet: 20.0,
              desktop: 24.0,
            ),
          ),
          child: IconButton(
            onPressed: () {
              // Handle logout or menu action
              _showLogoutDialog();
            },
            icon: Icon(
              Icons.logout,
              color: colorScheme.onPrimary,
              size: context.responsive(
                mobile: 20.0,
                tablet: 22.0,
                desktop: 24.0,
              ),
            ),
            tooltip: 'Logout',
            padding: EdgeInsets.all(
              context.responsive(
                mobile: 8.0,
                tablet: 10.0,
                desktop: 12.0,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: context.responsive(
                mobile: 40.0,
                tablet: 44.0,
                desktop: 48.0,
              ),
              minHeight: context.responsive(
                mobile: 40.0,
                tablet: 44.0,
                desktop: 48.0,
              ),
            ),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  void _showLogoutDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.responsive(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              ),
            ),
          ),
          title: ResponsiveText(
            'Logout',
            mobileFontSize: 18.0,
            tabletFontSize: 20.0,
            desktopFontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          content: ResponsiveText(
            'Are you sure you want to logout?',
            mobileFontSize: 14.0,
            tabletFontSize: 16.0,
            desktopFontSize: 18.0,
            color: colorScheme.onSurfaceVariant,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: ResponsiveText(
                'Cancel',
                mobileFontSize: 14.0,
                tabletFontSize: 16.0,
                desktopFontSize: 18.0,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle logout logic here
                ref.read(authProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    context.responsive(
                      mobile: 8.0,
                      tablet: 10.0,
                      desktop: 12.0,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(
                    mobile: 16.0,
                    tablet: 20.0,
                    desktop: 24.0,
                  ),
                  vertical: context.responsive(
                    mobile: 8.0,
                    tablet: 10.0,
                    desktop: 12.0,
                  ),
                ),
              ),
              child: ResponsiveText(
                'Logout',
                mobileFontSize: 14.0,
                tabletFontSize: 16.0,
                desktopFontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onError,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, DashboardState dashboardState,
      ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildResponsiveAppBar(colorScheme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.background,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary,
                blurRadius: 25,
                offset: const Offset(0, -8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: _buildBody(dashboardState),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, DashboardState dashboardState,
      ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer,
      appBar: _buildResponsiveAppBar(colorScheme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.background,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, -8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: _buildBody(dashboardState),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context,
      DashboardState dashboardState, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildResponsiveAppBar(colorScheme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.background,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, -8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: _buildBody(dashboardState),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DashboardState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading) {
      print('🔍 Showing loading indicator');
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (state.error != null) {
      print('🔍 Showing error: ${state.error}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,

              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(dashboardProvider.notifier).refreshDashboard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.stats == null) {
      print('🔍 Showing "No data available" - stats is null');
      return Center(
        child: Text(
          _getFriendlyErrorMessage(state.error),
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),

      );
    }

    print('🔍 Building dashboard content with stats');

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await ref.read(dashboardProvider.notifier).refreshDashboard();

          showTopSnackBar(
            Overlay.of(context),
            Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Text(
                  'Dashboard refreshed successfully!',
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
        } catch (e) {
          showTopSnackBar(
            Overlay.of(context),
            Material(
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.error,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Text(
                  'Failed to refresh: ${e.toString()}',
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
      },

      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      strokeWidth: 2.5,
      displacement: 40.0,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Add proper spacing for the overlap effect
          SliverToBoxAdapter(
            child: Container(
              height: context.responsive(
                mobile: 16.0,
                tablet: 20.0,
                desktop: 24.0,
              ),
            ),
          ),
          // Enhanced Overview Section with Advanced Scroll Effects
          SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, animationValue, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * animationValue),
                      child: Container(
                        padding: EdgeInsets.all(
                          context.responsive(
                            mobile: 16.0,
                            tablet: 24.0,
                            desktop: 32.0,
                          ),
                        ),
                        child: _buildStatsGrid(state.stats!.totals),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Spacing
          SliverToBoxAdapter(
            child: SizedBox(
              height: context.responsive(
                mobile: 24.0,
                tablet: 28.0,
                desktop: 32.0,
              ),
            ),
          ),

          // Cost by Year Chart with Enhanced Scroll Effect
          SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, animationValue, child) {
                return Transform.translate(
                  offset: Offset(0, 40 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.9 + (0.1 * animationValue),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsive(
                            mobile: 16.0,
                            tablet: 24.0,
                            desktop: 32.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: context.responsive(
                mobile: 24.0,
                tablet: 28.0,
                desktop: 32.0,
              ),
            ),
          ),


        ],
      ),
    );
  }
  String _getFriendlyErrorMessage(String? error) {
    if (error == null) return '';

    final lowerError = error.toLowerCase();

    if (lowerError.contains('socketexception') ||
        lowerError.contains('network is unreachable') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('connection failed')) {
      return 'No internet connection. Please check your network.';
    }

    if (lowerError.contains('timeout')) {
      return 'Request timed out. Try again later.';
    }

    if (lowerError.contains('clientexception')) {
      return 'Server connection error.';
    }

    return error; // fallback: show raw message
  }

  Widget _buildStatsGrid(Map<String, dynamic> totals) {
    final colorScheme = Theme.of(context).colorScheme;

    final stats = [
      {
        'title': 'Templates',
        'value': totals['templates']?.toString() ?? '0',
        'icon': Icons.description,
        'color': colorScheme.primary,
      },
      {
        'title': 'Materials',
        'value': totals['materials']?.toString() ?? '0',
        'icon': Icons.inventory,
        'color': colorScheme.primary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Overview',
          mobileFontSize: 18.0,
          tabletFontSize: 20.0,
          desktopFontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        SizedBox(
          height: context.responsive(
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
        ),
        ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 2,
          desktopColumns: 2,
          largeDesktopColumns: 2,
          spacing: context.responsive(
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
          runSpacing: context.responsive(
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
          childAspectRatio: context.responsive(
            mobile: 1.5,
            tablet: 1.4,
            desktop: 1.2,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: stats
              .map((stat) => _buildStatCard(
                    title: stat['title'] as String,
                    value: stat['value'] as String,
                    icon: stat['icon'] as IconData,
                    color: stat['color'] as Color,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.85 + (0.15 * animationValue),
          child: Opacity(
            opacity: animationValue.clamp(0.0, 1.0),
            child: ResponsiveContainer(
              mobilePadding: const EdgeInsets.all(16.0),
              tabletPadding: const EdgeInsets.all(20.0),
              desktopPadding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.98),
                    colorScheme.surface.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(
                  context.responsive(
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                ),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: context.responsive(
                      mobile: 8.0,
                      tablet: 12.0,
                      desktop: 16.0,
                    ),
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: context.responsive(
                      mobile: 4.0,
                      tablet: 6.0,
                      desktop: 8.0,
                    ),
                    offset: Offset(
                        0,
                        context.responsive(
                          mobile: 1.0,
                          tablet: 2.0,
                          desktop: 3.0,
                        )),
                  ),
                ],
              ),
              child: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon container
                    Container(
                      padding: EdgeInsets.all(
                        context.responsive(
                          mobile: 8.0,
                          tablet: 10.0,
                          desktop: 12.0,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.15),
                            color.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          context.responsive(
                            mobile: 14.0,
                            tablet: 16.0,
                            desktop: 18.0,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: context.responsive(
                          mobile: 20.0,
                          tablet: 24.0,
                          desktop: 28.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.responsive(
                        mobile: 6.0,
                        tablet: 8.0,
                        desktop: 10.0,
                      ),
                    ),
                    // Value text - make it more prominent
                    ResponsiveText(
                      value,
                      mobileFontSize: 18.0,
                      tabletFontSize: 20.0,
                      desktopFontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: context.responsive(
                        mobile: 4.0,
                        tablet: 5.0,
                        desktop: 6.0,
                      ),
                    ),
                    // Title text
                    ResponsiveText(
                      title,
                      mobileFontSize: 12.0,
                      tabletFontSize: 14.0,
                      desktopFontSize: 16.0,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
