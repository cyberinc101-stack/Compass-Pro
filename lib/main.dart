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
import 'services/localization_service.dart'; // ← ADD THIS IMPORT
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();

  // TEMPORARY FIX: Clear language selector flag to test it
  // REMOVE THESE 3 LINES after you've seen the language selector work once!
  await prefs.remove('has_seen_language_selector');
  print('🔧 MAIN: Cleared has_seen_language_selector flag for testing');
  print('🔍 MAIN: After clear - has_seen_language_selector = ${prefs.getBool('has_seen_language_selector')}');

  // Initialize LocationService once
  final locationService = LocationService();
  await locationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PremiumService()),
        ChangeNotifierProvider(create: (_) => CompassService()),
        ChangeNotifierProvider.value(value: locationService),
        ChangeNotifierProvider(create: (_) => SettingsService(prefs)),
        ChangeNotifierProvider(create: (_) => SavedLocationsService(prefs)),
        ChangeNotifierProvider(create: (_) => TrackingService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()), // ← ADD THIS LINE
      ],
      child: const CompassProApp(),
    ),
  );
}

class CompassProApp extends StatelessWidget {
  const CompassProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Compass Safe Pro',
          debugShowCheckedModeBanner: false,
          theme: settings.isDarkMode
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}