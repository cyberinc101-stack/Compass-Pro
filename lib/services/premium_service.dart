import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  bool _isPremium = false;
  String _subscriptionType = 'free';
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  
  // Premium features flags
  static const String _keyIsPremium = 'is_premium';
  static const String _keySubscriptionType = 'subscription_type';
  static const String _keyPurchaseDate = 'purchase_date';
  static const String _keyExpiryDate = 'expiry_date';

  bool get isPremium => _isPremium;
  String get subscriptionType => _subscriptionType;
  DateTime? get purchaseDate => _purchaseDate;
  DateTime? get expiryDate => _expiryDate;
  
  // Days remaining for subscription
  int? get daysRemaining {
    if (_expiryDate == null) return null;
    final diff = _expiryDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }
  
  bool get isLifetime => _subscriptionType == 'lifetime';
  bool get isMonthly => _subscriptionType == 'monthly';
  bool get isYearly => _subscriptionType == 'yearly';

  // Initialize and load saved premium status
  Future<void> initialize() async {
    await _loadPremiumStatus();
    await _checkSubscriptionExpiry();
  }

  // Feature access control
  bool canAccessFeature(PremiumFeature feature) {
    if (!_isPremium) return false;
    
    switch (feature) {
      case PremiumFeature.arView:
      case PremiumFeature.savedLocations:
      case PremiumFeature.weather:
      case PremiumFeature.tracking:
      case PremiumFeature.advancedCalibration:
      case PremiumFeature.customThemes:
      case PremiumFeature.exportData:
      case PremiumFeature.noAds:
        return true;
      default:
        return false;
    }
  }

  // Purchase monthly subscription
  Future<bool> purchaseMonthly() async {
    try {
      // TODO: Integrate with in_app_purchase package
      await Future.delayed(const Duration(seconds: 1));
      
      _isPremium = true;
      _subscriptionType = 'monthly';
      _purchaseDate = DateTime.now();
      _expiryDate = DateTime.now().add(const Duration(days: 30));
      
      await _savePremiumStatus();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  // Purchase yearly subscription
  Future<bool> purchaseYearly() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _isPremium = true;
      _subscriptionType = 'yearly';
      _purchaseDate = DateTime.now();
      _expiryDate = DateTime.now().add(const Duration(days: 365));
      
      await _savePremiumStatus();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  // Purchase lifetime access
  Future<bool> purchaseLifetime() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _isPremium = true;
      _subscriptionType = 'lifetime';
      _purchaseDate = DateTime.now();
      _expiryDate = null; // No expiry for lifetime
      
      await _savePremiumStatus();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  // Restore purchases from app store
  Future<bool> restorePurchases() async {
    try {
      // TODO: Integrate with in_app_purchase to query past purchases
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulated restore
      await _loadPremiumStatus();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  // Cancel subscription (for testing)
  Future<void> cancelSubscription() async {
    _isPremium = false;
    _subscriptionType = 'free';
    _expiryDate = null;
    
    await _savePremiumStatus();
    notifyListeners();
  }

  // Save premium status to persistent storage
  Future<void> _savePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, _isPremium);
    await prefs.setString(_keySubscriptionType, _subscriptionType);
    
    if (_purchaseDate != null) {
      await prefs.setString(_keyPurchaseDate, _purchaseDate!.toIso8601String());
    }
    
    if (_expiryDate != null) {
      await prefs.setString(_keyExpiryDate, _expiryDate!.toIso8601String());
    } else {
      await prefs.remove(_keyExpiryDate);
    }
  }

  // Load premium status from storage
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_keyIsPremium) ?? false;
    _subscriptionType = prefs.getString(_keySubscriptionType) ?? 'free';
    
    final purchaseDateStr = prefs.getString(_keyPurchaseDate);
    if (purchaseDateStr != null) {
      _purchaseDate = DateTime.parse(purchaseDateStr);
    }
    
    final expiryDateStr = prefs.getString(_keyExpiryDate);
    if (expiryDateStr != null) {
      _expiryDate = DateTime.parse(expiryDateStr);
    }
  }

  // Check if subscription has expired
  Future<void> _checkSubscriptionExpiry() async {
    if (_subscriptionType == 'lifetime') return;
    
    if (_expiryDate != null && DateTime.now().isAfter(_expiryDate!)) {
      _isPremium = false;
      _subscriptionType = 'free';
      await _savePremiumStatus();
      notifyListeners();
    }
  }

  // Get subscription price (placeholder)
  String getSubscriptionPrice(String type) {
    switch (type) {
      case 'monthly':
        return '\$4.99/month';
      case 'yearly':
        return '\$39.99/year';
      case 'lifetime':
        return '\$79.99 once';
      default:
        return 'Free';
    }
  }
}

// Premium features enum
enum PremiumFeature {
  arView,
  savedLocations,
  weather,
  tracking,
  advancedCalibration,
  customThemes,
  exportData,
  noAds,
}