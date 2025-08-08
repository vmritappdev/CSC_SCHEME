import 'package:csc/app.dart';
import 'package:csc/localization/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'package:csc/localization/localizationpro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final localizationProvider = LocalizationProvider();
  await localizationProvider.loadSavedLanguage();

  AppConfig(
    appName: 'CSC Dev',
    baseUrl: 'https://vmrdemos.com/csc_scheme',
    environment: Environment.dev,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => localizationProvider),
      ],
      child: const MyApp(),
    ),
  );
}
