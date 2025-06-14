import 'package:csc/app.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_config.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final localizationProvider = LocalizationProvider();
  await localizationProvider.loadSavedLanguage(); 
  
  AppConfig(
    appName: 'CSC Dev',
    baseUrl: 'https://vmrdemos.com/csc_scheme/',
    environment: Environment.dev,
  );
  runApp(const MyApp());
}
