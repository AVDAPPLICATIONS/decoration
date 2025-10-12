import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic>? _logoConfig;

  @override
  void initState() {
    super.initState();
    _loadLogoConfig();
    _initializeAnimations();
    _startAnimations();
  }

  void _loadLogoConfig() async {
    try {
      final configString = await DefaultAssetBundle.of(context)
          .loadString('assets/config/logo_config.json');
      setState(() {
        _logoConfig = json.decode(configString);
      });
    } catch (e) {
      print('Error loading logo config: $e');
    }
  }

  void _initializeAnimations() {
    // Logo scale and rotation animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOutCubic,
    ));

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();
    
    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 500));
    await _textController.forward();
    
    // Start pulse animation
    _pulseController.repeat(reverse: true);
    
    // Start fade animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoConfig = _logoConfig?['logo'];
    final colors = logoConfig?['colors'] ?? {};
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          // gradient: RadialGradient(
          //   center: Alignment.center,
          //   radius: 1.0,
          //   colors: [
          //     Color(int.parse(colors['primary']?.replaceAll('#', '0xFF') ?? '0xFFFF6B35')),
          //     Color(int.parse(colors['secondary']?.replaceAll('#', '0xFF') ?? '0xFFF7931E')),
          //   ],
          // ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section with animations
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoScaleAnimation,
                      _logoRotationAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          // shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/Untitled-1.png',
                          fit: BoxFit.fill,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Text section with animations
              // Expanded(
              //   flex: 2,
              //   child: AnimatedBuilder(
              //     animation: Listenable.merge([
              //       _textSlideAnimation,
              //       _textOpacityAnimation,
              //     ]),
              //     builder: (context, child) {
              //       return Transform.translate(
              //         offset: Offset(0, _textSlideAnimation.value),
              //         child: Opacity(
              //           opacity: _textOpacityAnimation.value,
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               // Primary text
              //               Text(
              //                 'HARIPRABODHAM',
              //                 style: TextStyle(
              //                   fontSize: 32,
              //                   fontWeight: FontWeight.bold,
              //                   color: Color(int.parse(colors['text_primary']?.replaceAll('#', '0xFF') ?? '0xFFCC0000')),
              //                   letterSpacing: 2.0,
              //                   shadows: [
              //                     Shadow(
              //                       color: Colors.white.withOpacity(0.5),
              //                       blurRadius: 10,
              //                     ),
              //                   ],
              //                 ),
              //                 textAlign: TextAlign.center,
              //               ),
              //               const SizedBox(height: 8),
              //
              //               // Secondary text
              //               Text(
              //                 'SEVA BHAKTI',
              //                 style: TextStyle(
              //                   fontSize: 24,
              //                   fontWeight: FontWeight.w500,
              //                   color: Color.fromARGB(220, 245, 185, 11),
              //                   letterSpacing: 1.5,
              //                   shadows: [
              //                     Shadow(
              //                       color: Colors.white.withOpacity(0.3),
              //                       blurRadius: 5,
              //                     ),
              //                   ],
              //                 ),
              //                 textAlign: TextAlign.center,
              //               ),
              //               const SizedBox(height: 20),
              //
              //               // Loading indicator
              //               AnimatedBuilder(
              //                 animation: _fadeAnimation,
              //                 builder: (context, child) {
              //                   return Opacity(
              //                     opacity: _fadeAnimation.value,
              //                     child: SizedBox(
              //                       width: 30,
              //                       height: 30,
              //                       child: CircularProgressIndicator(
              //                         strokeWidth: 3,
              //                         valueColor: AlwaysStoppedAnimation<Color>(
              //                           Colors.white.withOpacity(0.8),
              //                         ),
              //                       ),
              //                     ),
              //                   );
              //                 },
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
