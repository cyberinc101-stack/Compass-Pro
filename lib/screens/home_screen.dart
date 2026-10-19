import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/premium_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/ad_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/ad_banner_widget.dart';
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
import 'membership_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  bool _isInitialized = false;
  int _compassKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  bool _isDay() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 20;
  }

  Color _getBackgroundColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow': return isDay ? const Color(0xFF001a15) : const Color(0xFF000a08);
      case 'night': return isDay ? const Color(0xFF1a0000) : const Color(0xFF0a0000);
      default: return const Color(0xFF1a2a3a);
    }
  }

  List<Color> _getGradientColors(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow': return isDay
          ? [const Color(0xFF002a22), const Color(0xFF003a30)]
          : [const Color(0xFF001510), const Color(0xFF002018)];
      case 'night': return isDay
          ? [const Color(0xFF2a0000), const Color(0xFF3a0000)]
          : [const Color(0xFF150000), const Color(0xFF200000)];
      default: return [const Color(0xFF2a3a4a), const Color(0xFF3a4a5a)];
    }
  }

  Color _getTextColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow': return isDay ? const Color(0xFF00FFCC) : const Color(0xFF00FFAA);
      case 'night': return isDay ? const Color(0xFFFFAAAA) : const Color(0xFFFF8888);
      default: return Colors.white;
    }
  }

  Color _getAccentColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow': return isDay ? const Color(0xFF00FFCC) : const Color(0xFF00FFAA);
      case 'night': return isDay ? const Color(0xFFFFAAAA) : const Color(0xFFFF8888);
      default: return const Color(0xFF4A90E2);
    }
  }

  Color _getOverlayColor(String iconThemeMode, bool isDay) {
    switch (iconThemeMode) {
      case 'glow': return isDay
          ? const Color(0xFF00FFAA).withOpacity(0.15)
          : const Color(0xFF00FF88).withOpacity(0.15);
      case 'night': return isDay
          ? const Color(0xFFFF8888).withOpacity(0.15)
          : const Color(0xFFFF6666).withOpacity(0.15);
      default: return Colors.white.withOpacity(0.1);
    }
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return;
    try {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      // Pass context so prominent disclosure dialog can be shown
      // before the system permission prompt fires
      await locationService.getCurrentLocation(context: context);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _currentIndex = 0;
        _isInitialized = true;
      });
    }
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  void _navigateToCompass() {
    if (_currentIndex != 0) setState(() => _currentIndex = 0);
  }

  void _handleNavigation(int index) async {
    debugPrint('🧭 NAV TAPPED: index=$index, current=$_currentIndex');
    final adService = Provider.of<AdService>(context, listen: false);

    if (index == 0) {
      final prefs = await SharedPreferences.getInstance();
      final currentStyle = prefs.getString('compass_style') ?? 'classic';
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CompassStyleSelectorScreen(currentStyle: currentStyle),
        ),
      );
      if (mounted) setState(() => _compassKey++);
      adService.onNavigation();
    } else if (index == 5) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BackgroundSelectorScreen(currentBackground: 'night_sky'),
        ),
      );
      if (mounted) setState(() => _compassKey++);
      adService.onNavigation();
    } else if (index == 9) {
      // Don't fire an interstitial right before showing the paywall —
      // that's a bad moment to interrupt with an ad.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MembershipScreen()),
      );
    } else {
      adService.onNavigation();
      setState(() => _currentIndex = index);
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: overlayColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accentColor.withOpacity(0.3), width: 2),
                ),
                child: Icon(Icons.construction_rounded,
                    size: 64, color: accentColor),
              ),
              const SizedBox(height: 32),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Coming Soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor.withOpacity(0.7), fontSize: 18)),
            ],
          ),
        ),
      ),
    );
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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                builder: (context, value, child) => Transform.rotate(
                  angle: value * 6.28319,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: accentColor.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(Icons.explore, size: 64, color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(accentColor),
                    strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              Text('Initializing Compass Pro...',
                  style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Getting your location ready',
                  style: TextStyle(
                      color: textColor.withOpacity(0.6), fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: [
                    CompassScreen(key: ValueKey(_compassKey)),                 // 0
                    WeatherScreen(onBackToCompass: _navigateToCompass),        // 1
                    LocationScreen(onBackToCompass: _navigateToCompass),       // 2
                    TrackingScreen(onBackToCompass: _navigateToCompass),       // 3
                    SavedLocationsScreen(onBackToCompass: _navigateToCompass), // 4
                    _buildPlaceholderScreen('Background Theme'),               // 5
                    CalibrationScreen(onBackToCompass: _navigateToCompass),    // 6
                    SettingsScreen(onBackToCompass: _navigateToCompass),       // 7
                    SafetyTrackingScreen(onBackPressed: _navigateToCompass),   // 8
                  ],
                ),
                if (_currentIndex == 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNavigation(
                      currentIndex: _currentIndex,
                      isDarkMode: _isDarkMode,
                      onThemeToggle: _toggleTheme,
                      onItemTapped: _handleNavigation,
                    ),
                  ),
              ],
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}