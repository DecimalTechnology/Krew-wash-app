import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Navigate to auth wrapper after splash
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth-wrapper');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return isIOS ? _buildIOSSplashScreen() : _buildAndroidSplashScreen();
  }

  Widget _buildIOSSplashScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginScreen/car.png'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Brand Name
                Column(
                  children: [
                    // Logo with iOS-style rounded corners
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // More rounded for iOS
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4AA).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/Logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // KREW text
                    const Text(
                      'KREW',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontFamily: '.SF Pro Display', // iOS system font
                      ),
                    ),
                    const SizedBox(height: 8),
                    // CAR WASH text
                    const Text(
                      'CAR WASH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        letterSpacing: 4,
                        fontFamily: '.SF Pro Text', // iOS system font
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
                // Tagline
                Column(
                  children: [
                    const Text(
                      'PROFESSIONAL CAR CARE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4AA), // Teal color
                        letterSpacing: 1,
                        fontFamily: '.SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AT YOUR DOORSTEP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                        fontFamily: '.SF Pro Display',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // iOS-style loading indicator
                const CupertinoActivityIndicator(
                  color: Color(0xFF00D4AA),
                  radius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidSplashScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginScreen/car.png'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Brand Name
                Column(
                  children: [
                    // Logo with Material Design
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4AA).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/Logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // KREW text
                    const Text(
                      'KREW',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // CAR WASH text
                    const Text(
                      'CAR WASH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
                // Tagline
                Column(
                  children: [
                    const Text(
                      'PROFESSIONAL CAR CARE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D4AA), // Teal color
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AT YOUR DOORSTEP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Material Design loading indicator
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00D4AA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
