import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_service.dart';
import '../services/localization_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../widgets/brand_loader.dart';
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
  }

  Future<void> _selectLanguage(LanguageOption language) async {
    setState(() => selectedLanguage = language.code);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language.code);
    if (!mounted) return;

    final localization =
        Provider.of<LocalizationService>(context, listen: false);
    await localization.setLanguage(language.code);
    if (!mounted) return;

    try {
      Provider.of<LocationService>(context, listen: false)
          .setLanguage(language.code);
    } catch (e) {
      debugPrint('Error updating location service language: $e');
    }
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_isContinuing) return;
    _isContinuing = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_language_selector', true);
    await prefs.setString('language', selectedLanguage);
    if (!mounted) return;

    final localization =
        Provider.of<LocalizationService>(context, listen: false);
    final adService = Provider.of<AdService>(context, listen: false);
    await localization.setLanguage(selectedLanguage);
    try {
      Provider.of<LocationService>(context, listen: false)
          .setLanguage(selectedLanguage);
    } catch (e) {
      debugPrint('Error updating location service language: $e');
    }
    if (!mounted) return;

    if (widget.isFirstLaunch) {
      // Calls onDismissed immediately when no ad is loaded.
      adService.showInterstitial(onDismissed: _goToHome);
    } else {
      _goToHome();
    }
  }

  Widget _buildTile(LanguageOption language, int index, BrandPalette p) {
    final isSelected = selectedLanguage == language.code;
    const darkBlue = Color(0xFF1E3A5F);

    final titleColor = isSelected && p.light ? darkBlue : p.text;
    final subColor = isSelected && p.light
        ? const Color(0xFF5A6B80)
        : p.text.withOpacity(0.7);
    final fill = isSelected
        ? (p.light ? Colors.white : p.accent.withOpacity(0.18))
        : (p.light
            ? Colors.white.withOpacity(0.14)
            : Colors.white.withOpacity(0.05));
    final border = isSelected
        ? (p.light ? Colors.white : p.accent)
        : Colors.white.withOpacity(0.18);
    final checkColor = p.light ? const Color(0xFF2F6FD0) : p.accent;
    final delay = (index < 8 ? index : 8) * 40;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: fill,
          elevation: isSelected ? 6 : 0,
          shadowColor: Colors.black.withOpacity(0.35),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: border, width: isSelected ? 2 : 1),
          ),
          child: InkWell(
            onTap: () => _selectLanguage(language),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(p.light ? 0.92 : 0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.nativeName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          language.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSelected
                        ? Icon(Icons.check_circle,
                            key: const ValueKey('on'),
                            color: checkColor,
                            size: 28)
                        : const SizedBox(key: ValueKey('off'), width: 28),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final localization = context.watch<LocalizationService>();
    final p = BrandPalette.forMode(settings.iconThemeMode);

    return Scaffold(
      backgroundColor: p.top,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.top, p.bottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!widget.isFirstLaunch)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: p.text),
                    onPressed: () => Navigator.pop(context, selectedLanguage),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, widget.isFirstLaunch ? 24 : 0, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.accent.withOpacity(0.18),
                        border: Border.all(color: p.accent.withOpacity(0.5)),
                      ),
                      child: Icon(Icons.language, color: p.text, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        localization.translate('language'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: p.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: languages.length,
                  itemBuilder: (context, index) =>
                      _buildTile(languages[index], index, p),
                ),
              ),
              if (widget.isFirstLaunch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor:
                            p.light ? const Color(0xFF2F6FD0) : Colors.black,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localization.translate('continue'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
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