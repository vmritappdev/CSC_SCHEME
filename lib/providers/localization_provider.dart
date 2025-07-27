import 'package:flutter/foundation.dart';

class LocalizationProvider with ChangeNotifier {
  Future<void> loadSavedLanguage() async {
    // Simulate a delay to "load" saved language
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
