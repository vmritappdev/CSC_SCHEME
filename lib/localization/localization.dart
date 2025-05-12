import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static Map<String, String> _localizedStrings = {};
  static String currentLanguageCode = 'en'; // Default language

  /// Load the JSON file for the specified language
  static Future<void> load(String languageCode) async {
    try {
      currentLanguageCode = languageCode;
      final String jsonString =
          await rootBundle.loadString('assets/lang/$languageCode.json');
      print("Loaded JSON: $jsonString");  // Debug print
      _localizedStrings = Map<String, String>.from(json.decode(jsonString));
    } catch (e) {
      print('Error loading localization file: $e');
    }
  }

  /// Translate a given key
  static String translate(String key) {
    return _localizedStrings[key] ?? key; // If the key isn't found, return the key
  }
}
