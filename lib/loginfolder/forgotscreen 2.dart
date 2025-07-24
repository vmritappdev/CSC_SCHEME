import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/loginfolder/creatempin1.dart';
import 'package:csc/utillity/sample.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const ForgotScreen1(),
    ),
  );
}

class ForgotScreen1 extends StatefulWidget {
  const ForgotScreen1({super.key});

  @override
  State<ForgotScreen1> createState() => _ForgotScreen1State();
}

class _ForgotScreen1State extends State<ForgotScreen1> {
  final TextEditingController _controllerMobileNumber = TextEditingController();
  bool isLoading = false;

  // ✅ Function to verify mobile number


  Future<void> saveMobileNumber(String mobileNumber) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('phoneNumber', mobileNumber);
  debugPrint("✅ Mobile Number Saved: $mobileNumber");
}

Future<String?> loadMobileNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('phoneNumber');
}




  void _showInvalidOTPDialog(String message) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.02), // Dynamic Border Radius
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: screenHeight * 0.02), // Dynamic Spacing
            Icon(Icons.error, color: Colors.red, size: screenWidth * 0.1), // Dynamic Icon Size
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Dynamic Padding
              child: Text(
                message,
                style: GoogleFonts.lato(fontSize: screenWidth * 0.04), // Dynamic Font Size
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
                    fontSize: screenWidth * 0.045, // Dynamic Button Font Size
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
}


Future<bool> checkInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  
  // **Extra Check: Mobile lo net unda leda ani verify chestam**
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }

  return false;
}

  Future<void> verifyMobileNumber() async {
    String mobileNumber = _controllerMobileNumber.text.trim();
   final localization = Provider.of<LocalizationProvider>(context, listen: false);  

    // ✅ Validation
    if (mobileNumber.isEmpty || mobileNumber.length != 10) {
    //  _showErrorPopup(localization.translate("Enter a valid 10-digit mobile number"));
     ErrorScreen();
      return;
    }

     bool hasInternet = await checkInternet();
    if (!hasInternet) {
      _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile_verification.php'),
        
        body: {'mobile_no': mobileNumber},
      );

      var responseData = jsonDecode(response.body);
      print("✅ API Response: $responseData");

      if (responseData['login'] == 'SUCCESS') {
         // ✅ First save the mobile number
  await saveMobileNumber(mobileNumber);
        // ✅ Navigate to CreateTempPinScreen1 on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateMpin1Screen()),
        );
      } else {
        _showErrorPopup(localization.translate("No records on this number"));
      }
    } catch (e) {
      print("❌ API Exception: $e");
      _showErrorPopup("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
   verifyMobileNumber();
  });
}


  // ❌ Show error message
  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double fontSize = MediaQuery.of(context).size.width * 0.03;
        fontSize = fontSize.clamp(12, 24);
        final localization = Provider.of<LocalizationProvider>(context);
        return AlertDialog(
          shape: const RoundedRectangleBorder(),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  localization.translate(message),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 15, color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
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
                    localization.translate("OK"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
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
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
       onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen1()),
      );
      return false; // Prevent default back action
    },
      child: Scaffold(
        
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: BackButton(
                    onPressed: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen1(),
                        )
                      );
                    },
                    color: const Color.fromRGBO(2, 5, 62, 1),
                  ),
                ),
                Image.asset('assets/images/csc2.png', height: 90),
                Text(
                 localization.translate('CSCJEWELLERYS'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(43, 49, 101, 1),
                  ),
                ),
                SizedBox(height: screenHeight * 0.09),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: TextFormField(
                    maxLength: 10,
                    controller: _controllerMobileNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 10),
                      counterText: '',
                      hintText: localization.translate("Mobile Number*"),
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: const Icon(Icons.phone, size: 20),
                      border: OutlineInputBorder(
                      //  borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : verifyMobileNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                           localization.translate("Verify Mobile Number"),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}