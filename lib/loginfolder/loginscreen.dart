import 'dart:convert';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/loginotp.dart';

import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';

import 'package:csc/localization/localizationpro.dart';

import 'package:csc/loginfolder/mpin%20login.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/registationfolder/create%20account.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});

  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mpinController = TextEditingController();
  String errorMessage = '';
bool isLoading = false;  // Loading state
   
String phoneNumber = ""; // ఫోన్ నంబర్ స్టోర్ చేయడానికి
bool _rememberMe = false;



Future<void> _checkSavedPhoneNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload(); // Ensure the latest data is fetched
  String? savedPhoneNumber = prefs.getString('userPhoneNumber');
  String? savedMpin = prefs.getString('userMpin');


  if (savedPhoneNumber != null && savedPhoneNumber.length == 10 && savedMpin == "true") {
  print("✅ Mobile Number Found: $savedPhoneNumber");

  // Navigate directly to the HomeScreen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ),
  );
} else {
  print("❌ No valid Mobile Number found");
  // Optionally, show a message
}

}


Future<void> savePhoneNumber(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhoneNumber', mobileNumber);
    await prefs.setString('userMpin', 'true');
    await prefs.reload();  // ✅ Ensures the latest value is stored
    
    print("✅ Mobile Number Saved: $mobileNumber");
  }

  // ✅ Load Mobile Number from SharedPreferences
  Future<void> loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();  // ✅ Reloads latest data
    String? phoneNumber = prefs.getString('userPhoneNumber');

    setState(() {
      
     
    });
    print("✅ Loaded Mobile Number: $phoneNumber");
    }



@override
  void initState() {
    super.initState();
    loadPhoneNumber();
    
 WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkSavedPhoneNumber();
  });
  
    
    
  }

 


  

Future<void> _fetchUserDetails() async {
  String apiUrl = "$baseUrl/get_reg_account_details.php";

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    String? mobileNumber = prefs.getString('userPhoneNumber');

    if (mobileNumber == null || mobileNumber.length != 10) {
      print("❌ Mobile Number not found or invalid in SharedPreferences");
      return;
    }

    print("📤 Sending request with mobile number: $mobileNumber");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'mobile_no': mobileNumber},
    );

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is! Map) {
        print("❌ JSON root is not a map");
        return;
      }

      if (jsonResponse['status'] == 200 &&
          jsonResponse['account_details'] is List &&
          (jsonResponse['account_details'] as List).isNotEmpty) {
        
        final dynamic account = (jsonResponse['account_details'] as List).first;

        if (account is Map<String, dynamic>) {
          // Use toString() safely
          final firstName = account['f_name']?.toString().trim() ?? '';
          final lastName = account['l_name']?.toString().trim() ?? '';
          final phone = account['mobile_no']?.toString().trim() ?? '';
          final email = account['email_id']?.toString().trim() ?? '';

          // Debug logs
          print("✅ First Name: $firstName");
          print("✅ Last Name : $lastName");
          print("✅ Phone     : $phone");
          print("✅ Email     : $email");

          // Save only strings
          await prefs.setString('firstName', firstName);
          await prefs.setString('lastName', lastName);
          await prefs.setString('phoneNumber', phone);
          await prefs.setString('email', email);
        } else {
          print("❌ account_details[0] is not a valid map");
        }
      } else {
        print("❌ Invalid or empty data received");
      }
    } else {
      print("❌ Server error: ${response.statusCode}");
    }
  } catch (e, stackTrace) {
    print("❌ Error fetching data: $e");
    print("📛 StackTrace:\n$stackTrace");
  }
}




  // 🔹 MPIN వెరిఫై చేసే Function
Future<Map<String, dynamic>> _submitMpinToServer(String mpin, String mobileNumber) async {
  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    Navigator.push(
    context,
      MaterialPageRoute(builder: (context) => const ErrorScreen()),
    );
    return {'success': false, 'reason': 'NO_INTERNET'};
  }

  String phpUrl = "$baseUrl/mpin_verify.php";
  try {
    final response = await http.post(
      Uri.parse(phpUrl),
      body: {'mpin': mpin, 'mobile_no': mobileNumber},
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      bool success = jsonResponse['status'] == 200 && jsonResponse['login'] == 'SUCCESS';
     // String reason = jsonResponse['login1'] ?? 'UNKNOWN';
      String reason = jsonResponse['login1']?.toString() ?? 'UNKNOWN';
      return {'success': success, 'reason': reason};
    }

    return {'success': false, 'reason': 'SERVER_ERROR'};
  } catch (e) {
    return {'success': false, 'reason': 'EXCEPTION'};
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
      MaterialPageRoute(builder: (context) => const ErrorScreen()),
    );
    return;
  }

  if (mobileNumber.isEmpty || mobileNumber.length != 10) {
    setState(() {
      errorMessage = localization.translate('Please enter a valid 10-digit Mobile Number');
    });
   Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      setState(() {
        errorMessage = '';
      });
    }
  });
  return;
}

  if (mpin.isEmpty || mpin.length != 4) {
    setState(() {
      errorMessage = localization.translate('Please enter a valid 4-digit MPIN');
    });
   Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      setState(() {
        errorMessage = '';
      });
    }
  });
  return;
}

  showLoaderDialog(context);

  // 👉 Submit & get both success and reason
  Map<String, dynamic> result = await _submitMpinToServer(mpin, mobileNumber);
  bool isValid = result['success'];
  String reason = result['reason'];

  Navigator.pop(context);

  if (isValid) {
    await savePhoneNumber(mobileNumber);
    await _fetchUserDetails();
    await Future.delayed(const Duration(milliseconds: 300));
    await loadPhoneNumber();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(activescheme: Activescheme()),
      ),
    );
  } else {
    // 👉 Show reason-specific popup
    _showErrorPopup(reason);
  }
}



// Declare a FocusNode for the mobile number field
FocusNode phoneFocusNode = FocusNode();

void _showErrorPopup(String reason) {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);
  String errorMsg;

  if (reason == 'MPIN') {
    errorMsg = localization.translate("The MPIN you entered is incorrect. Please try again.");
  } else if (reason == 'MOBILE_NO') {
    errorMsg = localization.translate("We couldn’t verify your MPIN or Mobile Number. Please recheck and try again.");
  } else {
    errorMsg = localization.translate("");
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                errorMsg,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(2, 5, 62, 1),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  phoneController.clear();
                  mpinController.clear();
                  setState(() {});
                  FocusScope.of(context).requestFocus(phoneFocusNode);
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



  // title: Text("Login Failed"),
        //  content: Text("Invalid MPIN or Mobile Number. Please try again."),

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingAll = screenWidth * 0.05;
   // double fontSizeLarge = screenHeight * 0.035;
    double fontSizeSmall = screenHeight * 0.02;
    double inputFieldHeight = screenHeight * 0.06;
    double buttonHeight = screenHeight * 0.06;
    final localization = Provider.of<LocalizationProvider>(context,listen: false);

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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
           localization.translate('Are you sure do you want to exit?'),
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                 localization.translate('CANCEL'),
                  style: TextStyle(
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
                  style: TextStyle(
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

      child: SafeArea(
        child: Scaffold(
         
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(paddingAll),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [
               //   SizedBox(height: screenHeight * 0.08),
        
        
        /*
                   Align(
                        alignment: Alignment.bottomLeft,
                        child: BackButton(
                          color:  const Color.fromARGB(255, 12, 2, 42),
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                              builder: (context) =>  TermsAndConditionsScreen(),
                              )
                            );
                          },
                        ),
                      ),
        
                        */        SizedBox(height: screenHeight * 0.04),

          // 🖼️ Asset Image in center
          Center(
            child: Image.asset(
              'assets/images/cs.png', // 👈 replace with your image path
              height: screenHeight * 0.10, // adjust size
              fit: BoxFit.contain,
            ),
          ),

        //  SizedBox(height: screenHeight * 0.02),

        
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(localization.translate('Since 1971'),style: GoogleFonts.nunito(color: Color.fromRGBO(2, 5, 67, 1)),)
        
                     /*
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

                 */
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.020),
                  Text(
                    localization.translate("Welcome back to your CSC account!"),
                    style: GoogleFonts.nunito(fontSize: fontSizeSmall, color: Color.fromRGBO(2, 5, 67, 1),fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.04),


                  



                    SizedBox(height: screenHeight * 0.015),
        
                  _buildTextField(localization.translate("Mobile Number*"), phoneController, Icons.phone, inputFieldHeight, maxLength: 10),
                  SizedBox(height: screenHeight * 0.010),


                 

                  SizedBox(height: screenHeight * 0.015),
                  _buildTextField(localization.translate("Mpin"), mpinController, Icons.lock, inputFieldHeight, obscureText: true, maxLength: 4, isMPINField: true,),

                   SizedBox(height: screenHeight * 0.020),
        
                 Row(
  children: [
    // left side checkbox + text will start from left
    Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,  // force start
        children: [
         Checkbox(
  value: _rememberMe,
  activeColor: const Color.fromARGB(255, 3, 21, 47),
  onChanged: (bool? newValue) {
    setState(() {
      _rememberMe = newValue ?? false;
    });
  },
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // smaller box
  visualDensity: VisualDensity(horizontal: -4, vertical: -4), // make it more compact
),

SizedBox(width: 8,),

          Text(
            localization.translate("Remember me"),
            style: GoogleFonts.nunito(color: Colors.black, fontSize: 15),
          ),
        ],
      ),
    ),

    // right side forgot mpin
    GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginOtpScreen(),
          ),
        );
      },
      child: Text(
        localization.translate("Forgot MPIN?"),
        style: GoogleFonts.nunito(
          color: const Color.fromARGB(255, 88, 7, 1),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
)
,
        
                 // SizedBox(height: screenHeight * 0.010),
                  if (errorMessage.isNotEmpty)
                    Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: screenHeight * 0.016)),
        
                  SizedBox(height: screenHeight * 0.04),
                  _buildButton(localization.translate("Login"), const Color.fromARGB(255, 3, 21, 47), Colors.white, buttonHeight, _verifyMpin,),
                  SizedBox(height: screenHeight * 0.015),

                  RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: '--------------------------------------', 
        style: TextStyle(color: Colors.grey),
      ),
      TextSpan(
        text: ' Or ', 
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: '-------------------------------------', 
        style: TextStyle(color: Colors.grey),
      ),
    ],
  ),
)
,

  SizedBox(height: screenHeight * 0.015),

                  _buildButton(localization.translate("Login with OTP"), Colors.white, const Color.fromARGB(255, 3, 21, 47), buttonHeight, () {
                     Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginOtpScreen(),
            ),
          );
                
                      }),
        
                  SizedBox(height: screenHeight * 0.03),

                  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      localization.translate("Don't have an account?"),
      style: GoogleFonts.nunito(color: Colors.black, fontSize: fontSizeSmall),
    ),
    SizedBox(width: 4),
    InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CurvedImageScreen3(),
          ),
        );
      },
      child: Text(
        localization.translate("Sign up"),
        style: GoogleFonts.nunito( color: const Color.fromARGB(255, 3, 21, 47),
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.bold,)
      ),
    ),
  ],
),



                 
                 // SizedBox(height: screenHeight * 0.03),
                 // const Divider(),
                  SizedBox(height: screenHeight * 0.015),
                 // Text(localization.translate("or Login/Register with"), style: TextStyle(color: Colors.black54, fontSize: fontSizeSmall)),
                ],
              ),
            ),
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
  bool isMPINField = false, // ✅ Add this flag
}) {
  return SizedBox(
    height: fieldHeight,
    child: TextField(
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
      ],
      controller: controller,
      obscureText: isMPINField ? _isObscured : obscureText,
      keyboardType: label == "Mobile Number"
          ? TextInputType.phone
          : TextInputType.number,
      maxLength: maxLength,
    decoration: InputDecoration(
 // filled: true,
  //fillColor: Colors.grey.shade100, // light background color
  prefixIcon: Icon(icon, color: const Color.fromARGB(255, 3, 21, 47),size: 18,),
  suffixIcon: isMPINField
      ? IconButton(
          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility,size: 18,),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        )
      : null,
  labelText: label,labelStyle: GoogleFonts.nunito(fontSize: 14,color: const Color.fromARGB(255, 139, 139, 139)),
  counterText: "",
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey), // light grey border
    borderRadius: BorderRadius.circular(5),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: const Color.fromARGB(255, 3, 21, 47), width: 2),
    borderRadius: BorderRadius.circular(5),
  ),
  floatingLabelStyle: TextStyle(color: const Color.fromARGB(255, 3, 21, 47)),
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
  child: SpinKitFadingFour(
    color: Color.fromRGBO(2, 5, 67, 1,),
    size: 40.0,
  ),
);
    },
  );
}

  
}