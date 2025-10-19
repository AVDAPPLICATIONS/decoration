import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Custom loading bar widget with animated progress
class CustomLoadingBar extends StatefulWidget {
  final String? message;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double? height;
  final bool showMessage;
  final bool showProgress;

  const CustomLoadingBar({
    Key? key,
    this.message,
    this.primaryColor,
    this.backgroundColor,
    this.height,
    this.showMessage = true,
    this.showProgress = true,
  }) : super(key: key);

  @override
  State<CustomLoadingBar> createState() => _CustomLoadingBarState();
}

class _CustomLoadingBarState extends State<CustomLoadingBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller for the progress bar
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse animation controller for the loading indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _animationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = widget.primaryColor ?? colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? colorScheme.surface;
    final height = widget.height ??
        context.responsive(mobile: 6.0, tablet: 8.0, desktop: 10.0);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height! / 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height! / 2),
        child: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: backgroundColor,
            ),
            // Animated progress bar
            if (widget.showProgress)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          primaryColor.withOpacity(0.3),
                          primaryColor,
                          primaryColor.withOpacity(0.3),
                        ],
                        stops: [
                          _animation.value - 0.1,
                          _animation.value,
                          _animation.value + 0.1,
                        ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                      ),
                    ),
                  );
                },
              ),
            // Loading indicator
            if (widget.showMessage)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: context.responsive(
                                  mobile: 16.0, tablet: 18.0, desktop: 20.0),
                              height: context.responsive(
                                  mobile: 16.0, tablet: 18.0, desktop: 20.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                            SizedBox(
                                width: context.responsive(
                                    mobile: 8.0, tablet: 10.0, desktop: 12.0)),
                            Text(
                              widget.message ?? 'Loading...',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: context.responsive(
                                    mobile: 12.0, tablet: 14.0, desktop: 16.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Full screen loading overlay
class CustomLoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool showProgress;

  const CustomLoadingOverlay({
    Key? key,
    this.message,
    this.primaryColor,
    this.backgroundColor,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = this.primaryColor ?? colorScheme.primary;
    final backgroundColor =
        this.backgroundColor ?? colorScheme.surface.withOpacity(0.95);

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            AnimatedBuilder(
              animation: _createAnimationController(context),
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      1.0 + (0.2 * _createAnimationController(context).value),
                  child: Container(
                    width: context.responsive(
                        mobile: 80.0, tablet: 90.0, desktop: 100.0),
                    height: context.responsive(
                        mobile: 80.0, tablet: 90.0, desktop: 100.0),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 2.0,
                      ),
                    ),
                    child: Icon(
                      Icons.event,
                      color: primaryColor,
                      size: context.responsive(
                          mobile: 40.0, tablet: 45.0, desktop: 50.0),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
                height: context.responsive(
                    mobile: 24.0, tablet: 28.0, desktop: 32.0)),
            // Loading message
            Text(
              message ?? 'Loading events...',
              style: TextStyle(
                color: primaryColor,
                fontSize: context.responsive(
                    mobile: 18.0, tablet: 20.0, desktop: 22.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
                height: context.responsive(
                    mobile: 16.0, tablet: 18.0, desktop: 20.0)),
            // Progress bar
            if (showProgress)
              Container(
                width: context.responsive(
                    mobile: 200.0, tablet: 250.0, desktop: 300.0),
                child: CustomLoadingBar(
                  primaryColor: primaryColor,
                  backgroundColor: backgroundColor,
                  showMessage: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  AnimationController _createAnimationController(BuildContext context) {
    // This is a simplified version - in a real implementation,
    // you'd want to use a proper AnimationController
    return AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: context as TickerProvider,
    );
  }
}

/// Simple loading indicator with custom styling
class CustomLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const CustomLoadingIndicator({
    Key? key,
    this.message,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = color ?? colorScheme.primary;
    final indicatorSize =
        size ?? context.responsive(mobile: 24.0, tablet: 28.0, desktop: 32.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        if (message != null) ...[
          SizedBox(
              height: context.responsive(
                  mobile: 12.0, tablet: 14.0, desktop: 16.0)),
          Text(
            message!,
            style: TextStyle(
              color: primaryColor,
              fontSize:
                  context.responsive(mobile: 14.0, tablet: 16.0, desktop: 18.0),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
