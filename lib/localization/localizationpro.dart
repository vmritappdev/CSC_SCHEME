import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csc/localization/localization.dart';

class LocalizationProvider extends ChangeNotifier {
  String _languageCode = LocalizationService.currentLanguageCode;

  String get languageCode => _languageCode;

  /// Change language and reload the JSON file
  Future<void> changeLanguage(String languageCode) async {
    await LocalizationService.load(languageCode);  // Load language file
    _languageCode = languageCode;
    _saveLanguageToPreferences(languageCode);  // Save to SharedPreferences
    notifyListeners();  // Notify UI to rebuild
  }

  /// Translate a given key
  String translate(String key) {
    return LocalizationService.translate(key);  // Direct translation without args
  }

  /// Save the language code to SharedPreferences
  Future<void> _saveLanguageToPreferences(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);  // Store language code
  }

  /// Load saved language code from SharedPreferences
Future<void> loadSavedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final savedLanguageCode = prefs.getString('language_code');

  // Fallback to a default language if none is saved
  final languageCodeToLoad = savedLanguageCode ?? 'en'; // Replace 'en' with your default

  await LocalizationService.load(languageCodeToLoad);
  _languageCode = languageCodeToLoad;
  notifyListeners(); // Notify UI to rebuild
}

}
