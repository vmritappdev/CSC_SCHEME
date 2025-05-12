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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('language_code');  // Get saved language code
    
    if (savedLanguageCode != null) {
      await LocalizationService.load(savedLanguageCode);  // Load the language
      _languageCode = savedLanguageCode;
      notifyListeners();  // Notify UI to rebuild
    }
  }
}
