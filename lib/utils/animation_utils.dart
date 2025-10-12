// import 'package:flutter/material.dart';
// import 'dart:math' as math;
//
// class AnimationUtils {
//   static const Map<String, Curve> _curveMap = {
//     'ease_out_cubic': Curves.easeOutCubic,
//     'ease_in_out_cubic': Curves.easeInOutCubic,
//     'ease_out_back': Curves.easeOutBack,
//     'ease_in_out_sine': Curves.easeInOutSine,
//     'ease_out': Curves.easeOut,
//     'ease_in_out': Curves.easeInOut,
//     'ease_in': Curves.easeIn,
//     'linear': Curves.linear,
//   };
//
//   static Curve getCurve(String curveName) {
//     return _curveMap[curveName] ?? Curves.easeOut;
//   }
//
//   static Color parseColor(String colorString) {
//     try {
//       return Color(int.parse(colorString.replaceAll('#', '0xFF')));
//     } catch (e) {
//       return Colors.black;
//     }
//   }
//
//   static List<Color> parseColorList(List<dynamic> colorStrings) {
//     return colorStrings.map((color) => parseColor(color.toString())).toList();
//   }
//
//   static Widget createGlowEffect({
//     required Widget child,
//     Color color = Colors.white,
//     double blurRadius = 20.0,
//     double spreadRadius = 5.0,
//     double opacity = 0.3,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: color.withValues(alpha: opacity),
//             blurRadius: blurRadius,
//             spreadRadius: spreadRadius,
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   static Widget createShadowEffect({
//     required Widget child,
//     Color color = Colors.black,
//     double blurRadius = 10.0,
//     double spreadRadius = 2.0,
//     double opacity = 0.2,
//     Offset offset = const Offset(0, 4),
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: color.withValues(alpha: opacity),
//             blurRadius: blurRadius,
//             spreadRadius: spreadRadius,
//             offset: offset,
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   static Widget createParticleEffect({
//     required Widget child,
//     required TickerProvider vsync,
//     int particleCount = 20,
//     Color particleColor = Colors.white,
//     double particleOpacity = 0.6,
//     double particleSize = 2.0,
//     double speed = 1.0,
//     String direction = 'upward',
//   }) {
//     return _ParticleEffectWidget(
//       vsync: vsync,
//       particleCount: particleCount,
//       particleColor: particleColor,
//       particleOpacity: particleOpacity,
//       particleSize: particleSize,
//       speed: speed,
//       direction: direction,
//       child: child,
//     );
//   }
//
//   static AnimationController createAnimationController({
//     required TickerProvider vsync,
//     Duration duration = const Duration(milliseconds: 1000),
//     String? curveName,
//   }) {
//     return AnimationController(
//       duration: duration,
//       vsync: vsync,
//     );
//   }
//
//   static Animation<double> createAnimation({
//     required AnimationController controller,
//     double begin = 0.0,
//     double end = 1.0,
//     String curveName = 'ease_out',
//   }) {
//     return Tween<double>(
//       begin: begin,
//       end: end,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: getCurve(curveName),
//     ));
//   }
//
//   static Future<void> playAnimationSequence({
//     required List<AnimationController> controllers,
//     List<Duration>? delays,
//   }) async {
//     for (int i = 0; i < controllers.length; i++) {
//       if (delays != null && i < delays.length) {
//         await Future.delayed(delays[i]);
//       }
//       await controllers[i].forward();
//     }
//   }
//
//   static Widget createGradientBackground({
//     required List<Color> colors,
//     List<double>? stops,
//     Alignment begin = Alignment.topCenter,
//     Alignment end = Alignment.bottomCenter,
//     GradientType type = GradientType.linear,
//   }) {
//     Gradient gradient;
//
//     switch (type) {
//       case GradientType.linear:
//         gradient = LinearGradient(
//           begin: begin,
//           end: end,
//           colors: colors,
//           stops: stops,
//         );
//         break;
//       case GradientType.radial:
//         gradient = RadialGradient(
//           center: begin,
//           radius: 1.0,
//           colors: colors,
//           stops: stops,
//         );
//         break;
//       case GradientType.sweep:
//         gradient = SweepGradient(
//           center: begin,
//           colors: colors,
//           stops: stops,
//         );
//         break;
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         gradient: gradient,
//       ),
//     );
//   }
// }
//
// enum GradientType {
//   linear,
//   radial,
//   sweep,
// }
//
// class _ParticleEffectWidget extends StatefulWidget {
//   final Widget child;
//   final TickerProvider vsync;
//   final int particleCount;
//   final Color particleColor;
//   final double particleOpacity;
//   final double particleSize;
//   final double speed;
//   final String direction;
//
//   const _ParticleEffectWidget({
//     required this.child,
//     required this.vsync,
//     required this.particleCount,
//     required this.particleColor,
//     required this.particleOpacity,
//     required this.particleSize,
//     required this.speed,
//     required this.direction,
//   });
//
//   @override
//   State<_ParticleEffectWidget> createState() => _ParticleEffectWidgetState();
// }
//
// class _ParticleEffectWidgetState extends State<_ParticleEffectWidget>
//     with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;
//   late List<Animation<double>> _animations;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }
//
//   void _initializeAnimations() {
//     _controllers = List.generate(
//       widget.particleCount,
//       (index) => AnimationController(
//         duration: Duration(milliseconds: (2000 / widget.speed).round()),
//         vsync: this,
//       ),
//     );
//
//     _animations = _controllers.map((controller) {
//       return Tween<double>(
//         begin: 0.0,
//         end: 1.0,
//       ).animate(CurvedAnimation(
//         parent: controller,
//         curve: Curves.easeOut,
//       ));
//     }).toList();
//
//     // Start animations with random delays
//     for (int i = 0; i < _controllers.length; i++) {
//       Future.delayed(
//         Duration(milliseconds: math.Random().nextInt(1000)),
//         () {
//           if (mounted) {
//             _controllers[i].repeat();
//           }
//         },
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         widget.child,
//         ...List.generate(widget.particleCount, (index) {
//           return Positioned(
//             left: math.Random().nextDouble() * 400,
//             top: math.Random().nextDouble() * 400,
//             child: AnimatedBuilder(
//               animation: _animations[index],
//               builder: (context, animation) {
//                 final animationValue = (animation as Animation<double>).value;
//                 return Transform.translate(
//                   offset: Offset(
//                     0,
//                     widget.direction == 'upward'
//                         ? -animationValue * 100
//                         : animationValue * 100,
//                   ),
//                   child: Opacity(
//                     opacity: widget.particleOpacity * (1 - animationValue),
//                     child: Container(
//                       width: widget.particleSize,
//                       height: widget.particleSize,
//                       decoration: BoxDecoration(
//                         color: widget.particleColor,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }
//
// class AnimationSequence {
//   final String name;
//   final double startTime;
//   final Duration duration;
//   final String type;
//   final Map<String, dynamic> properties;
//
//   const AnimationSequence({
//     required this.name,
//     required this.startTime,
//     required this.duration,
//     required this.type,
//     required this.properties,
//   });
//
//   factory AnimationSequence.fromJson(Map<String, dynamic> json) {
//     return AnimationSequence(
//       name: json['name'] ?? '',
//       startTime: (json['start_time'] ?? 0.0).toDouble(),
//       duration: Duration(milliseconds: ((json['duration'] ?? 1.0) * 1000).round()),
//       type: json['type'] ?? '',
//       properties: Map<String, dynamic>.from(json['properties'] ?? {}),
//     );
//   }
// }
//
// class SplashAnimationConfig {
//   final String version;
//   final double duration;
//   final List<AnimationSequence> sequences;
//   final Map<String, dynamic> effects;
//   final Map<String, dynamic> timing;
//
//   const SplashAnimationConfig({
//     required this.version,
//     required this.duration,
//     required this.sequences,
//     required this.effects,
//     required this.timing,
//   });
//
//   factory SplashAnimationConfig.fromJson(Map<String, dynamic> json) {
//     final splashAnimations = json['splash_animations'] ?? {};
//
//     return SplashAnimationConfig(
//       version: splashAnimations['version'] ?? '1.0.0',
//       duration: (splashAnimations['duration'] ?? 3.0).toDouble(),
//       sequences: (splashAnimations['sequences'] as List<dynamic>? ?? [])
//           .map((seq) => AnimationSequence.fromJson(seq))
//           .toList(),
//       effects: Map<String, dynamic>.from(splashAnimations['effects'] ?? {}),
//       timing: Map<String, dynamic>.from(splashAnimations['timing'] ?? {}),
//     );
//   }
//
//   static Future<SplashAnimationConfig> loadFromAssets(String path) async {
//     // This would typically load from assets
//     // For now, return a default config
//     return const SplashAnimationConfig(
//       version: '1.0.0',
//       duration: 3.0,
//       sequences: [],
//       effects: {},
//       timing: {},
//     );
//   }
// }
