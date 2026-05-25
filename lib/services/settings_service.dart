import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';  // ADD THIS IMPORT
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Boolean settings
  bool get isDarkMode => _prefs.getBool('darkMode') ?? false;
  bool get autoDarkMode => _prefs.getBool('autoDarkMode') ?? false;
  bool get hapticFeedback => _prefs.getBool('hapticFeedback') ?? true;
  bool get nightMode => _prefs.getBool('nightMode') ?? false;
  bool get continuousTracking => _prefs.getBool('continuousTracking') ?? false;
  bool get showCoordinates => _prefs.getBool('showCoordinates') ?? true;
  bool get showWeatherInfo => _prefs.getBool('showWeatherInfo') ?? true;
  bool get showLevelBubble => _prefs.getBool('showLevelBubble') ?? true;
  bool get showHeadingCard => _prefs.getBool('showHeadingCard') ?? true;
  bool get showInfoCards => _prefs.getBool('showInfoCards') ?? true;
  bool get torchEnabled => _prefs.getBool('torchEnabled') ?? false;
  bool get showLocationText => _prefs.getBool('showLocationText') ?? true;
  
  // Individual swipeable info card toggles
  bool get showSpeed => _prefs.getBool('showSpeed') ?? true;
  bool get showAccuracy => _prefs.getBool('showAccuracy') ?? true;
  bool get showAltitude => _prefs.getBool('showAltitude') ?? true;
  bool get showBearing => _prefs.getBool('showBearing') ?? true;
  bool get showDistance => _prefs.getBool('showDistance') ?? true;
  bool get showMaxSpeed => _prefs.getBool('showMaxSpeed') ?? true;
  bool get showAvgSpeed => _prefs.getBool('showAvgSpeed') ?? true;
  bool get showLocation => _prefs.getBool('showLocation') ?? true;
  bool get showElevation => _prefs.getBool('showElevation') ?? true;
  bool get showMovingTime => _prefs.getBool('showMovingTime') ?? true;
  
  // Numeric settings
  double get magneticDeclination => _prefs.getDouble('declination') ?? 0.0;
  
  // String settings
  String get distanceUnit => _prefs.getString('distanceUnit') ?? 'Meters';
  String get speedUnit => _prefs.getString('speedUnit') ?? 'km/h';
  String get temperatureUnit => _prefs.getString('temperatureUnit') ?? 'Celsius';
  String get gpsAccuracy => _prefs.getString('gpsAccuracy') ?? 'High';
  String get language => _prefs.getString('language') ?? 'en';
  
  // NEW: Icon Theme Mode - 'day', 'glow', or 'night'
  String get iconThemeMode => _prefs.getString('iconThemeMode') ?? 'day';

  // Setters for boolean settings
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setAutoDarkMode(bool value) async {
    await _prefs.setBool('autoDarkMode', value);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    await _prefs.setBool('hapticFeedback', value);
    notifyListeners();
  }

  Future<void> setNightMode(bool value) async {
    await _prefs.setBool('nightMode', value);
    notifyListeners();
  }

  Future<void> setContinuousTracking(bool value) async {
    await _prefs.setBool('continuousTracking', value);
    notifyListeners();
  }

  Future<void> setShowCoordinates(bool value) async {
    await _prefs.setBool('showCoordinates', value);
    notifyListeners();
  }

  Future<void> setShowWeatherInfo(bool value) async {
    await _prefs.setBool('showWeatherInfo', value);
    notifyListeners();
  }

  Future<void> setShowLevelBubble(bool value) async {
    await _prefs.setBool('showLevelBubble', value);
    notifyListeners();
  }

  Future<void> setShowHeadingCard(bool value) async {
    await _prefs.setBool('showHeadingCard', value);
    notifyListeners();
  }

  Future<void> setShowInfoCards(bool value) async {
    await _prefs.setBool('showInfoCards', value);
    notifyListeners();
  }

  Future<void> setTorchEnabled(bool value) async {
    await _prefs.setBool('torchEnabled', value);
    notifyListeners();
  }

  Future<void> setShowLocationText(bool value) async {
    await _prefs.setBool('showLocationText', value);
    notifyListeners();
  }

  // Setters for individual swipeable info items
  Future<void> setShowSpeed(bool value) async {
    await _prefs.setBool('showSpeed', value);
    notifyListeners();
  }

  Future<void> setShowAccuracy(bool value) async {
    await _prefs.setBool('showAccuracy', value);
    notifyListeners();
  }

  Future<void> setShowAltitude(bool value) async {
    await _prefs.setBool('showAltitude', value);
    notifyListeners();
  }

  Future<void> setShowBearing(bool value) async {
    await _prefs.setBool('showBearing', value);
    notifyListeners();
  }

  Future<void> setShowDistance(bool value) async {
    await _prefs.setBool('showDistance', value);
    notifyListeners();
  }

  Future<void> setShowMaxSpeed(bool value) async {
    await _prefs.setBool('showMaxSpeed', value);
    notifyListeners();
  }

  Future<void> setShowAvgSpeed(bool value) async {
    await _prefs.setBool('showAvgSpeed', value);
    notifyListeners();
  }

  Future<void> setShowLocation(bool value) async {
    await _prefs.setBool('showLocation', value);
    notifyListeners();
  }

  Future<void> setShowElevation(bool value) async {
    await _prefs.setBool('showElevation', value);
    notifyListeners();
  }

  Future<void> setShowMovingTime(bool value) async {
    await _prefs.setBool('showMovingTime', value);
    notifyListeners();
  }

  // Setters for numeric settings
  Future<void> setMagneticDeclination(double value) async {
    await _prefs.setDouble('declination', value);
    notifyListeners();
  }

  // Setters for string settings
  Future<void> setDistanceUnit(String value) async {
    await _prefs.setString('distanceUnit', value);
    notifyListeners();
  }

  Future<void> setSpeedUnit(String value) async {
    await _prefs.setString('speedUnit', value);
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String value) async {
    await _prefs.setString('temperatureUnit', value);
    notifyListeners();
  }

  Future<void> setGpsAccuracy(String value) async {
    await _prefs.setString('gpsAccuracy', value);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString('language', languageCode);
    notifyListeners();
  }

  // NEW: Icon Theme Mode setter
  Future<void> setIconThemeMode(String mode) async {
    await _prefs.setString('iconThemeMode', mode);
    notifyListeners();
  }

  // NEW: Cycle through theme modes (day -> glow -> night -> day)
  Future<void> cycleIconThemeMode() async {
    String nextMode;
    switch (iconThemeMode) {
      case 'day':
        nextMode = 'glow';
        break;
      case 'glow':
        nextMode = 'night';
        break;
      case 'night':
        nextMode = 'day';
        break;
      default:
        nextMode = 'day';
    }
    await setIconThemeMode(nextMode);
  }

  // NEW: Get icon color based on theme mode
  Color getIconColor({double opacity = 1.0}) {
    switch (iconThemeMode) {
      case 'day':
        return Colors.white.withOpacity(opacity);
      case 'glow':
        return Color(0xFF00FF88).withOpacity(opacity); // Bright cyan-green glow
      case 'night':
        return Color(0xFFFF3333).withOpacity(opacity); // Red for night vision
      default:
        return Colors.white.withOpacity(opacity);
    }
  }

  // NEW: Get text color based on theme mode
  Color getTextColor({double opacity = 1.0}) {
    switch (iconThemeMode) {
      case 'day':
        return Colors.white.withOpacity(opacity);
      case 'glow':
        return Color(0xFF00FFAA).withOpacity(opacity); // Slightly different green for text
      case 'night':
        return Color(0xFFFF4444).withOpacity(opacity); // Slightly brighter red for text
      default:
        return Colors.white.withOpacity(opacity);
    }
  }

  // Helper method for auto-detecting declination
  void autoDetectDeclination() {
    setMagneticDeclination(0.0);
  }
}