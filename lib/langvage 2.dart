
import 'package:csc/dashboardscreens/terms_condition.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: child!,
      );
    },
    home: const Lang10(),
  ));
}

class Lang10 extends StatefulWidget {
  const Lang10({super.key});

  @override
  _Lang10State createState() => _Lang10State();
}

class _Lang10State extends State<Lang10> {
  final List<Map<String, dynamic>> languages = [
    {"native": "Telugu", "english": "\u0C24\u0C46\u0C32\u0C41\u0C17\u0C41", "code": "te", "color": Colors.teal},
    {"native": "English", "english": "\u0C07\u0C02\u0C17\u0C4D\u0C32\u0C40\u0C37\u0C4D", "code": "en", "color": Colors.blue},
   // {"native": "Hindi", "english": "\u0939\u093F\u0928\u094D\u0926\u0940", "code": "hi", "color": Colors.orange},
    //{"native": "Tamil", "english": "\u0BA4\u0BAE\u0BBF\u0BB4\u0BCD", "code": "ta", "color": Colors.green},
  ];

  String selectedLanguageCode = "en";

  Future<void> _savePhoneNumber(String phoneNumber) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('phoneNumber', phoneNumber);
}

Future<String?> _getPhoneNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('phoneNumber');
}

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedLanguageCode = prefs.getString('selectedLanguage') ?? "en";
    if (mounted) setState(() {});
  }

  void onLanguageSelected(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    await prefs.setString('selectedLanguage', languageCode);
    
    selectedLanguageCode = languageCode;
    if (mounted) setState(() {});

    Future.microtask(() {
      if (mounted) {
        Provider.of<LocalizationProvider>(context, listen: false)
            .changeLanguage(languageCode);
      }
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.04;
    final double fontSize = size.width * 0.05;
    
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Change Your Language",
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          backgroundColor: const Color.fromRGBO(2, 5, 67, 1),
        ),
        body: Column(
          children: [
            SizedBox(height: size.height * 0.08),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                  childAspectRatio: 1,
                ),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = selectedLanguageCode == lang["code"];

                  return GestureDetector(
                    onTap: () => onLanguageSelected(lang["code"]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: lang["color"],
                        borderRadius: BorderRadius.circular(padding * 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: padding * 0.5,
                            offset: Offset(0, padding * 0.2),
                          ),
                        ],
                        border: isSelected
                            ? Border.all(
                                color: const Color.fromRGBO(2, 5, 62, 1),
                                width: padding * 0.3,
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
                                fontSize: fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              lang["english"],
                              style: GoogleFonts.lato(
                                fontSize: fontSize * 0.8,
                                color: Colors.white70,
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: EdgeInsets.only(top: size.height * 0.015),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: fontSize * 1.4,
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
              height: size.height * 0.08,
              width: double.infinity,
              child: Center(
                child: Text(
                  "Selected Language: ${languages.firstWhere((lang) => lang["code"] == selectedLanguageCode)["native"]}",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
