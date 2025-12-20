import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class UserInfoCardWidget extends StatefulWidget {
  const UserInfoCardWidget({
    super.key,
    this.userName,
    this.userId,
    this.sessionText,
  });

  final String? userName;
  final String? userId;
  /// Text shown under ID (example: "SESSIONS: 3")
  final String? sessionText;

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
    final name = (widget.userName?.trim().isNotEmpty == true)
        ? widget.userName!.trim().toUpperCase()
        : 'USER';
    final idValue = (widget.userId?.trim().isNotEmpty == true)
        ? widget.userId!.trim()
        : '---';
    final sessionValue = (widget.sessionText?.trim().isNotEmpty == true)
        ? widget.sessionText!.trim().toUpperCase()
        : 'SESSIONS';

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
              'HI, $name',
              style: AppTheme.bebasNeue(
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
                  style: AppTheme.bebasNeue(
                    color: Colors.white,
                    fontSize: screenWidth > 400
                        ? 28
                        : (screenWidth > 600 ? 22 : 40),
                    fontWeight: FontWeight.w400,
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
                  'ID : $idValue',
                  style: AppTheme.bebasNeue(
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
        SizedBox(height: screenWidth > 400 ? 10 : 6),
        FadeTransition(
          opacity: _textAnimation,
          child: Text(
            sessionValue,
            style: AppTheme.bebasNeue(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: screenWidth > 400 ? 16 : 14,
              letterSpacing: 1.0,
            ),
          ),
        ),
        // Extra spacing below SESSIONS
        SizedBox(height: screenWidth > 400 ? 28 : 24),
      ],
    );
  }
}
