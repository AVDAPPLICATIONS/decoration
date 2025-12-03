import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'themes/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensures all bindings are ready

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AVD Decoration App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
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
    if (_showSplash) {
      return const SplashScreen();
    }

    final isAuthReady = ref.watch(authReadyProvider);
    final user = ref.watch(authProvider);


    if (!isAuthReady) {
      return const SplashScreen();
    }

    if (user != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
