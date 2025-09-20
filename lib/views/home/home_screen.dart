import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bottom_nav_provider.dart';
import '../../utils/responsive_utils.dart';
import '../dashboard/dashboard_screen.dart';
import '../event/event_screen.dart';
import '../inventory/inventory_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isAdmin = user?.role == 'admin';

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, isAdmin),
      tablet: _buildTabletLayout(context, isAdmin),
      desktop: _buildDesktopLayout(context, isAdmin),
      largeDesktop: _buildDesktopLayout(context, isAdmin),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isAdmin) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PersistentTabView(
      context,
      key: const ValueKey('persistent_tab_view'),
      controller: _controller,
      screens: _buildScreens(isAdmin),
      items: _buildNavBarItems(context),
      handleAndroidBackButtonPress: false,
      resizeToAvoidBottomInset: true,
      stateManagement: true, // Changed to true to better manage state
      hideNavigationBarWhenKeyboardAppears: true,
      navBarStyle: NavBarStyle.style9,
      backgroundColor: colorScheme.surface,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(24),
        colorBehindNavBar: colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      navBarHeight: 80,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // Add these properties to help with navigation state
      onItemSelected: (index) {
        // Handle tab selection
        ref.read(bottomNavIndexProvider.notifier).update((state) => index);
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context, bool isAdmin) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final screens = _buildScreens(isAdmin);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // Side Navigation for Tablet
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            constraints: const BoxConstraints(
              minWidth: 200,
              maxWidth: 300,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // App Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Event Manager',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  ref,
                  0,
                  currentIndex,
                  Icons.dashboard_rounded,
                  'Dashboard',
                ),
                _buildNavItem(
                  context,
                  ref,
                  1,
                  currentIndex,
                  Icons.event_rounded,
                  'Events',
                ),
                _buildNavItem(
                  context,
                  ref,
                  2,
                  currentIndex,
                  Icons.inventory_2_rounded,
                  'Inventory',
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 0,
              ),
              color: Theme.of(context).colorScheme.background,
              child: IndexedStack(
                index: currentIndex,
                children: screens,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isAdmin) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final screens = _buildScreens(isAdmin);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          // Side Navigation for Desktop
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            constraints: const BoxConstraints(
              minWidth: 250,
              maxWidth: 350,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // App Logo/Title with enhanced styling
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Event Management',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildNavItem(
                  context,
                  ref,
                  0,
                  currentIndex,
                  Icons.dashboard_rounded,
                  'Dashboard',
                ),
                _buildNavItem(
                  context,
                  ref,
                  1,
                  currentIndex,
                  Icons.event_rounded,
                  'Events',
                ),
                _buildNavItem(
                  context,
                  ref,
                  2,
                  currentIndex,
                  Icons.inventory_2_rounded,
                  'Inventory',
                ),
                const Spacer(),
                // User info at bottom with enhanced styling
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user?.username ?? 'Admin User',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                              ),
                              Text(
                                isAdmin ? 'Administrator' : 'User',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 0,
              ),
              color: Theme.of(context).colorScheme.background,
              child: IndexedStack(
                index: currentIndex,
                children: screens,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScreens(bool isAdmin) {
    return [
      const EventDashboardScreen(),
      EventScreen(isAdmin: isAdmin),
      const InventoryListScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _buildNavBarItems(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.dashboard_rounded),
        title: "Dashboard",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: colorScheme.onSurface.withOpacity(0.6),
        activeColorSecondary: colorScheme.primary,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.event_rounded),
        title: "Events",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: colorScheme.onSurface.withOpacity(0.6),
        activeColorSecondary: colorScheme.primary,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.inventory_2_rounded),
        title: "Inventory",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: colorScheme.onSurface.withOpacity(0.6),
        activeColorSecondary: colorScheme.primary,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
      ),
    ];
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    int currentIndex,
    IconData icon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          highlightColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.7),
                ),
                if (!isMobile) ...{
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.8),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
