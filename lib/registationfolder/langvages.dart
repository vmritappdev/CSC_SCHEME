import 'package:csc/dashboardscreens/terms_condition.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen1 extends StatefulWidget {
  const LanguageSelectionScreen1({super.key});

  @override
  _LanguageSelectionScreen1State createState() =>
      _LanguageSelectionScreen1State();
}

class _LanguageSelectionScreen1State extends State<LanguageSelectionScreen1> {
  final List<Map<String, dynamic>> languages = [
    {"native": "Telugu", "english": "తెలుగు", "code": "te", "color": Colors.teal},
    {"native": "English", "english": "English", "code": "en", "color": Colors.blue},
  //  {"native": "Hindi", "english": "हिन्दी", "code": "hi", "color": Colors.orange},
   // {"native": "Tamil", "english": "தமிழ்", "code": "ta", "color": Colors.green},
  ];

  String selectedLanguageCode = "en";

  @override
  void initState() {
    super.initState();
    _navigateBasedOnCondition();
  }

  /// Logic to navigate based on `isFirstTime` flag.
  Future<void> _navigateBasedOnCondition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (!isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen1()),
      );
    }
  }

  /// Save the selected language and navigate to the next screen.
  Future<void> onLanguageSelected(BuildContext context, String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // Mark as not first-time user
    await prefs.setString('selectedLanguage', languageCode);

    setState(() {
      selectedLanguageCode = languageCode;
    });

    // Update localization provider
    Provider.of<LocalizationProvider>(context, listen: false)
        .changeLanguage(languageCode);

    // Navigate to Terms and Conditions Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsAndConditionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Change Your Language",
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.08),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: screenWidth * 0.04,
                mainAxisSpacing: screenHeight * 0.03,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = selectedLanguageCode == lang["code"];

                return GestureDetector(
                  onTap: () => onLanguageSelected(context, lang["code"]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: lang["color"],
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: screenWidth * 0.02,
                          offset: Offset(0, screenHeight * 0.005),
                        ),
                      ],
                      border: isSelected
                          ? Border.all(
                              color: const Color.fromRGBO(2, 5, 62, 1),
                              width: screenWidth * 0.01,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang["native"],
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.05,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lang["english"],
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white70,
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.015),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: const Color.fromRGBO(2, 5, 62, 1),
            height: screenHeight * 0.08,
            width: double.infinity,
            child: Center(
              child: Text(
                "Selected Language: ${languages.firstWhere((lang) => lang["code"] == selectedLanguageCode)["native"]}",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}