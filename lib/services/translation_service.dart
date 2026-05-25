import 'package:flutter/material.dart';

class TranslationService {
  final Locale locale;

  TranslationService(this.locale);

  static TranslationService of(BuildContext context) {
    return TranslationService(Localizations.localeOf(context));
  }

  // Add your translation methods here
  String translate(String key) {
    // Implement your translation logic
    return key;
  }

  // Add any other methods your heading_card.dart expects
}