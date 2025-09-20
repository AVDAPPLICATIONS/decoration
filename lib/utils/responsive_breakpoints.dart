import 'package:flutter/widgets.dart';

enum DeviceScreenType { mobile, tablet, desktop, largeDesktop }

class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < mobile;

  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= mobile && screenWidth(context) < tablet;

  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= tablet && screenWidth(context) < desktop;

  static bool isLargeDesktop(BuildContext context) =>
      screenWidth(context) >= desktop;

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = screenWidth(context);
    if (width >= desktop) {
      return DeviceScreenType.largeDesktop;
    } else if (width >= tablet) {
      return DeviceScreenType.desktop;
    } else if (width >= mobile) {
      return DeviceScreenType.tablet;
    } else {
      return DeviceScreenType.mobile;
    }
  }
}
