import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'themes/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/splash/splash_screen.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensures all bindings are ready

  runApp(
    const ProviderScope(child: MyApp()),
  );
}
// +qyqq
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   runApp(
//     ProviderScope(
//       child: DevicePreview(
//         enabled: true, // Set to false to disable device preview
//         builder: (context) => const MyApp(),
//       ),
//     ),
//   );
// }

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AVD Decoration App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      // Use named routes so screens like '/issue-item' resolve
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      // Fallback home in case someone navigates directly without routes
      // Note: AppRoutes.splash will show SplashScreen, which then navigates
      // based on auth state. Keeping home as AppRoot for backward compatibility
      home: const AppRoot(),
    );
  }
}

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash screen for 3 seconds, then proceed to auth check
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen for initial 3 seconds
    if (_showSplash) {
      print('🔄 AppRoot: Showing initial splash screen');
      return const SplashScreen();
    }

    // After splash, check authentication state
    final isAuthReady = ref.watch(authReadyProvider);
    final user = ref.watch(authProvider);

    print(
        '🔄 AppRoot: isAuthReady=$isAuthReady, user=${user?.username ?? 'null'}');

    // If auth is not ready yet, show splash screen
    if (!isAuthReady) {
      print('🔄 AppRoot: Auth not ready, showing splash screen');
      return const SplashScreen();
    }

    // If user is authenticated, show home screen with persistent navigation
    if (user != null) {
      print('🔄 AppRoot: User authenticated, showing home screen');
      return const HomeScreen();
    }

    // If user is not authenticated, show login screen without persistent navigation
    print('🔄 AppRoot: User not authenticated, showing login screen');
    return const LoginScreen();
  }
}
