import 'package:avd_decoration_application/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'AVD Decoration App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash, // or AppRoutes.home if skipping splash
        onGenerateRoute: AppRoutes.generateRoute, // ✅ Correct usage
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
