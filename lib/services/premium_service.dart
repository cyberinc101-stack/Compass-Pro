import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  // ── RevenueCat keys ──────────────────────────────────────────────────────
  static const String _rcAndroidKey = 'goog_BaJofFRQbBndKhtqWKQaNVXWYFV';

  // ── Entitlement & product identifiers ────────────────────────────────────
  static const String _entitlementId   = 'pro';
  static const String _monthlyProductId = 'compass_monthly';
  static const String _yearlyProductId  = 'compass_yearly';

  // ── Local cache keys ─────────────────────────────────────────────────────
  static const String _keyIsPremium        = 'is_premium';
  static const String _keySubscriptionType = 'subscription_type';
  static const String _keyExpiryDate       = 'expiry_date';

  bool      _isPremium        = false;
  String    _subscriptionType = 'free';
  DateTime? _expiryDate;

  bool      get isPremium        => _isPremium;
  String    get subscriptionType => _subscriptionType;
  DateTime? get expiryDate       => _expiryDate;

  bool get noAds           => _isPremium && (_expiryDate == null || DateTime.now().isBefore(_expiryDate!));
  bool get allStatsVisible => noAds;
  bool get isMonthly       => _subscriptionType == 'monthly';
  bool get isYearly        => _subscriptionType == 'yearly';

  int? get daysRemaining {
    if (_expiryDate == null) return null;
    final diff = _expiryDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  // ── Initialise ────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    await _loadLocalCache();

    if (!Platform.isAndroid) return;

    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_rcAndroidKey));

    Purchases.addCustomerInfoUpdateListener(_handleCustomerInfo);

    try {
      final info = await Purchases.getCustomerInfo();
      await _handleCustomerInfo(info);
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo failed: $e');
    }
  }

  // ── Purchase helpers ──────────────────────────────────────────────────────
  Future<bool> purchaseMonthly() => _purchase(_monthlyProductId, 'monthly');
  Future<bool> purchaseYearly()  => _purchase(_yearlyProductId,  'yearly');

  Future<bool> _purchase(String productId, String type) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      Package? package;
      if (current != null) {
        package = current.availablePackages.firstWhere(
          (p) => p.storeProduct.identifier == productId,
          orElse: () => current.availablePackages.first,
        );
      }

      // purchases_flutter 9.x: purchasePackage/purchaseStoreProduct now
      // return a PurchaseResult wrapper, not CustomerInfo directly.
      CustomerInfo info;
      if (package != null) {
        final result = await Purchases.purchasePackage(package);
        info = result.customerInfo;
      } else {
        final products = await Purchases.getProducts([productId]);
        if (products.isEmpty) throw Exception('Product not found: $productId');
        final result = await Purchases.purchaseStoreProduct(products.first);
        info = result.customerInfo;
      }

      await _handleCustomerInfo(info);
      return noAds;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled by user');
      } else {
        debugPrint('Purchase error: $e');
      }
      return false;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      await _handleCustomerInfo(info);
      return noAds;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  // ── Handle entitlement update from RevenueCat ─────────────────────────────
  Future<void> _handleCustomerInfo(CustomerInfo info) async {
    final entitlement = info.entitlements.all[_entitlementId];
    final isActive = entitlement?.isActive ?? false;

    if (isActive) {
      _isPremium = true;

      final productId = entitlement?.productIdentifier ?? '';
      if (productId.contains('monthly')) {
        _subscriptionType = 'monthly';
      } else if (productId.contains('yearly')) {
        _subscriptionType = 'yearly';
      }

      final expiryStr = entitlement?.expirationDate;
      if (expiryStr != null) {
        try {
          _expiryDate = DateTime.parse(expiryStr);
        } catch (_) {}
      }
    } else {
      _isPremium        = false;
      _subscriptionType = 'free';
      _expiryDate       = null;
    }

    await _saveLocalCache();
    notifyListeners();
  }

  // ── Local cache ───────────────────────────────────────────────────────────
  Future<void> _saveLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, _isPremium);
    await prefs.setString(_keySubscriptionType, _subscriptionType);
    if (_expiryDate != null) {
      await prefs.setString(_keyExpiryDate, _expiryDate!.toIso8601String());
    } else {
      await prefs.remove(_keyExpiryDate);
    }
  }

  Future<void> _loadLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium        = prefs.getBool(_keyIsPremium)          ?? false;
    _subscriptionType = prefs.getString(_keySubscriptionType) ?? 'free';
    final expiryStr   = prefs.getString(_keyExpiryDate);
    if (expiryStr != null) {
      _expiryDate = DateTime.tryParse(expiryStr);
    }
    if (_expiryDate != null && DateTime.now().isAfter(_expiryDate!)) {
      _isPremium        = false;
      _subscriptionType = 'free';
      _expiryDate       = null;
      await _saveLocalCache();
    }
  }

  // ── Pricing helpers ───────────────────────────────────────────────────────
  String getSubscriptionPrice(String type) {
    switch (type) {
      case 'monthly': return '\$2.99/month';
      case 'yearly':  return '\$8.99/year';
      default:        return 'Free';
    }
  }

  String getSavingsLabel() => 'Save 75%';

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_handleCustomerInfo);
    super.dispose();
  }
}

enum PremiumFeature { noAds, allStats }