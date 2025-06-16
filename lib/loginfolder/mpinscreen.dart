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
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home:const CreateMpinScreen5(),
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
   String? savedMobileNumber; // ✅ Add this


final TextEditingController _mpinController = TextEditingController();
final TextEditingController _confirmMpinController = TextEditingController();


Future<void> _loadSavedMobileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString('phoneNumber');
    setState(() {
      savedMobileNumber = number;
    });
    print("✅ Saved mobile number in CreateMpinScreen5: $savedMobileNumber");
  }

  @override
  void initState() {
  super.initState();
  _loadSavedMobileNumber(); // ✅ Load mobile number on start
  }




@override
void dispose() {
  _mpinController.dispose();
  _confirmMpinController.dispose();
  super.dispose();
}


  

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
             // MPIN field
buildPinput(
  controller: _mpinController,
  onChanged: (value) {
    print('mpin changed: "$value"');
    setState(() {
      mpin = value;
      errorMessage = '';
    });
  },
),
// Confirm MPIN field

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
buildPinput(
  controller: _confirmMpinController,
  onChanged: (value) {
    print('confirmMpin changed: "$value"');
    setState(() {
      confirmMpin = value;
      errorMessage = '';
    });
  },
),

              if (errorMessage.isNotEmpty)
               Padding(
  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015), // Dynamic Padding
  child: Text(
    errorMessage, // Display error message
    style: TextStyle(
      fontSize: MediaQuery.of(context).size.height * 0.015, // Dynamic Font Size
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
                      backgroundColor: const Color.fromRGBO(2, 5, 62, 1), 
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
Widget buildPinput({
  required ValueChanged<String> onChanged,
  required TextEditingController controller,
}) {
  return Padding(
    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
    child: Pinput(
      length: 4,
      controller: controller,
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
  String currentMpin = _mpinController.text.trim();
  String currentConfirmMpin = _confirmMpinController.text.trim();

  print('controller mpin: "$currentMpin"');
  print('controller confirmMpin: "$currentConfirmMpin"');

  if (currentMpin.isEmpty || currentConfirmMpin.isEmpty) {
    setState(() {
      errorMessage = localization.translate('Please enter both MPIN and Confirm MPIN.');
    });
    return;
  }

 if (currentMpin != currentConfirmMpin) {
  setState(() {
    errorMessage = localization.translate('MPINs do not match!');
    _mpinController.clear();
    _confirmMpinController.clear();
    mpin = '';
    confirmMpin = '';
  });
  _showErrorPopup(localization.translate('MPINs do not match!'));
  return;
}


  mpin = currentMpin; // update class variable if needed
  confirmMpin = currentConfirmMpin;

  final success = await _submitMpinToServer();
  if (success) {
    _showpopup(context);
  } else {
    _showErrorPopup(localization.translate("Failed to create MPIN. Please try again."));
  }
}


 Future<bool> _submitMpinToServer() async {
   final localization = Provider.of<LocalizationProvider>(context,listen: false);
  String apiUrl = "$baseUrl/save_mpin.php";  // Your API URL

  String mpin = _mpinController.text.trim();
  String confirmMpin = _confirmMpinController.text.trim();

  // Simple validation before API call
  if (mpin.length < 4) {
    setState(() {
      errorMessage = localization.translate('MPIN must be at least 4 digits');
    });
    return false;
  }

  if (mpin != confirmMpin) {
    setState(() {
      errorMessage = localization.translate('MPIN and Confirm MPIN do not match');
    });
    return false;
  }

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ErrorScreen()),
    );
    return false;
  }

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');

    if (mobileNumber == null || mobileNumber.isEmpty) {
      setState(() {
        errorMessage = localization.translate('Mobile number not found. Please try again.');
      });
      return false;
    }

    print('mobileNumber from prefs: $mobileNumber');
    print('Sending to API: mpin=$mpin, confirmMpin=$confirmMpin, mobile_no=$mobileNumber');

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mpin': mpin,
        'conform_mpin': confirmMpin,
        'mobile_no': mobileNumber,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('Decoded JSON response: $jsonResponse');

      if (jsonResponse['response'] == 'success') {
        return true;
      } else {
        setState(() {
          errorMessage = jsonResponse['message'] ?? 'Something went wrong!';
        });
        return false;
      }
    } else {
      setState(() {
      //  errorMessage = 'Failed to connect to the server. Status: ${response.statusCode}';
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


  void _showpopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LayoutBuilder(
        
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth * 0.03; // Dynamic font size
          fontSize = fontSize.clamp(12, 24); // Set min/max limits
  final localization = Provider.of<LocalizationProvider>(context,listen: false);
          return AlertDialog(
            shape: const RoundedRectangleBorder(
             // borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: constraints.maxWidth * 0.09, // Dynamic height
                  width: constraints.maxWidth * 0.09,  // Dynamic width
                  child: Lottie.asset(
                    'assets/images/suc2.json',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(2, 5, 62, 1),
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


void _showErrorPopup( String message) {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
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
              decoration: BoxDecoration(
                color: const Color.fromRGBO(2, 5, 62, 1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
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


}
