import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../widgets/bottom_navigation.dart';
import 'compass_screen.dart';
import 'compass_style_selector_screen.dart';
import 'background_selector_screen.dart';
import 'calibration_screen.dart';
import 'settings_screen.dart';
import 'saved_locations_screen.dart';
import 'location_screen.dart';
import 'weather_screen_files/weather_screen.dart';
import 'tracking_screen.dart';
import 'safety_tracking_screen/safety_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = -1;
  bool _isDarkMode = false;
  bool _isInitialized = false;
  int _compassKey = 0; // ADDED: Key to force compass reload

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  Color _getBackgroundColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF001a15)
            : const Color(0xFF000a08);
      case 'night':
        return isDay
            ? const Color(0xFF1a0000)
            : const Color(0xFF0a0000);
      default:
        return const Color(0xFF1a2a3a);
    }
  }

  List<Color> _getGradientColors(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? [
                const Color(0xFF002a22),
                const Color(0xFF003a30),
              ]
            : [
                const Color(0xFF001510),
                const Color(0xFF002018),
              ];
      case 'night':
        return isDay
            ? [
                const Color(0xFF2a0000),
                const Color(0xFF3a0000),
              ]
            : [
                const Color(0xFF150000),
                const Color(0xFF200000),
              ];
      default:
        return [
          const Color(0xFF2a3a4a),
          const Color(0xFF3a4a5a),
        ];
    }
  }

  Color _getTextColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFCC)
            : const Color(0xFF00FFAA);
      case 'night':
        return isDay
            ? const Color(0xFFFFAAAA)
            : const Color(0xFFFF8888);
      default:
        return Colors.white;
    }
  }

  Color _getAccentColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFCC)
            : const Color(0xFF00FFAA);
      case 'night':
        return isDay
            ? const Color(0xFFFFAAAA)
            : const Color(0xFFFF8888);
      default:
        return const Color(0xFF4A90E2);
    }
  }

  Color _getOverlayColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFAA).withOpacity(0.15)
            : const Color(0xFF00FF88).withOpacity(0.15);
      case 'night':
        return isDay
            ? const Color(0xFFFF8888).withOpacity(0.15)
            : const Color(0xFFFF6666).withOpacity(0.15);
      default:
        return Colors.white.withOpacity(0.1);
    }
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return;
    
    try {
      // Initialize location service
      final locationService = Provider.of<LocationService>(context, listen: false);
      await locationService.initialize();
      
      // Use addPostFrameCallback to defer setState
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
              _isInitialized = true;
            });
          }
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      // Even if initialization fails, show the app
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
              _isInitialized = true;
            });
          }
        });
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _navigateToCompass() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _handleNavigation(int index) async {
    // If compass icon (index 0) is tapped, open compass style selector
    if (index == 0) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompassStyleSelectorScreen(
            currentStyle: 'classic',
          ),
        ),
      );
      // Force compass to reload with new style
      if (mounted) {
        setState(() {
          _compassKey++; // Increment key to force rebuild
        });
      }
    }
    // If background icon (index 5) is tapped, open background selector
    else if (index == 5) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BackgroundSelectorScreen(
            currentBackground: 'classic',
          ),
        ),
      );
      // Force compass to reload with new background
      if (mounted) {
        setState(() {
          _compassKey++; // Increment key to force rebuild
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildPlaceholderScreen(String title) {
    final settings = Provider.of<SettingsService>(context, listen: false);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    
    final gradientColors = _getGradientColors(iconThemeMode, isDay);
    final textColor = _getTextColor(iconThemeMode, isDay);
    final overlayColor = _getOverlayColor(iconThemeMode, isDay);
    final accentColor = _getAccentColor(iconThemeMode, isDay);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: overlayColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: iconThemeMode != 'default' ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      Icons.construction_rounded,
                      size: 64,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      shadows: iconThemeMode != 'default' ? [
                        Shadow(
                          color: textColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ] : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    translate('coming_soon'), // CHANGED: Replaced 'Coming Soon'
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _navigateToCompass,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: overlayColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: iconThemeMode != 'default' ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ADDED: Helper function to access translations
  // You should replace this with your actual translation service/function
  String translate(String key) {
    // TODO: Replace with your actual translation service
    // Example: return TranslationService.translate(key);
    // For now, returning the key as placeholder
    final translations = {
      'coming_soon': 'Coming Soon',
      'background_theme': 'Background Theme',
      'initializing_compass_pro': 'Initializing Compass Pro...',
      'getting_location_ready': 'Getting your location ready',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      final settings = Provider.of<SettingsService>(context, listen: false);
      final iconThemeMode = settings.iconThemeMode ?? 'default';
      final isDay = _isDay();
      
      final bgColor = _getBackgroundColor(iconThemeMode, isDay);
      final textColor = _getTextColor(iconThemeMode, isDay);
      final accentColor = _getAccentColor(iconThemeMode, isDay);

      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated compass icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 6.28319, // 2 * PI for full rotation
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: iconThemeMode != 'default' ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        Icons.explore,
                        size: 64,
                        color: accentColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Pulsing loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                translate('initializing_compass_pro'), // CHANGED: Replaced 'Initializing Compass Pro...'
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: iconThemeMode != 'default' ? [
                    Shadow(
                      color: textColor.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ] : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translate('getting_location_ready'), // CHANGED: Replaced 'Getting your location ready'
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // CHANGED: Use IndexedStack to keep all screens alive
          IndexedStack(
            index: _currentIndex >= 0 ? _currentIndex : 0,
            children: [
              CompassScreen(key: ValueKey(_compassKey)), // 0 - Compass with key for reloading
              WeatherScreen(onBackToCompass: _navigateToCompass), // 1 - Weather
              LocationScreen(onBackToCompass: _navigateToCompass), // 2 - Location
              TrackingScreen(onBackToCompass: _navigateToCompass), // 3 - Tracking
              SavedLocationsScreen(onBackToCompass: _navigateToCompass), // 4 - Saved Locations
              _buildPlaceholderScreen(translate('background_theme')), // 5 - Background (won't show as it opens selector) // CHANGED: Replaced 'Background Theme'
              CalibrationScreen(onBackToCompass: _navigateToCompass), // 6 - Calibration
              SettingsScreen(onBackToCompass: _navigateToCompass), // 7 - Settings
              SafetyTrackingScreen(onBackPressed: _navigateToCompass), // 8 - Safety Tracking
            ],
          ),
          
          // Only show bottom navigation on compass screen (index 0)
          if (_currentIndex == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavigation(
                currentIndex: _currentIndex,
                isDarkMode: _isDarkMode,
                onThemeToggle: _toggleTheme,
                onItemTapped: (index) {
                  // Remove premium checks - all screens accessible during development
                  _handleNavigation(index);
                },
              ),
            ),
        ],
      ),
    );
  }
}