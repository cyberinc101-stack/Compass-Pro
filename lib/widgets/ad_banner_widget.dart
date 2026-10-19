
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../services/premium_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({Key? key}) : super(key: key);

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int _failCount = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          // Auto-refreshes call this again for the banner that is already
          // showing - only the first load needs to rebuild.
          _failCount = 0;
          if (!_isLoaded) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          // A failed auto-refresh is reported on the banner that is already
          // on screen. Disposing it here made the banner vanish after a
          // couple of refreshes. Keep it; the SDK retries on its next refresh.
          if (_isLoaded && identical(ad, _bannerAd)) return;

          ad.dispose();
          if (identical(ad, _bannerAd)) _bannerAd = null;
          _failCount++;
          if (!mounted) return;
          setState(() => _isLoaded = false);
          if (_failCount <= 3) {
            _retryTimer?.cancel();
            _retryTimer = Timer(Duration(seconds: 30 * _failCount), () {
              if (mounted) _loadBanner();
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noAds = context.watch<PremiumService>().noAds;

    // Always reserve space for the system nav bar so the bottom nav
    // never sits behind the Android gesture/button bar.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom == 0
        ? MediaQuery.of(context).viewPadding.bottom
        : 0.0;

    if (noAds) {
      // No ad — just pad for the system nav bar
      return SizedBox(height: bottomInset);
    }

    final adHeight = _bannerAd?.size.height.toDouble() ?? 50;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoaded && _bannerAd != null)
          SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: adHeight,
            child: AdWidget(ad: _bannerAd!),
          )
        else
          SizedBox(height: adHeight),
        SizedBox(height: bottomInset),
      ],
    );
  }
}
