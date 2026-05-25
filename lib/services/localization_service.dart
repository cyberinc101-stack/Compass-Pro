import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import all language translation files
import 'package:compass_pro/ui_language_selector/en(English).dart';
import 'package:compass_pro/ui_language_selector/ar(Arabic).dart';
import 'package:compass_pro/ui_language_selector/bn(Bengali).dart';
import 'package:compass_pro/ui_language_selector/de(German).dart';
import 'package:compass_pro/ui_language_selector/es(Spanish).dart';
import 'package:compass_pro/ui_language_selector/es_mx(Spanish_Mexico).dart'; // ADDED
import 'package:compass_pro/ui_language_selector/fr(French).dart';
import 'package:compass_pro/ui_language_selector/hi(Hindi).dart';
import 'package:compass_pro/ui_language_selector/id(Indonesian).dart'; // ADDED
import 'package:compass_pro/ui_language_selector/it(Italian).dart';
import 'package:compass_pro/ui_language_selector/ja(Japanese).dart';
import 'package:compass_pro/ui_language_selector/jv(Javanese).dart';
import 'package:compass_pro/ui_language_selector/ko(Korean).dart';
import 'package:compass_pro/ui_language_selector/mr(Marathi).dart';
import 'package:compass_pro/ui_language_selector/nl(Dutch).dart'; // ADDED
import 'package:compass_pro/ui_language_selector/pa(Punjabi).dart';
import 'package:compass_pro/ui_language_selector/pl(Polish).dart'; // ADDED
import 'package:compass_pro/ui_language_selector/pt(Portuguese).dart';
import 'package:compass_pro/ui_language_selector/pt_br(Portuguese_Brazil).dart'; // ADDED
import 'package:compass_pro/ui_language_selector/ru(Russian).dart';
import 'package:compass_pro/ui_language_selector/ta(Tamil).dart';
import 'package:compass_pro/ui_language_selector/te(Telugu).dart';
import 'package:compass_pro/ui_language_selector/th(Thai).dart'; // ADDED
import 'package:compass_pro/ui_language_selector/tr(Turkish).dart';
import 'package:compass_pro/ui_language_selector/vi(Vietnamese).dart';
import 'package:compass_pro/ui_language_selector/zh(Chinese).dart';

class LocalizationService extends ChangeNotifier {
  static String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  // Language code to name mapping - ADDED MISSING LANGUAGES
  static final Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'bn': 'বাংলা',
    'de': 'Deutsch',
    'es': 'Español',
    'es_mx': 'Español (México)', // ADDED
    'fr': 'Français',
    'hi': 'हिन्दी',
    'id': 'Bahasa Indonesia', // ADDED
    'it': 'Italiano',
    'ja': '日本語',
    'jv': 'Basa Jawa',
    'ko': '한국어',
    'mr': 'मराठी',
    'nl': 'Nederlands', // ADDED
    'pa': 'ਪੰਜਾਬੀ',
    'pl': 'Polski', // ADDED
    'pt': 'Português',
    'pt_br': 'Português (Brasil)', // ADDED
    'ru': 'Русский',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'th': 'ไทย', // ADDED
    'tr': 'Türkçe',
    'vi': 'Tiếng Việt',
    'zh': '中文',
  };

  // Static method for quick translations
  static String translate(String key) {
    return _getTranslations()[key] ?? key;
  }

  // Instance method
  String translateKey(String key) {
    return _getTranslations()[key] ?? key;
  }

  // Get translations based on current language - ADDED MISSING LANGUAGES
  static Map<String, String> _getTranslations() {
    switch (_currentLanguage) {
      case 'en':
        return EnglishTranslations.translations;
      case 'ar':
        return ArabicTranslations.translations;
      case 'bn':
        return BengaliTranslations.translations;
      case 'de':
        return GermanTranslations.translations;
      case 'es':
        return SpanishTranslations.translations;
      case 'es_mx': // ADDED
        return SpanishMexicoTranslations.translations;
      case 'fr':
        return FrenchTranslations.translations;
      case 'hi':
        return HindiTranslations.translations;
      case 'id': // ADDED
        return IndonesianTranslations.translations;
      case 'it':
        return ItalianTranslations.translations;
      case 'ja':
        return JapaneseTranslations.translations;
      case 'jv':
        return JavaneseTranslations.translations;
      case 'ko':
        return KoreanTranslations.translations;
      case 'mr':
        return MarathiTranslations.translations;
      case 'nl': // ADDED
        return DutchTranslations.translations;
      case 'pa':
        return PunjabiTranslations.translations;
      case 'pl': // ADDED
        return PolishTranslations.translations;
      case 'pt':
        return PortugueseTranslations.translations;
      case 'pt_br': // ADDED
        return PortugueseBrazilTranslations.translations;
      case 'ru':
        return RussianTranslations.translations;
      case 'ta':
        return TamilTranslations.translations;
      case 'te':
        return TeluguTranslations.translations;
      case 'th': // ADDED
        return ThaiTranslations.translations;
      case 'tr':
        return TurkishTranslations.translations;
      case 'vi':
        return VietnameseTranslations.translations;
      case 'zh':
        return ChineseTranslations.translations;
      default:
        return EnglishTranslations.translations;
    }
  }

  // Load saved language preference
  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'en';
      notifyListeners();
    } catch (e) {
      _currentLanguage = 'en';
    }
  }

  // Change language and save preference
  Future<void> setLanguage(String languageCode) async {
    if (!languageNames.containsKey(languageCode)) {
      return;
    }
    
    _currentLanguage = languageCode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
    
    notifyListeners();
  }

  // Get all available languages
  static List<String> getAvailableLanguages() {
    return languageNames.keys.toList();
  }

  // Get language name by code
  static String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }
}

// Extension to add translate method to instance
extension LocalizationExtension on LocalizationService {
  String translate(String key) => translateKey(key);
}

// Alias for TranslationService
typedef TranslationService = LocalizationService;