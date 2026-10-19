import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/premium_service.dart';
import 'services/compass_service.dart';
import 'services/location_service.dart';
import 'services/settings_service.dart';
import 'services/saved_locations_service.dart';
import 'services/tracking_service.dart';
import 'services/localization_service.dart';
import 'services/ad_service.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();

  // TEMPORARY: Remove after language selector has been seen once
  await prefs.remove('has_seen_language_selector');

  final locationService = LocationService();
  await locationService.initialize();

  // Initialise both services before runApp
  final premiumService = PremiumService();
  await premiumService.initialize();

  final adService = AdService();
  await adService.initialize();

  // Sync initial state
  adService.setPremium(premiumService.noAds);

  // Keep AdService in sync whenever premium status changes —
  // no ProxyProvider needed, just a plain listener
  premiumService.addListener(() {
    adService.setPremium(premiumService.noAds);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PremiumService>.value(value: premiumService),
        ChangeNotifierProvider<AdService>.value(value: adService),
        ChangeNotifierProvider(create: (_) => CompassService()),
        ChangeNotifierProvider.value(value: locationService),
        ChangeNotifierProvider(create: (_) => SettingsService(prefs)),
        ChangeNotifierProvider(create: (_) => SavedLocationsService(prefs)),
        ChangeNotifierProvider(create: (_) => TrackingService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: const CompassProApp(),
    ),
  );
}

class CompassProApp extends StatefulWidget {
  const CompassProApp({Key? key}) : super(key: key);

  @override
  State<CompassProApp> createState() => _CompassProAppState();
}

class _CompassProAppState extends State<CompassProApp> {
  AppOpenAdLifecycleReactor? _appOpenReactor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only wire this up once — didChangeDependencies can fire more than once.
    if (_appOpenReactor == null) {
      final adService = Provider.of<AdService>(context, listen: false);
      _appOpenReactor = AppOpenAdLifecycleReactor(adService)
        ..listenToAppStateChanges();
    }
  }

  @override
  void dispose() {
    _appOpenReactor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Compass Safe Pro',
          debugShowCheckedModeBanner: false,
          theme: settings.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
