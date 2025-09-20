// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// Service providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(apiBaseUrl);
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Main auth state (user info)
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref);
});

// Auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error message state
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth provider ready state
final authReadyProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends StateNotifier<UserModel?> {
  final Ref ref;
  bool _isInitialized = false;

  AuthNotifier(this.ref) : super(null) {
    // Check for saved user session when provider is created
    _checkSavedSession();
  }

  // Check if there's a saved user session
  Future<void> _checkSavedSession() async {
    try {
      print('Checking for saved user session...');
      final localStorage = ref.read(localStorageServiceProvider);
      final savedUserData = await localStorage.getUserData();

      if (savedUserData != null) {
        state = savedUserData;
        print(
            '✅ Restored user session: ${savedUserData.username} (${savedUserData.role})');
      } else {
        print('❌ No saved user session found');
      }
    } catch (e) {
      print('❌ Error checking saved session: $e');
    } finally {
      _isInitialized = true;
      ref.read(authReadyProvider.notifier).state = true;
      print('✅ Auth provider initialization completed');
    }
  }

  // Manual method to check authentication status
  Future<bool> checkAuthenticationStatus() async {
    // Wait for initialization to complete
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      final localStorage = ref.read(localStorageServiceProvider);
      final savedUserData = await localStorage.getUserData();

      if (savedUserData != null) {
        state = savedUserData;
        print(
            '✅ Authentication status: Logged in as ${savedUserData.username}');
        return true;
      } else {
        state = null;
        print('❌ Authentication status: Not logged in');
        return false;
      }
    } catch (e) {
      print('❌ Error checking authentication status: $e');
      state = null;
      return false;
    }
  }

  // Check if provider is ready
  bool get isReady => _isInitialized;

  Future<void> login(String username, String password) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final response =
          await ref.read(authServiceProvider).login(username, password);

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final user = UserModel(
          id: userData['id'],
          username: userData['username'],
          role: userData['role'],
          email: userData['email'],
          createdAt: userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : null,
        );

        // Save user data to shared preferences
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.saveUserData(user);

        state = user;
        print('✅ User logged in and saved: ${user.username} (${user.role})');
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      state = null;
      ref.read(authErrorProvider.notifier).state =
          'Login failed. Please try again.';
      print('❌ Login error: $e');
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Method to update user state directly
  void updateUser(UserModel user) {
    state = user;
  }

  Future<void> register(UserModel user) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final newUser = await ref.read(authServiceProvider).register(user);

      // Save user data to shared preferences
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.saveUserData(newUser);

      state = newUser;
      print(
          '✅ User registered and saved: ${newUser.username} (${newUser.role})');
    } catch (e) {
      state = null;
      ref.read(authErrorProvider.notifier).state = 'Registration failed.';
      print('❌ Registration error: $e');
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authServiceProvider).logout();

      // Clear saved user data
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.clearUserData();

      state = null;
      print('✅ User logged out and data cleared');
    } catch (e) {
      print('❌ Logout error: $e');
      // Even if logout fails, clear local state
      state = null;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => state != null;

  // Get current user
  UserModel? get currentUser => state;
}
