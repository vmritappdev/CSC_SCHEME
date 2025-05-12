import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/loginotp.dart';
import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/dashboardscreens/terms_condition.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/loginfolder/forgotscreen%202.dart';
import 'package:csc/loginfolder/mpin%20login.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/registationfolder/create%20account.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen1 extends StatefulWidget {
  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mpinController = TextEditingController();
  String errorMessage = '';
   String _message = '';
bool isLoading = false;  // Loading state
   
String phoneNumber = ""; // ఫోన్ నంబర్ స్టోర్ చేయడానికి





Future<void> _checkSavedPhoneNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload(); // Ensure the latest data is fetched
  String? savedPhoneNumber = prefs.getString('userPhoneNumber');

  if (savedPhoneNumber != null && savedPhoneNumber.length == 10) {
    print("✅ Mobile Number Found: $savedPhoneNumber");

    // Navigate directly to the HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  } else {
    print("❌ No valid Mobile Number found");
    // Optionally, you can show a message or take other actions here
  }
}


Future<void> savePhoneNumber(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhoneNumber', mobileNumber);
    await prefs.reload();  // ✅ Ensures the latest value is stored
    
    print("✅ Mobile Number Saved: $mobileNumber");
  }

  // ✅ Load Mobile Number from SharedPreferences
  Future<void> loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();  // ✅ Reloads latest data
    String? phoneNumber = prefs.getString('userPhoneNumber');

    if (phoneNumber != null) {
      setState(() {
        
        phoneController.text = phoneNumber;
      });
      print("✅ Loaded Mobile Number: $phoneNumber");
    } else {
      print("❌ Mobile Number Not Found");
    }
  }



@override
  void initState() {
    super.initState();
    loadPhoneNumber();
  _checkSavedPhoneNumber();
  
    
    
  }

 


  

Future<void> _fetchUserDetails() async {
  const String apiUrl = "$baseUrl/get_reg_account_details.php";  //"https://vmrdemos.com/csc_scheme/get_reg_account_details.php"

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // ✅ Ensures latest data is fetched
    String? mobileNumber = prefs.getString('userPhoneNumber');

    if (mobileNumber == null || mobileNumber.length != 10) {
      print("❌ Mobile Number not found in SharedPreferences");
      return;
    }

    print("📤 Sending Mobile Number to API: $mobileNumber");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"}, // ✅ Important
      body: {'mobile_no': mobileNumber},
    );

    print("📥 API Response Status: ${response.statusCode}");
    print("📥 API Response Body: ${response.body}");

    final jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 200) {
      print("✅ User Details: $jsonResponse");

      var userDetails = jsonResponse['account_details'][0]; // ✅ First user data
      String firstName = userDetails['f_name']?.trim() ?? "";
      String lastName = userDetails['l_name']?.trim() ?? "";
      String phoneNumber = userDetails['mobile_no']?.trim() ?? "";
      String email = userDetails['email_id']?.trim() ?? "";

      // ✅ Save to SharedPreferences
      await prefs.setString('firstName', firstName);
      await prefs.setString('lastName', lastName);
      await prefs.setString('phoneNumber', phoneNumber);
      await prefs.setString('email', email);

      print("✅ Saved Data: FirstName: $firstName, LastName: $lastName, Mobile: $phoneNumber, Email: $email");

    } else {
      print("❌ User details fetch failed: ${jsonResponse['message']}");
    }
  } catch (e) {
    print("❌ Error fetching user details: $e");
  }
}





  // 🔹 MPIN వెరిఫై చేసే Function
  Future<bool> _submitMpinToServer(String mpin, String mobileNumber) async {

     bool hasInternet = await checkInternet();
    if (!hasInternet) {
      

    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ErrorScreen()), // ✅
  );
      return false;
    }


    const String phpUrl = "$baseUrl/mpin_verify.php";  
    try {
      final response = await http.post(
        Uri.parse(phpUrl),
        body: {'mpin': mpin, 'mobile_no': mobileNumber},
      );


        print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] == 200 && jsonResponse['login'] == 'SUCCESS';

        
      }
      return false;
    } catch (e) {
      return false;
    }
  }

void _verifyMpin() async {
  String mpin = mpinController.text.trim();
  String mobileNumber = phoneController.text.trim();
  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ErrorScreen()), // Error screen for no internet
    );
    return;
  }

  // Mobile Number Validation
  if (mobileNumber.isEmpty || mobileNumber.length != 10) {
    setState(() {
      errorMessage = localization.translate('Please enter a valid 10-digit Mobile Number');
    });
    return;
  }

  // MPIN Validation
  if (mpin.isEmpty || mpin.length != 4) {
    setState(() {
      errorMessage = localization.translate('Please enter a valid 4-digit MPIN');
    });
    return;
  }

  // Show Loader (Lottie animation, for example)
  showLoaderDialog(context);

  // Submit MPIN and Mobile Number to Server
  bool isValid = await _submitMpinToServer(mpin, mobileNumber);

  // Hide Loader after validation
  Navigator.pop(context); // This will hide the loader

  if (isValid) {
    // Save Mobile Number to SharedPreferences
    await savePhoneNumber(mobileNumber);

    // Fetch User Details
    await _fetchUserDetails();

    // Navigate to HomeScreen
    await Future.delayed(Duration(milliseconds: 300)); // Allow saving to complete
    await loadPhoneNumber(); // Ensure it loads correctly

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(activescheme: Activescheme()),
      ),
    );
  } else {
    // Show error popup if MPIN/Number is incorrect
    _showErrorPopup();
  }
}



// Declare a FocusNode for the mobile number field
FocusNode phoneFocusNode = FocusNode();

void _showErrorPopup() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final localization = Provider.of<LocalizationProvider>(context);
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Column(
        mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            // 🔴 Icon Added
            Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            SizedBox(height: 10),
            // 📄 Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                localization.translate("We couldn’t verify your MPIN or Mobile Number.\nPlease recheck and try again."),
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 🔘 OK Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
              color: const Color.fromRGBO(2, 5, 62, 1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  phoneController.clear();  // Clear the mobile number field
                  mpinController.clear();  // Clear the MPIN field
                  setState(() {});           // Refresh the UI
                  
                  // Focus the phone number field after closing the popup
                  FocusScope.of(context).requestFocus(phoneFocusNode);  // Focus on the phone field
                },
                child: Text(
                  localization.translate("OK"),
                  style: TextStyle(
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


  // title: Text("Login Failed"),
        //  content: Text("Invalid MPIN or Mobile Number. Please try again."),

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingAll = screenWidth * 0.05;
    double fontSizeLarge = screenHeight * 0.035;
    double fontSizeSmall = screenHeight * 0.02;
    double inputFieldHeight = screenHeight * 0.07;
    double buttonHeight = screenHeight * 0.06;
      final localization = Provider.of<LocalizationProvider>(context);

    return Scaffold(
     
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingAll),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.08),



               Align(
                    alignment: Alignment.bottomLeft,
                    child: BackButton(
                      color:  const Color.fromARGB(255, 12, 2, 42),
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => TermsAndConditionsScreen(),
                          )
                        );
                      },
                    ),
                  ),

                  

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                 
                  Icon(Icons.touch_app, color: Colors.orange, size: screenWidth * 0.08),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                   localization.translate("CSC"),
                    style: GoogleFonts.roboto(
                      fontSize: fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 3, 21, 47),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                localization.translate("Welcome back to your CSC account!"),
                style: TextStyle(fontSize: fontSizeSmall, color: Colors.black54),
              ),
              SizedBox(height: screenHeight * 0.04),

              _buildTextField(localization.translate("Mobile Number*"), phoneController, Icons.phone, inputFieldHeight, maxLength: 10),
              SizedBox(height: screenHeight * 0.025),
              _buildTextField(localization.translate("MPIN"), mpinController, Icons.lock, inputFieldHeight, obscureText: true, maxLength: 4),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ForgotScreen1(),
                    )
                  );
                },
                child: Align(
                alignment: Alignment.centerRight,
                child: Text(localization.translate("Forgot MPIN?"), style: TextStyle(color: const Color.fromARGB(255, 12, 2, 42), fontSize: fontSizeSmall,fontWeight: FontWeight.bold)),
                            ),
              ),

              SizedBox(height: screenHeight * 0.015),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: screenHeight * 0.016)),

              SizedBox(height: screenHeight * 0.04),
              _buildButton(localization.translate("Login"), Color.fromARGB(255, 3, 21, 47), Colors.white, buttonHeight, _verifyMpin,),
              SizedBox(height: screenHeight * 0.015),
              _buildButton(localization.translate("Login with OTP"), Colors.white, Color.fromARGB(255, 3, 21, 47), buttonHeight, () {
                 Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>LoginOtp(),
        ),
      );
            
                  }),

              SizedBox(height: screenHeight * 0.03),
              Text(localization.translate("New on CSC?"), style: TextStyle(color: Colors.black54, fontSize: fontSizeSmall)),
                 SizedBox(height: screenHeight * 0.02),
              GestureDetector(child: Text(localization.translate("Register here"), style: TextStyle(color:Color.fromARGB(255, 3, 21, 47), fontSize: fontSizeSmall,fontWeight: FontWeight.bold),
              ),
              onTap: () {
                 Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>CurvedImageScreen2(),
        ),
      );
              },
              ),

              SizedBox(height: screenHeight * 0.03),
              Divider(),
              SizedBox(height: screenHeight * 0.015),
             // Text(localization.translate("or Login/Register with"), style: TextStyle(color: Colors.black54, fontSize: fontSizeSmall)),
            ],
          ),
        ),
      ),
    );
  }

bool _isObscured = true; // 🔹 MPIN visibility toggle

Widget _buildTextField(
  String label,
  TextEditingController controller,
  IconData icon,
  double fieldHeight, {
  bool obscureText = false,
  int? maxLength,
}) {
  return SizedBox(
    height: fieldHeight,
    child: TextField(
              inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
      controller: controller,
      obscureText: label == "MPIN" ? _isObscured : obscureText, // 🔹 MPIN Visibility Toggle
      keyboardType: label == "Mobile Number" ? TextInputType.phone : TextInputType.number,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 3, 21, 47)),
        suffixIcon: label == "MPIN"
            ? IconButton(
                icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured; // 🔹 Click చేస్తే టోగుల్ అవుతుంది
                  });
                },
              )
            : null,
        labelText: label, // 🔹 hintText Badulu labelText
       // filled: true,
        //fillColor: Colors.grey[200],
        counterText: "",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        //  borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

  Widget _buildButton(String text, Color bgColor, Color textColor, double buttonHeight, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Color.fromARGB(255, 3, 21, 47)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

void showLoaderDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          width: 100,
          height: 100,
          child: Image.asset(
            'assets/images/gif.gif', // ✅ Replace with your gif path
            fit: BoxFit.contain,
          ),
        ),
      );
    },
  );
}

  
}