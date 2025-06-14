import 'package:csc/dashboardscreens/terms_condition.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Other imports remain the same

class LanguageSelectionScreen2 extends StatefulWidget {
  const LanguageSelectionScreen2({super.key});

  @override
  _LanguageSelectionScreen2State createState() =>
      _LanguageSelectionScreen2State();
}

class _LanguageSelectionScreen2State extends State<LanguageSelectionScreen2> {
  final List<Map<String, dynamic>> languages = [

     {
      "native": "English",
      "english": "English",
      "code": "en",
      "color": [Color(0xFF2C3E50), Color(0xFF3498DB)]
    },



    {
      "native": "Telugu",
      "english": "తెలుగు",
      "code": "te",
      "color": [Color(0xFF1A4E8B), Color(0xFF2C7D91)]
    },

     {
      "native": "Hindi",
      "english": "हिन्दी",
      "code": "hi",
      "color": [Color(0xFFE67E22), Color(0xFFD35400)]
    },
    {
      "native": "Tamil",
      "english": "தமிழ்",
      "code": "ta",
      "color": [Color(0xFF27AE60), Color(0xFF229954)]
    },
   
  ];

  String selectedLanguageCode = "en";

  // Keep existing logic for _navigateBasedOnCondition and onLanguageSelected

  



@override
  void initState() {
    super.initState();
  //  _navigateBasedOnCondition();
  }


   /// Save the selected language and navigate to the next screen.
 Future<void> onLanguageSelected(BuildContext context, String languageCode) async {
  if (languageCode == 'hi' || languageCode == 'ta') {
    // Alert if Hindi or Tamil selected
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Icon(Icons.error, color: Colors.red, size: screenWidth * 0.1),
              SizedBox(height: screenHeight * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                 "Hindi and Tamil languages are currently not available.",
                  style: GoogleFonts.lato(fontSize: screenWidth * 0.04),
                   textAlign: TextAlign.center,
                  ),

              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(2, 5, 62, 1),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return; // stop further execution
  }


  // Continue for available languages
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstTime', false);
  await prefs.setString('selectedLanguage', languageCode);

  setState(() {
    selectedLanguageCode = languageCode;
  });

  Provider.of<LocalizationProvider>(context, listen: false)
      .changeLanguage(languageCode);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const TermsAndConditionsScreen(),
    ),
  );
}




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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: size.height * 0.20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(2, 5, 67, 1), Color.fromRGBO(2, 5, 67, 1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Icon(Icons.translate, size: 40, color: Colors.white),
                    Image.asset('assets/images/csc2.png',height: 40,color: Colors.white,),
                   // SizedBox(height: 16),
                    Text(
                      "Choose Your Language",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        //letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = selectedLanguageCode == lang["code"];
                    
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: lang["color"],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: isSelected
                            ? Border.all(
                                color: Colors.white,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => onLanguageSelected(context, lang["code"]),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        lang["native"],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        lang["english"],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                    //  color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                   
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
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(2, 5, 67, 1), Color.fromRGBO(2, 5, 67, 1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Selected: ${languages.firstWhere((lang) => lang["code"] == selectedLanguageCode)["native"]}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  
}