import 'package:flutter/material.dart';

import '../views/auth/login_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/event/eventTemplate/event_screen.dart';
import '../views/event/years_screen.dart';
import '../views/event/issue_item_screen.dart';
import '../views/home/home_screen.dart';
import '../views/inventory/inventory_screen.dart';
import '../views/splash/splash_screen.dart';

// Import your screens here
// Add remaining screens as needed:
// import '../screens/splash/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/management/material_management_screen.dart';
// import '../screens/management/tool_management_screen.dart';
// import '../screens/management/year_management_screen.dart';
// import '../screens/user/user_management_screen.dart';
// import '../screens/event/event_detail_screen.dart';
// import '../screens/event/event_list_screen.dart';
// import '../screens/template/event_template_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String event = '/event';
  static const String inventory = '/inventory';
  static const String eventTemplates = '/event-templates';
  static const String yearManagement = '/year-management';
  static const String eventList = '/event-list';
  static const String eventDetail = '/event-detail';
  static const String materialManagement = '/material-management';
  static const String toolManagement = '/tool-management';
  static const String userManagement = '/user-management';
  static const String years = '/years';
  static const String issueItem = '/issue-item';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      // case register:
      //   return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const EventDashboardScreen());

      case event:
        final args = settings.arguments as Map<String, dynamic>?;
        final isAdmin = args?['isAdmin'] ?? false;
        return MaterialPageRoute(
          builder: (_) => EventScreen(isAdmin: isAdmin),
        );

      case inventory:
        return MaterialPageRoute(
          builder: (_) => const InventoryFormPage(),
          fullscreenDialog: true,
        );

      case years:
        final args = settings.arguments as Map<String, dynamic>?;
        final templateId = args?['templateId'] as int?;
        final templateName = args?['templateName'] as String?;
        return MaterialPageRoute(
          builder: (_) => YearsScreen(
            templateId: templateId,
            templateName: templateName,
          ),
        );

      case issueItem:
        final args = settings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'] as int?;
        final onItemIssued = args?['onItemIssued'] as VoidCallback?;
        final onNavigateToMaterialTab =
            args?['onNavigateToMaterialTab'] as VoidCallback?;
        if (eventId == null) {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
        return MaterialPageRoute(
          builder: (_) => IssueItemScreen(
            eventId: eventId,
            onItemIssued: onItemIssued ?? () {},
            onNavigateToMaterialTab: onNavigateToMaterialTab,
          ),
        );

      // case eventTemplates:
      //   return MaterialPageRoute(builder: (_) => const EventTemplateScreen());

      // case yearManagement:
      //   return MaterialPageRoute(builder: (_) => const YearManagementScreen());

      // case eventList:
      //   return MaterialPageRoute(builder: (_) => const EventListScreen());

      // case eventDetail:
      //   return MaterialPageRoute(builder: (_) => const EventDetailScreen());

      // case materialManagement:
      //   return MaterialPageRoute(builder: (_) => const MaterialManagementScreen());

      // case toolManagement:
      //   return MaterialPageRoute(builder: (_) => const ToolManagementScreen());

      // case userManagement:
      //   return MaterialPageRoute(builder: (_) => const UserManagementScreen());

      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
