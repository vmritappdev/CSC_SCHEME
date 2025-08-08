

import 'package:csc/appinstillzer/appinstillzer.dart';
import 'package:csc/localization/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:csc/localization/localizationpro.dart';

//To generate Builds
// flutter build apk --flavor prod --release
// flutter build apk --flavor dev --release

//To run app
// flutter run --flavor dev -t lib/main_dev.dart
// flutter run --flavor prod -t lib/main_prod.dart


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
      ],
      child: const AppInitializer(),
    ),
  );
}
