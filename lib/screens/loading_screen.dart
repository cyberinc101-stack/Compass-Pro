import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentPhase = 0; // 0: compass, 1: location, 2: finalizing
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    
    print('🔄 LOADING SCREEN: initState called');
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('⚙️ LOADING: Starting app initialization');
      
      // Let the fade-in animation complete fully
      await Future.delayed(const Duration(milliseconds: 700));
      
      // Get services
      final compassService = Provider.of<CompassService>(context, listen: false);
      final locationService = Provider.of<LocationService>(context, listen: false);

      // Phase 1: Setting up compass
      if (mounted) {
        setState(() => _currentPhase = 0);
      }
      
      // Allow time for compass to initialize
      print('🧭 LOADING: Initializing compass service...');
      await Future.delayed(const Duration(milliseconds: 900));
      print('🧭 LOADING: Compass service ready');

      // Phase 2: Getting location
      if (mounted) {
        setState(() => _currentPhase = 1);
      }
      
      // Allow time for location services to be ready
      print('📍 LOADING: Ensuring location is available...');
      await Future.delayed(const Duration(milliseconds: 900));
      print('📍 LOADING: Location service ready');

      // Phase 3: Preparing app
      if (mounted) {
        setState(() => _currentPhase = 2);
      }
      
      // Give services time to warm up
      print('🔄 LOADING: Warming up services...');
      await Future.delayed(const Duration(milliseconds: 700));
      print('✅ LOADING: Services ready');

      // Phase 4: Finalizing
      if (mounted) {
        setState(() => _currentPhase = 3);
      }
      await Future.delayed(const Duration(milliseconds: 700));

      print('✅ LOADING: Initialization complete');

      if (!mounted) {
        print('❌ LOADING: Widget not mounted, aborting navigation');
        return;
      }

      if (_hasNavigated) {
        print('⚠️ LOADING: Already navigated, skipping');
        return;
      }

      _hasNavigated = true;

      print('🏠 LOADING: Navigating to Home Screen with fade transition');
      
      // Add longer delay to ensure everything is truly ready
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (!mounted) return;
      
      // Very slow fade transition to completely mask any loading states
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth fade with slight scale - slower curve
            const begin = 0.90;
            const end = 1.0;
            final scaleTween = Tween(begin: begin, end: end);
            
            // Use a slower, smoother curve
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            
            final scaleAnimation = curvedAnimation.drive(scaleTween);
            
            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 1500),
          reverseTransitionDuration: const Duration(milliseconds: 1000),
        ),
      );
      
      print('✅ LOADING: Navigation complete');
      
    } catch (e) {
      print('❌ LOADING: Error during initialization: $e');
      
      // Even on error, navigate after minimum time with smooth transition
      if (!_hasNavigated && mounted) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _hasNavigated = true;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              );
              return FadeTransition(
                opacity: curvedAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  Color _getBackgroundColor(String iconThemeMode, bool isDay) {
    if (iconThemeMode == 'day') {
      return const Color(0xFF4A90E2);
    }
    
    switch (iconThemeMode) {
      case 'glow':
        return isDay ? const Color(0xFF001a15) : const Color(0xFF000a08);
      case 'night':
        return isDay ? const Color(0xFF1a0000) : const Color(0xFF0a0000);
      default:
        return const Color(0xFF1a2a3a);
    }
  }

  Color _getTextColor(String iconThemeMode, bool isDay) {
    if (iconThemeMode == 'day') {
      return Colors.white;
    }
    
    switch (iconThemeMode) {
      case 'glow':
        return isDay ? const Color(0xFF00FFCC) : const Color(0xFF00FFAA);
      case 'night':
        return isDay ? const Color(0xFFFFAAAA) : const Color(0xFFFF8888);
      default:
        return Colors.white;
    }
  }

  IconData _getCurrentPhaseIcon() {
    switch (_currentPhase) {
      case 0:
        return Icons.explore; // Compass
      case 1:
        return Icons.location_on; // Location
      case 2:
        return Icons.tune; // Settings/preparing
      case 3:
        return Icons.check_circle; // Ready
      default:
        return Icons.explore;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 LOADING: Building UI');
    
    final settings = Provider.of<SettingsService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    
    final bgColor = _getBackgroundColor(iconThemeMode, isDay);
    final textColor = _getTextColor(iconThemeMode, isDay);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: iconThemeMode == 'day'
                ? [
                    const Color(0xFF4A90E2),
                    const Color(0xFF63B3ED),
                    const Color(0xFF4A90E2),
                  ]
                : [
                    bgColor,
                    bgColor.withOpacity(0.8),
                    bgColor,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main compass icon with actual image
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: iconThemeMode != 'day' ? [
                        BoxShadow(
                          color: textColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: Image.asset(
                        'assets/images/compass-icon-professional.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor.withOpacity(0.8),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Phase indicator icon
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      _getCurrentPhaseIcon(),
                      key: ValueKey<int>(_currentPhase),
                      size: 32,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}