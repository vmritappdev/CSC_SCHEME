

import 'package:csc/localization/localizationpro.dart';
import 'package:csc/localization/provider.dart';

import 'package:csc/splash_screen.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final localizationProvider = LocalizationProvider();
  await localizationProvider.loadSavedLanguage(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),
        ChangeNotifierProvider<LocalizationProvider>(
          create: (_) => LocalizationProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // 👈 Set this based on your Figma/Design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter App',
          theme: ThemeData(
            primaryColor: const Color.fromRGBO(2, 5, 62, 1),
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.latoTextTheme(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(2, 5, 62, 1), width: 2),
              ),
            ),
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
