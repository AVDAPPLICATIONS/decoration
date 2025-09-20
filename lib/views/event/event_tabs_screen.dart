import 'package:avd_decoration_application/views/event/widget/cost_tab.dart';
import 'package:avd_decoration_application/views/event/widget/design_tab.dart';
import 'package:avd_decoration_application/views/event/widget/material_tab.dart';
import 'package:avd_decoration_application/views/custom_widget/custom_appbar.dart';
import 'package:avd_decoration_application/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class EventTabsScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const EventTabsScreen({Key? key, required this.event, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, colorScheme),
      tablet: _buildTabletLayout(context, colorScheme),
      desktop: _buildDesktopLayout(context, colorScheme),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme) {
    return _buildEventTabsScreen(context, colorScheme);
  }

  Widget _buildTabletLayout(BuildContext context, ColorScheme colorScheme) {
    return _buildEventTabsScreen(context, colorScheme);
  }

  Widget _buildDesktopLayout(BuildContext context, ColorScheme colorScheme) {
    return _buildEventTabsScreen(context, colorScheme);
  }

  Widget _buildEventTabsScreen(BuildContext context, ColorScheme colorScheme) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomTabAppBar(
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
        ),
        backgroundColor: colorScheme.background,
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
            margin: EdgeInsets.only(
              top: context.responsive(
                mobile: 15.0,
                tablet: 18.0,
                desktop: 24.0,
              ),
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  context.responsive(
                    mobile: 28.0,
                    tablet: 28.0,
                    desktop: 28.0,
                  ),
                ),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: context.responsive(
                mobile: 100.0,
                tablet: 110.0,
                desktop: 120.0,
              ),
            ),
            child: TabBarView(
              children: [
                MaterialTab(event: event, isAdmin: isAdmin),
                DesignTab(event: event, isAdmin: isAdmin),
                CostTab(event: event, isAdmin: isAdmin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}