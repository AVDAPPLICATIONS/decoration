import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onLongPress: () async {
          // Clear user data for testing (long press on splash screen)
          final localStorage = ref.read(localStorageServiceProvider);
          await localStorage.clearAllData();
          ref.read(authProvider.notifier).state = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data cleared for testing'),
              backgroundColor: Colors.green,
            ),
          );
        },
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/swamiji.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
