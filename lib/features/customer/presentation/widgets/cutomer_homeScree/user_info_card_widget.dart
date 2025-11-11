import 'package:flutter/material.dart';

class UserInfoCardWidget extends StatefulWidget {
  const UserInfoCardWidget({super.key});

  @override
  State<UserInfoCardWidget> createState() => _UserInfoCardWidgetState();
}

class _UserInfoCardWidgetState extends State<UserInfoCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _glowController;

  late Animation<double> _textAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _glowController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HI, ANOOP with slide animation
        SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-0.3, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: FadeTransition(
            opacity: _textAnimation,
            child: Text(
              'HI, ANOOP',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth > 400
                    ? 22
                    : (screenWidth > 600 ? 17 : 18),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        SizedBox(height: screenWidth > 400 ? 12 : 8),

        // FAST FRESH with scale and glow animation
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: _textAnimation,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Text(
                  'FAST FRESH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth > 400
                        ? 28
                        : (screenWidth > 600 ? 22 : 40),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: const Color(
                          0xFF04CDFE,
                        ).withValues(alpha: _glowAnimation.value * 0.5),
                        blurRadius: 10 * _glowAnimation.value,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: screenWidth > 400 ? 12 : 8),

        // ID with slide and fade animation
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: FadeTransition(
            opacity: _textAnimation,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Text(
                  'ID : 147587',
                  style: TextStyle(
                    color: const Color(0xFF04CDFE),
                    fontSize: screenWidth > 400
                        ? 22
                        : (screenWidth > 600 ? 17 : 16),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: const Color(
                          0xFF04CDFE,
                        ).withValues(alpha: _glowAnimation.value * 0.3),
                        blurRadius: 8 * _glowAnimation.value,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
