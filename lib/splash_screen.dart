import 'dart:async';



import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/registationfolder/langvages%20page.dart';
import 'package:csc/utillity/constantcolor.dart';




import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>   {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }




  

  /// Navigate to the appropriate screen based on isFirstTime flag
  void _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // Delay for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (isFirstTime) {
      // Navigate to Language Selection Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen2()),
      );
    } else {
      // Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen1()),
      );
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.blue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/images/csc2.png',
                  color: Colors.white,
                  height: 100,
                ),
              ),
              // Text Below the Logo

              
              Text(
                "JEWELLERS",
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              Text('Since 1971',style: GoogleFonts.nunito( color: Colors.white,),)
            ],
          ),
        ),
      ),
    );
  }
}
