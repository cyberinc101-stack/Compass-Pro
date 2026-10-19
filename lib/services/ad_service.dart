import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends ChangeNotifier {
  static const String _bannerIdReal       = 'ca-app-pub-9286981131873574/6140338870';
  static const String _interstitialIdReal = 'ca-app-pub-9286981131873574/6238895857';
  static const String _bannerIdTest       = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialIdTest = 'ca-app-pub-3940256099942544/1033173712';

  // Reusing the interstitial ad unit for App Open ads — AdMob reporting
  // will lump both formats' stats together under this one unit ID.
  static const String _appOpenIdReal = _interstitialIdReal;
  static const String _appOpenIdTest = _interstitialIdTest;

  static String get bannerId       => kDebugMode ? _bannerIdTest       : _bannerIdReal;
  static String get interstitialId => kDebugMode ? _interstitialIdTest : _interstitialIdReal;
  static String get appOpenId      => kDebugMode ? _appOpenIdTest      : _appOpenIdReal;

  static const int _interstitialEvery = 5;
  int _navCount = 0;

  BannerAd?       _bannerAd;
  InterstitialAd? _interstitialAd;
  AppOpenAd?      _appOpenAd;

  bool _isBannerLoaded       = false;
  bool _isInterstitialLoaded = false;
  bool _isAppOpenLoading     = false;
  bool _isShowingAppOpenAd   = false;
  bool _noAds                = false;

  DateTime? _appOpenLoadTime;

  bool      get isBannerLoaded       => _isBannerLoaded       && !_noAds;
  bool      get isInterstitialLoaded => _isInterstitialLoaded && !_noAds;
  BannerAd? get bannerAd             => _bannerAd;

  bool get isAppOpenAdAvailable {
    if (_appOpenAd == null || _noAds) return false;
    // AdMob policy: app open ads expire ~4 hours after load.
    if (_appOpenLoadTime == null) return false;
    return DateTime.now().difference(_appOpenLoadTime!).inHours < 4;
  }

  Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await MobileAds.instance.initialize();
    loadBanner();
    loadInterstitial();
    loadAppOpenAd();
  }

  /// Called by ProxyProvider whenever PremiumService.noAds changes.
  void setPremium(bool value) {
    if (_noAds == value) return;
    _noAds = value;
    if (value) {
      // Subscription active — kill all ads immediately
      _disposeBanner();
      _disposeInterstitial();
      _disposeAppOpenAd();
    } else {
      // Subscription expired — reload ads
      loadBanner();
      loadInterstitial();
      loadAppOpenAd();
    }
    notifyListeners();
  }

  /// Call this on every meaningful screen change / user "move".
  /// Fires an interstitial every [_interstitialEvery] calls.
  void onNavigation() {
    if (_noAds) return;
    _navCount++;
    if (_navCount >= _interstitialEvery) {
      _navCount = 0;
      showInterstitial();
    }
  }

  void loadBanner() {
    if (_noAds || !Platform.isAndroid) return;
    _bannerAd = BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
          _isBannerLoaded = false;
          notifyListeners();
        },
      ),
    )..load();
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  void loadInterstitial() {
    if (_noAds || !Platform.isAndroid) return;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd       = ad;
          _isInterstitialLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: $error');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if available.
  /// [onDismissed] fires once the ad is closed (or immediately if there
  /// was no ad to show), so callers can safely chain navigation after it.
  void showInterstitial({VoidCallback? onDismissed}) {
    if (!_isInterstitialLoaded || _noAds || _interstitialAd == null) {
      onDismissed?.call();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;
    _isInterstitialLoaded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitial();
        onDismissed?.call();
      },
    );
    ad.show();
  }

  void _disposeInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
  }

  // ── App Open Ad ────────────────────────────────────────────────────────

  void loadAppOpenAd() {
    if (_noAds || !Platform.isAndroid || _isAppOpenLoading) return;
    _isAppOpenLoading = true;
    AppOpenAd.load(
      adUnitId: appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd        = ad;
          _appOpenLoadTime  = DateTime.now();
          _isAppOpenLoading = false;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed: $error');
          _isAppOpenLoading = false;
        },
      ),
    );
  }

  /// Shows the preloaded App Open ad if one is ready.
  /// [onDismissed] always fires exactly once — immediately if there's no ad
  /// to show, or after the ad closes — so callers can safely chain
  /// navigation/continuation after it, same contract as showInterstitial.
  void showAppOpenAdIfAvailable({VoidCallback? onDismissed}) {
    if (!isAppOpenAdAvailable || _isShowingAppOpenAd || _appOpenAd == null) {
      onDismissed?.call();
      return;
    }

    final ad = _appOpenAd!;
    _appOpenAd = null;
    _isShowingAppOpenAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAppOpenAd = false;
        loadAppOpenAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App open ad failed to show: $error');
        ad.dispose();
        _isShowingAppOpenAd = false;
        loadAppOpenAd();
        onDismissed?.call();
      },
    );
    ad.show();
  }

  void _disposeAppOpenAd() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _appOpenLoadTime = null;
  }

  @override
  void dispose() {
    _disposeBanner();
    _disposeInterstitial();
    _disposeAppOpenAd();
    super.dispose();
  }
}

/// Watches app lifecycle and shows a preloaded App Open ad whenever the app
/// comes back to the foreground from the background (NOT on first cold
/// start — that's handled once, manually, from LoadingScreen so the two
/// don't double-fire).
class AppOpenAdLifecycleReactor with WidgetsBindingObserver {
  final AdService adService;
  AppOpenAdLifecycleReactor(this.adService);

  void listenToAppStateChanges() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      adService.showAppOpenAdIfAvailable();
    }
  }
}