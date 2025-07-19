

import 'package:csc/loginfolder/loginscreen.dart';

import 'package:csc/localization/localizationpro.dart';
import 'package:csc/registationfolder/langvages%20page.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MaterialApp(
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: child!,
      );
    },
    home: const TermsAndConditionsScreen(),
  ));
}

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool isLoading = false;

  

  Future<void> handleAccept() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => isLoading = false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const LoginScreen1()));
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final titleStyle = GoogleFonts.lato(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.white);
    final textStyle = GoogleFonts.lato(fontSize: screenWidth * 0.04, color: Colors.white70);

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {

      return false; // Prevent default back action
    },
        child: Scaffold(
          backgroundColor: const Color(0xFF02053E),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopSection(localization, titleStyle, textStyle, screenHeight, screenWidth),
                _buildTermsSection(localization, screenHeight, screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(LocalizationProvider localization, TextStyle titleStyle, TextStyle textStyle, double screenHeight, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF02053E), Color(0xFF02053E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color: Colors.white,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSelectionScreen2())),
              ),
              Text(localization.translate("Hello 👋"), style: titleStyle),
              const Icon(Icons.help_outline, color: Colors.white),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            localization.translate("Before you create an account, please read\nand accept our Terms & Conditions."),
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(LocalizationProvider localization, double screenHeight, double screenWidth) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF02053E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );

    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.translate("Terms & Conditions"),
                      style: GoogleFonts.lato(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      localization.translate("The customer can also purchase jewelry from the 10th month of enrollment with full benefits."),
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    for (int i = 1; i <= 26; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$i. ',
                                style: GoogleFonts.lato(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              TextSpan(
                                text: localization.translate("$i"),
                                style: GoogleFonts.lato(fontSize: screenWidth * 0.035, color: Colors.black87, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildButtons(localization, buttonStyle, screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(LocalizationProvider localization, ButtonStyle buttonStyle, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Text(localization.translate("Decline"), style: GoogleFonts.lato()),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
         Expanded(
  child: ElevatedButton(
    onPressed: isLoading ? null : handleAccept,
    style: buttonStyle,
    child: isLoading
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.03, // Dynamic height
            child: SpinKitThreeBounce(
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.05, // Dynamic size
            ),
          )
        : Text(
            localization.translate("Accept"),
            style: GoogleFonts.lato(fontSize: screenWidth * 0.045), // Dynamic font size
          ),
  ),
),

        ],
      ),
    );
  }
}
