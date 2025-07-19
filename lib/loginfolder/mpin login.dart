import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/loginfolder/forgot%20screen.dart';
import 'package:csc/model/activescheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const LoginPage(),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _pin = '';
  bool _isSuccess = false;
  bool _isError = false;
  bool _showFingerprint = false;
  String errorMessage = '';
  bool _isBiometricAvailable = false;
  final bool _isPinVisible = false;

  String firstName = '';
String lastName = '';


  final List<String> _enteredMpin = [];
final String correctMpin = "1234"; // Example correct MPIN


 Future<void> _fetchUserDetails() async {
  String apiUrl = "$baseUrl/get_reg_account_details.php";

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ensures latest data is fetched

    String? mobileNumber = prefs.getString('userPhoneNumber');

    if (mobileNumber == null || mobileNumber.length != 10) {
      print("❌ Mobile Number not found in SharedPreferences");
      return;
    }

    print("📤 Sending Mobile Number to API: $mobileNumber");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'mobile_no': mobileNumber},
    );

    print("📥 API Response Status: ${response.statusCode}");
    print("📥 API Response Body: ${response.body}");

    final jsonResponse = json.decode(response.body);

    if (jsonResponse['status'] == 200) {
      var userDetails = jsonResponse['account_details'][0];

      String fetchedFirstName = userDetails['f_name']?.trim() ?? "";
      String fetchedLastName = userDetails['l_name']?.trim() ?? "";
      String fetchedPhone = userDetails['mobile_no']?.trim() ?? "";
      String fetchedEmail = userDetails['email_id']?.trim() ?? "";

      // Save to SharedPreferences
      await prefs.setString('firstName', fetchedFirstName);
      await prefs.setString('lastName', fetchedLastName);
      await prefs.setString('phoneNumber', fetchedPhone);
      await prefs.setString('email', fetchedEmail);

      print("✅ Saved: $fetchedFirstName $fetchedLastName");

      // ✅ Update UI state variables
      setState(() {
        firstName = fetchedFirstName;
        lastName = fetchedLastName;
      });

    } else {
      print("❌ Failed to fetch user details: ${jsonResponse['message']}");
    }
  } catch (e) {
    print("❌ Error fetching user details: $e");
  }
}


  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    WidgetsBinding.instance.addPostFrameCallback((_) {
     _authenticateUser();
     _fetchUserDetails();
  });
    
  }

  void _validateMpin() {
  String enteredPin = _enteredMpin.join();

  if (enteredPin == correctMpin) {
    // Correct MPIN
    print("MPIN correct");
    // Proceed to next step
  } else {
    // Wrong MPIN
    print("Wrong MPIN");

    // Clear MPIN
    setState(() {
      _enteredMpin.clear();
    });

    // Optionally, error popup kuda chupinchavachu
   // _showErrorDialog();
  }
}


  void _onKeyTap(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
        if (_pin.length == 4) {
          _validatePin();
        }
      });
    }
  }

void _validatePin() async {
      final localization = Provider.of<LocalizationProvider>(context,listen: false);

  setState(() {
    _isSuccess = false;
    _isError = false;
    _showFingerprint = false;
  });

  bool isSuccess = await _submitMpinToServer(_pin);

  if (isSuccess) {
    setState(() {
      _isSuccess = true;
      _isError = false;
      _showFingerprint = _isBiometricAvailable;
      errorMessage = ''; // <<< Correct MPIN ayite error message empty cheyyadam
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme())),
      );
    });

  } else {
    setState(() {
      _isError = true;
      errorMessage = localization.translate('Invalid MPIN. Please try again.');
      _pin = ''; // wrong ayite pin clear cheyyadam
    });
  }
}


 void _onDelete() {
  if (_enteredMpin.isNotEmpty) {
    setState(() {
   //   _enteredMpin.removeLast();
       _pin = _pin.substring(0, _pin.length - 1);
    });
  }
}


  Future<void> _checkBiometricAvailability() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    setState(() {
      _isBiometricAvailable = canCheckBiometrics;
    });
  }


  void _startAuthentication() async {
  bool isAuthenticated = await authenticate();
  if (isAuthenticated) {
    // Authentication success logic
  } else {
    // Authentication failed logic
  }
}

Future<bool> authenticate() async {
  final LocalAuthentication auth = LocalAuthentication();
  try {
    bool authenticated = await auth.authenticate(
      localizedReason: 'Please authenticate to proceed',
      options: const AuthenticationOptions(
        biometricOnly: true,
      ),
    );
    return authenticated;
  } catch (e) {
    print(e);
    return false;
  }
}




Future<void> _authenticateUser() async {
    try {
      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Authentication success
        _goToHomeScreen();
      } else {
        // Authentication failed
        // You can show error or stay on same screen
      }
    } catch (e) {
      print("Authentication error: $e");
    }
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme())),
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

  // Submit form and send data to API
 

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
  








  Future<bool> _submitMpinToServer(String mpin) async {

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
    //  _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
    const ErrorScreen();
      return false;
    }
    String phpUrl = "$baseUrl/mpin_verify.php";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobileNumber = prefs.getString('phoneNumber');
      if (mobileNumber!.isEmpty) {
        setState(() {
          errorMessage = 'Mobile number not found. Please try again.';
        });
        return false;
      }

      final response = await http.post(
        Uri.parse(phpUrl),
        body: {'mpin': mpin, 'mobile_no': mobileNumber},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] == 200 && jsonResponse['login'] == 'SUCCESS';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  

  Future<void> _authenticateWithFingerprint() async {

    bool hasInternet = await checkInternet();
  if (!hasInternet) {
  //  _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
  const ErrorScreen();
    return;
  }
    try {
      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to login',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      if (isAuthenticated) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme())),
        );
      }
    } catch (e) {
      print("Fingerprint Authentication Error: $e");
    }
  }

@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
    final localization = Provider.of<LocalizationProvider>(context,listen: false);
  double fontSize = screenWidth * 0.045;
  double iconSize = screenWidth * 0.12;
  double buttonSize = screenWidth * 0.18;

  return WillPopScope(
    onWillPop: () async {
 bool shouldExit = await showDialog(
  
  barrierDismissible: false,
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
localization.translate('CSC App'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
           localization.translate('Are you sure do you want to exit?'),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                 localization.translate('CANCEL'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                localization.translate('EXIT'),
                  style: const TextStyle(
                  fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

 if (shouldExit) {
 SystemNavigator.pop();

    
  }

  return false;
},

    child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light elegant background
      body: SingleChildScrollView(
        child:Column(
    children: [
      SizedBox(height: screenHeight * 0.09),
    
    
    
      Text(
    '${localization.translate("Hi")}, $firstName $lastName!',
    style: GoogleFonts.poppins(
      fontSize: screenWidth * 0.04,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF02053E),
    ),
    ),
    
      
      SizedBox(height: screenHeight * 0.01),
      Text(
      localization.translate('Enter your 4-digit MPIN'),
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: screenHeight * 0.02),
    
      // MPIN box row
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            width: screenWidth * 0.14,
            height: screenWidth * 0.14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _pin.length > index ? '●' : '',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.08,
                color: const Color(0xFF02053E),
              ),
            ),
          );
        }),
      ),
    
      SizedBox(height: screenHeight * 0.01),
    
      // Forgot MPIN button
      TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ForgotScreen()),
          );
        },
        child: Text(
         localization.translate('Forgot MPIN?'),
          style: GoogleFonts.poppins(
            color: const Color(0xFF0077B6),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    
    
      Text(
                        errorMessage,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 12
                        ),
                        textAlign: TextAlign.center,
                      ),
    
      //SizedBox(height: screenHeight * 0.02),
    
      // --- ICON + ERROR Message Space Reserve ---
      Column(
        children: [
          // Success/Error Icon
          SizedBox(
            height: iconSize, // Always reserve space for icon
            child: Center(
              child: _isSuccess
                  ? Icon(Icons.check_circle, color: Colors.green, size: iconSize)
                 
                      : const SizedBox.shrink(),
            ),
          ),
    
          //SizedBox(height: screenHeight * 0.01),
    
          // Error message text
        
        ],
      ),
      // --- END of ICON + ERROR space ---
    
    //  SizedBox(height: screenHeight * 0.03),
    
      // Fingerprint
      GestureDetector(
        onTap: _authenticateWithFingerprint,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Icon(
            Icons.fingerprint,
            size: screenWidth * 0.14,
            color: const Color(0xFF02053E),
          ),
        ),
      ),
    
      SizedBox(height: screenHeight * 0.01),
    
      // Keypad
      Column(
        children: [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['0', '⌫']].map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((number) {
              return GestureDetector(
                onTap: () => number == '⌫' ? _onDelete() : _onKeyTap(number),
    
                 onLongPress: () {
      if (number == '⌫') {
        setState(() {
          _pin = ''; // full MPIN clear
        });
      }
    },
                
                child: Container(
                  margin: EdgeInsets.all(screenWidth * 0.025),
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF02053E),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    
      SizedBox(height: screenHeight * 0.05),
    ],
    )
    
      ),
    ),
  );
}










}
