import 'package:csc/chaingedscreens.dart/paymentverify.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/localization/provider.dart';
import 'package:csc/splash_screen.dart';
import 'package:csc/upidetails/payment%20verify.dart';
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690), // 👈 Set this based on your Figma/Design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter App',
          theme: ThemeData(
            primaryColor: Color.fromRGBO(2, 5, 62, 1),
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.latoTextTheme(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(2, 5, 62, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
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
