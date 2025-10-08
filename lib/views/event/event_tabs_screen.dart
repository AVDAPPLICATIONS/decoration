import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avd_decoration_application/views/event/widget/cost_tab.dart';
import 'package:avd_decoration_application/views/event/widget/design_tab.dart';
import 'package:avd_decoration_application/views/event/widget/material_tab.dart';
import 'package:avd_decoration_application/views/custom_widget/custom_appbar.dart';
import 'package:avd_decoration_application/utils/responsive_utils.dart';
import '../../themes/app_theme.dart';

class EventTabsScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const EventTabsScreen({
    Key? key,
    required this.event,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _applyEdgeToEdgeUI(); // ensures no black strip above appbar

    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveBuilder(
      mobile: _buildLayout(context, colorScheme),
      tablet: _buildLayout(context, colorScheme),
      desktop: _buildLayout(context, colorScheme),
    );
  }

  /// Force full edge-to-edge layout and transparent status/navigation bars
  void _applyEdgeToEdgeUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  Widget _buildLayout(BuildContext context, ColorScheme colorScheme) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary,
                colorScheme.background,
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            top: false, // allow gradient behind status bar
            child: Column(
              children: [
                /// CustomTabAppBar reused from the scalable appbar system
                CustomTabAppBar(
                  title: '${event['name']} (${event['year']})',
                  tabs: const [
                    Tab(text: 'Inventory'),
                    Tab(text: 'Design'),
                    Tab(text: 'Cost'),
                  ],
                  labelColor: AppColors.background,
                  unselectedLabelColor: Colors.white,
                  indicatorColor: AppColors.secondary,
                  indicatorWeight: 4,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  titleColor: Colors.white,
                ),

                /// Tab content area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                          context.responsive(
                            mobile: 24.0,
                            tablet: 28.0,
                            desktop: 32.0,
                          ),
                        ),
                      ),
                    ),
                    child: const _EventTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Separate widget for TabBarView to improve readability and maintainability
class _EventTabContent extends StatelessWidget {
  const _EventTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventTabsScreen parent =
    context.findAncestorWidgetOfExactType<EventTabsScreen>()!;

    return TabBarView(
      children: [
        MaterialTab(event: parent.event, isAdmin: parent.isAdmin),
        DesignTab(event: parent.event, isAdmin: parent.isAdmin),
        CostTab(event: parent.event, isAdmin: parent.isAdmin),
      ],
    );
  }
}
