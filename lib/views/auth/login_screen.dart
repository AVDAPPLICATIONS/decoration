import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/validators.dart';
import '../custom_widget/custom_button.dart';
import '../custom_widget/custom_input_field.dart';

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Simple validation
    if (username.isEmpty || password.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text('Please enter both username and password')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create auth service instance
      final authService = AuthService(apiBaseUrl);

      // Call the login API
      final response = await authService.login(username, password);

      // Close loading dialog
      Navigator.of(context).pop();

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final user = UserModel(
          id: userData['id'],
          username: userData['username'],
          role: userData['role'],
          email: userData['email'] ?? '', // Handle missing email field
          createdAt: userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : null,
        );

        // Save user data to shared preferences
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.saveUserData(user);

        // Update auth state
        ref.read(authProvider.notifier).updateUser(user);

        print('✅ User logged in successfully: ${user.username}');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Welcome ${user.username}!')),
        );

        // Navigation will be handled automatically by the AppRoot widget
        // when the auth state changes
      } else {
        print(response['message']);
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('❌ Login error: $e');
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ResponsiveBuilder(
                  mobile: _buildMobileLayout(context),
                  tablet: _buildTabletLayout(context),
                  desktop: _buildDesktopLayout(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: _buildLoginForm(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 40.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: _buildLoginForm(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: _buildLoginForm(context),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Responsive Image
          ResponsiveContainer(
            mobileHeight: 300,
            tabletHeight: 350,
            desktopHeight: 400,
            child: Image.asset(
              'assets/images/IMG_2379.PNG',
              fit: BoxFit.contain,
            ),
          ),

          // Responsive Spacing
          SizedBox(
            height: context.responsive(
              mobile: 24.0,
              tablet: 32.0,
              desktop: 40.0,
            ),
          ),

          // Responsive Title
          ResponsiveText(
            'Login',
            mobileFontSize: 28.0,
            tabletFontSize: 32.0,
            desktopFontSize: 36.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface,
            textAlign: TextAlign.center,
          ),

          // Responsive Spacing
          SizedBox(
            height: context.responsive(
              mobile: 32.0,
              tablet: 40.0,
              desktop: 48.0,
            ),
          ),

          // Form Fields with responsive spacing
          CustomTextField(
            controller: _usernameController,
            label: 'Username',
            icon: Icons.person_outline,
            validator: Validators.validateUsername,
          ),

          SizedBox(
            height: context.responsive(
              mobile: 16.0,
              tablet: 20.0,
              desktop: 24.0,
            ),
          ),

          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            toggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: Validators.validatePassword,
          ),

          SizedBox(
            height: context.responsive(
              mobile: 24.0,
              tablet: 32.0,
              desktop: 40.0,
            ),
          ),

          // Login Button
          CustomButton(
            label: 'Login',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _handleLogin();
              }
            },
          ),
        ],
      ),
    );
  }
}
