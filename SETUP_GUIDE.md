# Compass Pro Setup Guide

## Quick Start

### 1. Install Flutter Dependencies
```bash
cd compass_pro
flutter pub get
```

### 2. Configure Google Maps

#### Android
1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Edit `android/app/src/main/AndroidManifest.xml`
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key

#### iOS
1. Edit `ios/Runner/AppDelegate.swift`
2. Add your Google Maps API key

### 3. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Release Build
flutter build apk --release
flutter build ios --release
```

## Firebase Setup (Optional but Recommended)

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Download `google-services.json` for Android
3. Download `GoogleService-Info.plist` for iOS
4. Place files in respective directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## In-App Purchase Setup

### Android (Google Play)
1. Create products in Play Console
2. Update product IDs in `lib/services/premium_service.dart`

### iOS (App Store)
1. Create products in App Store Connect
2. Update product IDs in `lib/services/premium_service.dart`

## Revenue Model

### Pricing
- **Monthly**: $4.99/month
- **Lifetime**: $29.99 one-time

### Features Breakdown
- **Free**: Basic compass, limited locations
- **Premium**: AR view, unlimited locations, advanced tools

## Troubleshooting

### Location Not Working
- Ensure location permissions are granted
- Check GPS is enabled on device

### Maps Not Showing
- Verify Google Maps API key is correct
- Check billing is enabled in Google Cloud Console

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Support
For issues, contact: support@compasspro.app

