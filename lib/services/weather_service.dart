import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  // Open-Meteo API - completely FREE, no API key needed!
  static const String baseUrl = 'https://api.open-meteo.com/v1';
  static const String geocodingUrl = 'https://geocoding-api.open-meteo.com/v1';

  /// Get weather using GPS location (for compass screen)
  Future<Map<String, dynamic>?> getCurrentWeather() async {
    try {
      print('🌤️ WEATHER: Starting getCurrentWeather()');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ WEATHER: Location services are disabled.');
        return null;
      }
      print('✅ WEATHER: Location services enabled');

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔍 WEATHER: Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ WEATHER: Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ WEATHER: Location permissions are permanently denied.');
        return null;
      }
      print('✅ WEATHER: Permissions granted');

      // Get current GPS position with longer timeout
      print('📍 WEATHER: Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10), // Increased from 5 to 10
      );
      print('✅ WEATHER: Got position: ${position.latitude}, ${position.longitude}');

      // Fetch weather from Open-Meteo API
      final data = await getWeather(position.latitude, position.longitude);
      print('🌤️ WEATHER: Data fetched: ${data != null ? "SUCCESS" : "FAILED"}');
      return data;
    } catch (e) {
      print('❌ WEATHER ERROR: $e');
      return null;
    }
  }

  /// Get weather by coordinates (for saved locations and weather screen)
  Future<Map<String, dynamic>?> getWeather(double latitude, double longitude) async {
    try {
      print('🌐 WEATHER API: Fetching for lat=$latitude, lon=$longitude');
      
      final url = Uri.parse(
        '$baseUrl/forecast?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
        'precipitation,weather_code,cloud_cover,pressure_msl,surface_pressure,'
        'wind_speed_10m,wind_direction_10m,wind_gusts_10m'
        '&hourly=temperature_2m,precipitation_probability,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
        'sunrise,sunset,precipitation_sum,precipitation_probability_max,'
        'wind_speed_10m_max,uv_index_max'
        '&timezone=auto&forecast_days=7',
      );

      print('🌐 WEATHER API: URL: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 15), // Increased from 10 to 15
        onTimeout: () {
          print('⏰ WEATHER API: Request timed out after 15 seconds');
          throw TimeoutException('Weather API request timed out');
        },
      );

      print('🌐 WEATHER API: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ WEATHER API: Data parsed successfully');
        print('🌡️ WEATHER API: Current temp: ${data['current']?['temperature_2m']}°C');
        return data;
      } else {
        print('❌ WEATHER API: Failed with status ${response.statusCode}');
        print('❌ WEATHER API: Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ WEATHER API ERROR: $e');
      return null;
    }
  }

  /// Search for location by name
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    if (query.isEmpty) return [];
    
    try {
      print('🔍 LOCATION SEARCH: Searching for "$query"');
      
      final url = Uri.parse(
        '$geocodingUrl/search?name=$query&count=5&language=en&format=json',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final results = List<Map<String, dynamic>>.from(data['results']);
          print('✅ LOCATION SEARCH: Found ${results.length} results');
          return results;
        }
      }
      print('⚠️ LOCATION SEARCH: No results found');
      return [];
    } catch (e) {
      print('❌ LOCATION SEARCH ERROR: $e');
      return [];
    }
  }

  /// Get weather by location name
  Future<Map<String, dynamic>?> getWeatherByLocationName(String locationName) async {
    final locations = await searchLocation(locationName);
    if (locations.isNotEmpty) {
      final location = locations.first;
      return getWeather(location['latitude'], location['longitude']);
    }
    return null;
  }

  /// Get weather for a specific location (alias for consistency)
  Future<Map<String, dynamic>?> getWeatherForLocation(
    double latitude,
    double longitude,
  ) async {
    return await getWeather(latitude, longitude);
  }

  /// Refresh current weather
  Future<Map<String, dynamic>?> refreshWeather() async {
    return await getCurrentWeather();
  }

  /// Convert Open-Meteo weather code to readable condition
  String getWeatherCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  /// Get weather emoji based on code
  String getWeatherEmoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '🌡️';
  }

  /// Convert wind direction from degrees to cardinal direction
  String getWindDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Convert Open-Meteo weather code to icon (for weather_info_widget)
  String getWeatherConditionText(int code) {
    if (code == 0) return 'clear';
    if (code <= 3) return 'partly cloudy';
    if (code <= 48) return 'fog';
    if (code <= 67) return 'rain';
    if (code <= 77) return 'snow';
    if (code <= 82) return 'showers';
    if (code <= 86) return 'snow showers';
    if (code <= 99) return 'thunderstorm';
    return 'clear';
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}