import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  String? _errorMessage;
  bool _isLoading = false;
  String _currentLanguage = 'en';

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String get currentLanguage => _currentLanguage;

  void setLanguage(String languageCode) {
    debugPrint('LocationService: setLanguage called with $languageCode (current: $_currentLanguage)');
    _currentLanguage = languageCode;
    debugPrint('LocationService: Language changed to $_currentLanguage');
    if (_currentPosition != null) {
      _updateAddressWithLanguage();
    }
  }

  Future<void> initialize() async {
    await getCurrentLocation();
  }

  /// Shows a prominent disclosure dialog BEFORE requesting location permission.
  /// Returns true if user accepts, false if they decline.
  static Future<bool> showLocationDisclosure(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.location_on_rounded, color: Color(0xFF4A90E2)),
            SizedBox(width: 8),
            Text('Location Access'),
          ],
        ),
        content: const Text(
          'Compass Pro uses your device location to:\n\n'
          '• Show your current position on the compass\n'
          '• Display local weather conditions\n'
          '• Provide accurate navigation data\n'
          '• Enable safety tracking features\n\n'
          'Your location is only accessed while the app is open '
          'and is never stored on our servers or shared with third parties.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No Thanks',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Allow Location',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> getCurrentLocation({BuildContext? context}) async {
    if (_isLoading || _currentPosition != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // Only show disclosure + request if not already granted
      if (permission == LocationPermission.denied) {
        // Show prominent disclosure before system prompt
        if (context != null && context.mounted) {
          final accepted = await showLocationDisclosure(context);
          if (!accepted) {
            _errorMessage = 'Location permission declined.';
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      await _updateAddressWithLanguage();

      _isLoading = false;
      notifyListeners();
    } on TimeoutException {
      _errorMessage = 'Location timeout.';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Location error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateAddressWithLanguage() async {
    if (_currentPosition == null) return;

    try {
      final languageMap = {
        'en': 'en',
        'en_gb': 'en',
        'zh': 'zh',
        'ja': 'ja',
        'de': 'de',
        'hi': 'hi',
        'fr': 'fr',
        'it': 'it',
        'pt_br': 'pt-BR',
        'pt': 'pt',
        'ko': 'ko',
        'ru': 'ru',
        'es': 'es',
        'es_mx': 'es-MX',
        'id': 'id',
        'nl': 'nl',
        'tr': 'tr',
        'ar': 'ar',
        'th': 'th',
        'pl': 'pl',
        'bn': 'bn',
        'pa': 'pa',
        'te': 'te',
        'mr': 'mr',
        'ta': 'ta',
        'jv': 'jv',
        'vi': 'vi',
      };

      final acceptLanguage = languageMap[_currentLanguage] ?? 'en';
      debugPrint('LocationService: Fetching address with language: $acceptLanguage');

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'format=json&'
        'lat=${_currentPosition!.latitude}&'
        'lon=${_currentPosition!.longitude}&'
        'accept-language=$acceptLanguage&'
        'zoom=10'
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'CompassPro/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        final components = <String>[];

        if (address['city'] != null) {
          components.add(address['city']);
        } else if (address['town'] != null) {
          components.add(address['town']);
        } else if (address['village'] != null) {
          components.add(address['village']);
        }

        if (address['state'] != null) {
          components.add(address['state']);
        } else if (address['region'] != null) {
          components.add(address['region']);
        }

        if (address['country'] != null) {
          components.add(address['country']);
        }

        if (components.isNotEmpty) {
          _currentAddress = components.join(', ');
          debugPrint('LocationService: Address updated to $_currentAddress');
        } else {
          _currentAddress = data['display_name']
              ?.toString()
              .split(',')
              .take(3)
              .join(',');
        }
      } else {
        await _updateAddressFallback();
      }

      if (_currentAddress == null || _currentAddress!.isEmpty) {
        _currentAddress =
            '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}';
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Nominatim geocoding error: $e');
      await _updateAddressFallback();
    }
  }

  Future<void> _updateAddressFallback() async {
    if (_currentPosition == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentAddress = [
          place.locality,
          place.administrativeArea,
          place.country,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
      }

      if (_currentAddress == null || _currentAddress!.isEmpty) {
        _currentAddress =
            '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}';
      }

      notifyListeners();
    } catch (_) {
      _currentAddress =
          '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}';
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    _currentPosition = null;
    _currentAddress = null;
    await getCurrentLocation();
  }

  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  double getBearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}