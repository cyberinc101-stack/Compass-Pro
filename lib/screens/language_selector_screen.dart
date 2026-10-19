import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import '../services/location_service.dart';
import '../services/ad_service.dart';
import 'loading_screen.dart';
import 'home_screen.dart';

class LanguageSelectorScreen extends StatefulWidget {
  final String currentLanguage;
  final bool isFirstLaunch;

  const LanguageSelectorScreen({
    Key? key,
    this.currentLanguage = 'en',
    this.isFirstLaunch = false,
  }) : super(key: key);

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  late String selectedLanguage;
  bool _isContinuing = false;

  // Languages ordered by country power/influence (top to bottom)
  final List<LanguageOption> languages = [
    // 1. United States
    LanguageOption(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    // 2. China
    LanguageOption(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    // 3. Japan
    LanguageOption(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    // 4. Germany
    LanguageOption(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    // 5. United Kingdom
    LanguageOption(code: 'en_gb', name: 'English (UK)', nativeName: 'English (UK)', flag: '🇬🇧'),
    // 6. India
    LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    // 7. France
    LanguageOption(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    // 8. Italy
    LanguageOption(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    // 9. Brazil
    LanguageOption(code: 'pt_br', name: 'Portuguese (Brazil)', nativeName: 'Português (Brasil)', flag: '🇧🇷'),
    // 10. South Korea
    LanguageOption(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    // 11. Russia
    LanguageOption(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
    // 12. Spain
    LanguageOption(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    // 13. Mexico
    LanguageOption(code: 'es_mx', name: 'Spanish (Mexico)', nativeName: 'Español (México)', flag: '🇲🇽'),
    // 14. Indonesia
    LanguageOption(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    // 15. Netherlands
    LanguageOption(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
    // 16. Turkey
    LanguageOption(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    // 17. Saudi Arabia
    LanguageOption(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    // 18. Thailand
    LanguageOption(code: 'th', name: 'Thai', nativeName: 'ไทย', flag: '🇹🇭'),
    // 19. Poland
    LanguageOption(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱'),
    // 20. Portugal
    LanguageOption(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    // Other Indian Languages
    LanguageOption(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇧🇩'),
    LanguageOption(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
    LanguageOption(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    LanguageOption(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    LanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    // Other Southeast Asian Languages
    LanguageOption(code: 'jv', name: 'Javanese', nativeName: 'Basa Jawa', flag: '🇮🇩'),
    LanguageOption(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
  ];

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.currentLanguage;
    print('🌍 LANGUAGE SELECTOR: initState - isFirstLaunch=${widget.isFirstLaunch}, currentLanguage=${widget.currentLanguage}');
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

  Color _getCardBackgroundColor(String iconThemeMode, bool isDay) {
    if (iconThemeMode == 'day') {
      return Colors.white.withOpacity(0.95);
    }
    
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF002a22).withOpacity(0.6)
            : const Color(0xFF001510).withOpacity(0.6);
      case 'night':
        return isDay
            ? const Color(0xFF2a0000).withOpacity(0.6)
            : const Color(0xFF150000).withOpacity(0.6);
      default:
        return const Color(0xFF2a3a4a).withOpacity(0.6);
    }
  }

  Color _getTextColor(String iconThemeMode, bool isDay) {
    if (iconThemeMode == 'day') {
      return Colors.black87;
    }
    
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

  Color _getSecondaryTextColor(String iconThemeMode, bool isDay) {
    if (iconThemeMode == 'day') {
      return Colors.black54;
    }
    
    switch (iconThemeMode) {
      case 'glow':
        return isDay
            ? const Color(0xFF00FFAA).withOpacity(0.7)
            : const Color(0xFF00FF88).withOpacity(0.7);
      case 'night':
        return isDay
            ? const Color(0xFFFF8888).withOpacity(0.7)
            : const Color(0xFFFF6666).withOpacity(0.7);
      default:
        return Colors.white.withOpacity(0.7);
    }
  }

  Color _getAccentColor(String iconThemeMode, bool isDay) {
    if (iconThemeMode == 'day') {
      return const Color(0xFF4A90E2);
    }
    
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
    if (iconThemeMode == 'day') {
      return Colors.grey[300]!;
    }
    
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

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  void _goToLoadingScreen() {
    if (!mounted) return;
    print('🔄 LANGUAGE SELECTOR: Navigating to Loading Screen');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoadingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.95;
          const end = 1.0;
          final scaleTween = Tween(begin: begin, end: end);
          final scaleAnimation = animation.drive(scaleTween);

          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _goToHomeScreen() {
    if (!mounted) return;
    print('🏠 LANGUAGE SELECTOR: Navigating to Home Screen');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_isContinuing) return; // guard against double taps
    _isContinuing = true;

    print('🚀 LANGUAGE SELECTOR: Continue button pressed');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_language_selector', true);
    await prefs.setString('language', selectedLanguage);
    
    // Update the localization service to apply the language
    final localization = Provider.of<LocalizationService>(context, listen: false);
    await localization.setLanguage(selectedLanguage);
    
    // Update location service language for geocoding
    try {
      final locationService = Provider.of<LocationService>(context, listen: false);
      locationService.setLanguage(selectedLanguage);
      print('✅ LOCATION SERVICE: Language set to $selectedLanguage in Continue');
    } catch (e) {
      print('❌ ERROR updating location service in Continue: $e');
    }
    
    print('✅ LANGUAGE SELECTOR: Preferences saved and language updated to $selectedLanguage');
    
    if (!mounted) {
      print('❌ LANGUAGE SELECTOR: Widget not mounted');
      return;
    }

    if (widget.isFirstLaunch) {
      print('🎬 LANGUAGE SELECTOR: First launch - showing interstitial before Loading Screen');
      final adService = Provider.of<AdService>(context, listen: false);
      // showInterstitial calls onDismissed immediately if no ad is loaded,
      // so this never blocks the first-launch flow.
      adService.showInterstitial(
        onDismissed: () {
          _goToLoadingScreen();
        },
      );
    } else {
      _goToHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final localization = Provider.of<LocalizationService>(context);
    final iconThemeMode = settings.iconThemeMode ?? 'default';
    final isDay = _isDay();
    
    final bgColor = _getBackgroundColor(iconThemeMode, isDay);
    final cardBgColor = _getCardBackgroundColor(iconThemeMode, isDay);
    final textColor = _getTextColor(iconThemeMode, isDay);
    final secondaryTextColor = _getSecondaryTextColor(iconThemeMode, isDay);
    final accentColor = _getAccentColor(iconThemeMode, isDay);
    final overlayColor = _getOverlayColor(iconThemeMode, isDay);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: iconThemeMode == 'day' ? 2 : 0,
        iconTheme: IconThemeData(color: textColor),
        leading: widget.isFirstLaunch
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => Navigator.pop(context, selectedLanguage),
              ),
        automaticallyImplyLeading: !widget.isFirstLaunch,
        actions: widget.isFirstLaunch
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: IconButton(
                      onPressed: _handleContinue,
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: localization.translate('continue'),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: iconThemeMode == 'day' 
                ? [
                    const Color(0xFF4A90E2),
                    const Color(0xFF63B3ED),
                  ]
                : [
                    bgColor,
                    bgColor.withOpacity(0.8),
                  ],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            final isSelected = selectedLanguage == language.code;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 30)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: iconThemeMode == 'day' ? 4 : 0,
                color: isSelected ? cardBgColor : cardBgColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected 
                        ? accentColor.withOpacity(0.5)
                        : accentColor.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    print('🌍 SELECTED LANGUAGE: ${language.code}');
                    
                    setState(() {
                      selectedLanguage = language.code;
                    });
                    
                    // Save preference
                    await _saveLanguagePreference(language.code);
                    
                    // Update the localization service to change UI immediately
                    if (mounted) {
                      await localization.setLanguage(language.code);
                      print('🌍 LOCALIZATION SERVICE UPDATED TO: ${localization.currentLanguage}');
                      
                      // Update location service language
                      try {
                        final locationService = Provider.of<LocationService>(context, listen: false);
                        locationService.setLanguage(language.code);
                        print('🌍 LOCATION SERVICE LANGUAGE SET TO: ${language.code}');
                      } catch (e) {
                        print('❌ ERROR updating location service: $e');
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: iconThemeMode == 'day'
                                ? Colors.grey[200]
                                : overlayColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? accentColor.withOpacity(0.5)
                                  : accentColor.withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: isSelected && iconThemeMode != 'day' ? [
                              BoxShadow(
                                color: accentColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: Center(
                            child: Text(
                              language.flag,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.nativeName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 16,
                                  color: textColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                language.name,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}