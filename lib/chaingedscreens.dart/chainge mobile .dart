import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/otpscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home:MobileScreen(),
    ),
  );
}

class MobileScreen extends StatefulWidget {
  @override
  _MobileScreenState createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false; // Loader state

 

Future<void> sendMobileChangeRequest() async {
  if (!context.mounted) return;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String mobileNumber = prefs.getString('phoneNumber') ?? "";

  if (mobileNumber.isEmpty) return;

  String newMobileNumber = _controller.text.trim();

  if (newMobileNumber.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(newMobileNumber)) {
    return;
  }

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
    return;
  }

  setState(() => isLoading = true);

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/change_mobile_no.php'), //'https://vmrdemos.com/csc_scheme/change_mobile_no.php'
      body: {
        'mobile_no': mobileNumber,
        'new_mobile_no': newMobileNumber,
      },
    );

    if (!context.mounted) return;

    final responseData = jsonDecode(response.body);
    print("API Response: $responseData");

    if (response.statusCode == 200 && responseData['response'] == 'success') {
      await prefs.setString('phoneNumber', newMobileNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message'] ?? "Update Successful"),
          duration: Duration(seconds: 1),
        ),
      );

      await Future.delayed(Duration(seconds: 2));

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OtpScreen()),
        );
      }
    }
  } catch (e) {
    print("API Error: $e");
  } finally {
    if (context.mounted) {
      setState(() => isLoading = false);
    }
  }
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




Future<void> verifyMobileNumber() async {
  String newMobileNumber = _controller.text.trim();

  if (newMobileNumber.isEmpty || newMobileNumber.length != 10) {
    _showInvalidOTPDialog("Please enter a valid 10-digit mobile number.");
    return;
  }

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
  //  _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
       Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ErrorScreen()), // ✅
  );
    return;
  }

  setState(() => isLoading = true);

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/mobile_verification.php'),//'https://vmrdemos.com/csc_scheme/mobile_verification.php'
      body: {'mobile_no': newMobileNumber},
    );

    final responseData = jsonDecode(response.body);
    print("✅ Mobile Verify API Response: $responseData");

    if (responseData['login'] == 'SUCCESS') {
      // Number already exists in database
      _showInvalidOTPDialog("❌ This mobile number is already registered.");
    } else {
      // Number doesn't exist, proceed to update
      print("🔹 Mobile number not found on server, proceeding to update...");
      await sendMobileChangeRequest();
    }
  } catch (e) {
    print("❌ Mobile Verify Exception: $e");
    _showInvalidOTPDialog("Something went wrong. Please try again.");
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
 final localization = Provider.of<LocalizationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
         localization.translate('Forgot Mobile Number'), 
        style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.translate('Recover your CSC Account'), 
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,fontSize: 18)),
              SizedBox(height: screenHeight * 0.02),
              Text(
               localization.translate('Enter your CSC registered mobile number'), 
              style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: screenHeight * 0.02),
              
              TextField(
                controller: _controller,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: localization.translate('Enter new mobile number'),hintStyle: GoogleFonts.lato(fontSize: 15)
                ),
                keyboardType: TextInputType.phone,
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              SizedBox(
                height: screenHeight * 0.06,
                width: double.infinity,
                child: ElevatedButton(
 onPressed: isLoading ? null : verifyMobileNumber, // Before: sendMobileChangeRequest
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                       localization.translate('Next'), 
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white)),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),
              Center(
                child: Column(
                  children: [
                    Text(
                     localization.translate("Don't have access to the CSC registered mobile number?"), 
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(height: screenHeight * 0.01),
                    TextButton.icon(
                      onPressed: () {
                        // Contact customer care action
                      },
                      icon: Icon(Icons.call, color: Colors.orange),
                      label: Text(localization.translate('Contact Customer Care'), 
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Color.fromRGBO(2, 5, 62, 1))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
