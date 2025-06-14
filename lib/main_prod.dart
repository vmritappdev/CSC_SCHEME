import 'package:csc/localization/localizationpro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'config/app_config.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final localizationProvider = LocalizationProvider();
  await localizationProvider.loadSavedLanguage(); 
  
  AppConfig(
    appName: 'CSC',
    baseUrl: 'https://cscjewellers.com/nellore/scheme/',
    environment: Environment.prod,
  );
  runApp(const MyApp());
}
