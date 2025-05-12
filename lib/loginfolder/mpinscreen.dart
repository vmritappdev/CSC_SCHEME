import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home:CreateMpinScreen5(),
    ),
  );
}

class CreateMpinScreen5 extends StatefulWidget {
  const CreateMpinScreen5({super.key});

  @override
  State<CreateMpinScreen5> createState() => _CreateMpinScreen5State();
}

class _CreateMpinScreen5State extends State<CreateMpinScreen5> {
  final defaultPinTheme = PinTheme(
    width: 65,
    height: 50,
    textStyle: const TextStyle(
      fontSize: 18,
     // fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  String mpin = '';
  String confirmMpin = '';
  String errorMessage = '';



  

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              Center(
                child: Image.asset(
                  'assets/images/mi.png',
                  height: screenHeight * 0.3,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            Padding(
  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1), // Dynamic Padding
  child: Align(
    alignment: Alignment.bottomLeft,
    child: Text(
      localization.translate('Create MPIN*'),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.020, // Dynamic Font Size
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

              SizedBox(height: screenHeight * 0.02),
              buildPinput((value) {
                setState(() {
                  mpin = value;
                  errorMessage = '';
                });
              }),
              SizedBox(height: screenHeight * 0.07),
             Padding(
  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1), // Dynamic Padding
  child: Align(
    alignment: Alignment.bottomLeft,
    child: Text(
      localization.translate('Confirm MPIN*'),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.020, // Dynamic Font Size
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

              SizedBox(height: screenHeight * 0.02),
              buildPinput((value) {
                setState(() {
                  confirmMpin = value;
                  errorMessage = '';
                });
              }),
              if (errorMessage.isNotEmpty)
               Padding(
  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015), // Dynamic Padding
  child: Text(
    errorMessage, // Display error message
    style: TextStyle(
      fontSize: MediaQuery.of(context).size.height * 0.02, // Dynamic Font Size
      color: Colors.red,
    ),
  ),
),

              SizedBox(height: screenHeight * 0.09),
              SizedBox(
                width: screenWidth * 0.8,
                child: 
                   ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(2, 5, 62, 1), 
                     // shadowColor: Colors.transparent, 
                     padding: EdgeInsets.symmetric(
  vertical: MediaQuery.of(context).size.height * 0.015, // Dynamic Vertical Padding
),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () => _submitForm(localization),
                     
                    child: Text(
  localization.translate('SUBMIT'),
  style: TextStyle(
    fontSize: MediaQuery.of(context).size.width * 0.04, // Dynamic Font Size
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
),

                  ),
                
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPinput(ValueChanged<String> onChanged) {
    return Padding(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
      child: Pinput(
        length: 4,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: const Color.fromRGBO(43, 49, 101, 1), width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _submitForm(LocalizationProvider localization) async {
    if (mpin.isEmpty || confirmMpin.isEmpty) {
      setState(() {
        errorMessage = localization.translate('Please enter both MPIN and Confirm MPIN.');
      });
      return;
    }

    if (mpin != confirmMpin) {
      setState(() {
        errorMessage = localization.translate('MPINs do not match!');
      });
      return;
    }

    final success = await _submitMpinToServer();
    if (success) {
     // _showCustomBottomSheet();
    }
     _showpopup(context);
  }

  Future<bool> _submitMpinToServer() async {

    const String apiUrl = "$baseUrl/save_mpin.php";  //"https://vmrdemos.com/csc_scheme/save_mpin.php"


    bool hasInternet = await checkInternet();
    if (!hasInternet) {
     // _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
          Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ErrorScreen()), // ✅
  );
      return false ;
    }

    try {
     SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobileNumber = prefs.getString('phoneNumber');


      

      if (mobileNumber == null || mobileNumber.isEmpty) {
        setState(() {
           errorMessage = 'Mobile number not found. Please try again.';
        });
        return false;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'mpin': mpin,
          'conform_mpin': confirmMpin,
          'mobile_no': mobileNumber,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return true;
        } else {
          setState(() {
           // errorMessage = jsonResponse['message'] ?? 'Something went wrong!';
          });
          return false;
        }
      } else {
        setState(() {
          errorMessage = 'Failed to connect to the server. Status: ${response.statusCode}';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
      return false;
    }
  }

 void _showCustomBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
       Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => HomeScreen(
      activescheme: Activescheme(),
    ),
  ),
  (Route<dynamic> route) => false, // Remove all previous routes
);

      });

      return LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth * 0.05; // Dynamic font size
          fontSize = fontSize.clamp(12, 24); // Set min/max limits
          final localization = Provider.of<LocalizationProvider>(context);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(43, 49, 101, 1),
                //  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                     localization.translate('Create MPIN Successfully'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize, // Dynamic font size
                      ),
                    ),
                    SizedBox(
                      height: constraints.maxWidth * 0.08, // Dynamic height
                      width: constraints.maxWidth * 0.08, // Dynamic width
                      child: Lottie.asset(
                        'assets/images/suc.json',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _showpopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LayoutBuilder(
        
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth * 0.03; // Dynamic font size
          fontSize = fontSize.clamp(12, 24); // Set min/max limits
  final localization = Provider.of<LocalizationProvider>(context);
          return AlertDialog(
            shape: RoundedRectangleBorder(
             // borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                SizedBox(
                  height: constraints.maxWidth * 0.08, // Dynamic height
                  width: constraints.maxWidth * 0.08,  // Dynamic width
                  child: Lottie.asset(
                    'assets/images/suc.json',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    localization.translate('Create MPIN Successfully'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: fontSize, // Dynamic font size
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(2, 5, 62, 1),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            activescheme: Activescheme(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      localization.translate("OK"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize * 0.8, // Adjusted button font size
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
    },
  );
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
              decoration: BoxDecoration(
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

}
