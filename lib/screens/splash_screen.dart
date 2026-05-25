import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_selector_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    print('🚀 SPLASH SCREEN: initState called');
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    print('⏳ SPLASH: Waiting 2.5 seconds...');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    print('✅ SPLASH: Delay complete, checking mounted');
    if (!mounted) {
      print('❌ SPLASH: Widget not mounted, returning');
      return;
    }

    print('📱 SPLASH: Getting SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    final hasSeenLanguageSelector = prefs.getBool('has_seen_language_selector') ?? false;
    final currentLanguage = prefs.getString('language') ?? 'en';

    print('🔍 SPLASH: hasSeenLanguageSelector = $hasSeenLanguageSelector');
    print('🔍 SPLASH: currentLanguage = $currentLanguage');

    if (!mounted) {
      print('❌ SPLASH: Widget not mounted after prefs check, returning');
      return;
    }

    if (!hasSeenLanguageSelector) {
      print('🌍 SPLASH: First launch detected - navigating to Language Selector');
      try {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              print('🏗️ SPLASH: Building LanguageSelectorScreen');
              return LanguageSelectorScreen(
                currentLanguage: currentLanguage,
                isFirstLaunch: true,
              );
            },
          ),
        );
        print('✅ SPLASH: Navigation to Language Selector initiated');
      } catch (e) {
        print('❌ SPLASH: Error navigating to Language Selector: $e');
      }
    } else {
      print('🏠 SPLASH: Not first launch - navigating to Home Screen');
      try {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              print('🏗️ SPLASH: Building HomeScreen');
              return const HomeScreen();
            },
          ),
        );
        print('✅ SPLASH: Navigation to Home Screen initiated');
      } catch (e) {
        print('❌ SPLASH: Error navigating to Home Screen: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 SPLASH: Building UI');
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF63B3ED),
              Color(0xFF4A90E2),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            Positioned(
              top: -100,
              right: -100,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated compass icon with actual image
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: RotationTransition(
                      turns: _rotateAnimation,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(90),
                          child: Image.asset(
                            'assets/images/compass-icon-professional.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Compass Safe Pro',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}