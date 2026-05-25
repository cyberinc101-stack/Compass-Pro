import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_location.dart';

class SavedLocationsService extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<SavedLocation> _locations = [];
  
  static const String _storageKey = 'saved_locations';

  SavedLocationsService(this._prefs) {
    _loadLocations();
  }

  List<SavedLocation> get locations => List.unmodifiable(_locations);

  void _loadLocations() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        _locations = jsonList
            .map((json) => SavedLocation.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading saved locations: $e');
        _locations = [];
      }
    }
  }

  Future<void> _saveLocations() async {
    try {
      final jsonList = _locations.map((location) => location.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving locations: $e');
    }
  }

  Future<void> addLocation(SavedLocation location) async {
    _locations.add(location);
    await _saveLocations();
    notifyListeners();
  }

  Future<void> updateLocation(SavedLocation location) async {
    final index = _locations.indexWhere((l) => l.id == location.id);
    if (index != -1) {
      _locations[index] = location;
      await _saveLocations();
      notifyListeners();
    }
  }

  Future<void> deleteLocation(String id) async {
    _locations.removeWhere((l) => l.id == id);
    await _saveLocations();
    notifyListeners();
  }

  SavedLocation? getLocationById(String id) {
    try {
      return _locations.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SavedLocation> getLocationsByCategory(String category) {
    return _locations.where((l) => l.category == category).toList();
  }

  Future<void> clearAllLocations() async {
    _locations.clear();
    await _prefs.remove(_storageKey);
    notifyListeners();
  }
}