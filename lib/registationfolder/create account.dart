import 'dart:convert';
import 'dart:async'; // Import for async operations







import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/dashboardscreens/terms3.dart';


import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/chaingedscreens.dart/otpscreen.dart';
import 'package:csc/loginfolder/mpin%20login.dart';
import 'package:csc/utillity/bouncing.dart';
import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/constantcolor.dart';
import 'package:csc/utillity/netmix.dart';


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home:const CurvedImageScreen3(),
    ),
  );
}


class CurvedImageScreen3 extends StatefulWidget {
  const CurvedImageScreen3({super.key});

  @override
  State<CurvedImageScreen3> createState() => _CurvedImageScreen3State();
}

class _CurvedImageScreen3State extends State<CurvedImageScreen3>  with NetworkMixin {





  bool _isLoading = false; // Control loading screen

    bool _termsAccepted = false;


bool _showTermsError = false;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _controlleremail = TextEditingController();
// Message to show after submission
   String? previousPhoneNumber;

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
  }
}



Future<void> savePhoneNumber(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhoneNumber', mobileNumber);
   // await prefs.reload();  // ✅ Ensures the latest value is stored

    await prefs.setString('userMpin', 'false');
    await prefs.reload();  // ✅ Ensures the latest value is stored
    
    print("✅ Mobile Number Saved: $mobileNumber");
  }
  
   
    
  @override
  void initState() {
    super.initState();
    loadPhoneNumber();
    _checkSavedPhoneNumber();
   
    
  }

  // Load phone number from shared preferences
  Future<void> loadPhoneNumber() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? phoneNumber = prefs.getString('userPhoneNumber');
   // phoneController.text = phoneNumber!;
    }

   void _showInvalidOTPDialog(String message) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;
   final localization = Provider.of<LocalizationProvider>(context,listen: false);

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
               // message,
                 localization.translate("Sorry, the mobile number has already been used. Please provide a different mobile number."),
                style: GoogleFonts.lato(fontSize: screenWidth * 0.04), // Dynamic Font Size
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.blue,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                 localization.translate("OK"),
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
  void showErrorDialog(String message) {
  final localization = Provider.of<LocalizationProvider>(context,listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              const Text(
                'Alert Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
           // message,
         localization.translate("Sorry, the mobile number has already been used. Please provide a different mobile number."),
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            SizedBox(
             // height: MediaQuery.of(context).size.height * 0.04, // 5% of screen height
             // width: MediaQuery.of(context).size.width * 0.9,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color:AppColors.blue,
                //  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text(
                   localization.translate("OK"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Submit form and send data to API
 


Future<void> submitForm() async {

  if (!_termsAccepted) {
    setState(() {
      _showTermsError = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showTermsError = false;
        });
      }
    });

    return;
  }



  if (_formKey.currentState!.validate()) {

    // **🔥 Correct Network Check Before API Call**
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
    //  _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
     Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>  ErrorScreen()), // ✅
  );
  
      return;
    }
    // **🔥 Fix Applied**
    
    if (phoneController.text == previousPhoneNumber) {
      _showInvalidOTPDialog('Phone number already used.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var url = "$baseUrl/save_account.php";    //"https://vmrdemos.com/csc_scheme/save_account.php"

    final data = {
      'f_name': _controllerFirstName.text,
      'l_name': _controllerLastName.text,
      'mobile_no': phoneController.text,
      'email_id': _controlleremail.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');

        setState(() {
        });

        if (responseData['response'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstName', _controllerFirstName.text);
          await prefs.setString('lastName', _controllerLastName.text);
          await prefs.setString('userPhoneNumber', phoneController.text);
          await prefs.setString('phoneNumber', phoneController.text);
          await prefs.setString('userMpin', 'false');
          await prefs.setString('email', _controlleremail.text);

          previousPhoneNumber = phoneController.text;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  OtpScreen()),
          );
        } else {
          _showInvalidOTPDialog(responseData['message']);
        }
      } else {
        _showInvalidOTPDialog('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showInvalidOTPDialog('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


 @override
Widget build(BuildContext context) {
  final localization = Provider.of<LocalizationProvider>(context, listen: true);
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;

  return WillPopScope(
    onWillPop: () async {
     Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LoginScreen1()),
);

     // Navigator.pop(context);  // back button press on device
      return false; // handled manually
    },
    child: Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header section
                Container(
                  height: screenHeight * 0.30,
                  width: screenWidth,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: BackButton(
                            color: AppColors.blue,
                            onPressed: () {
                             Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LoginScreen1()),
);

                            },
                          ),
                        ),
                        Image.asset(
                          'assets/images/csc2.png',
                          height: screenHeight * 0.1,
                          color: AppColors.blue,
                        ),
                        Text(
                          localization.translate("JEWELLERS"),
                          style: GoogleFonts.lato(
                            fontSize: screenWidth * 0.03,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                        Text(localization.translate('Since 1971'),
                            style: TextStyle(fontSize: 8, color: AppColors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
    
    
                
    
                // Form section in scroll view
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  localization.translate("Create Account"),
                                  style: GoogleFonts.poppins(
                                   // color: Colors.black,
                                   color: AppColors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                              Icon(Icons.touch_app, color: AppColors.blue),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
    
                          buildTextFormField(
                            _controllerFirstName,
                            localization.translate("First Name*"),
                            Icons.person_outline,
                            TextInputType.name,
                            (value) => value == null || value.isEmpty
                                ? localization.translate("enter_first_name")
                                : null,
                          ),
                          SizedBox(height: screenHeight * 0.02),
    
                          buildTextFormField(
                            _controllerLastName,
                            localization.translate("Last Name*"),
                           Icons.account_circle,
                            TextInputType.name,
                            (value) => value == null || value.isEmpty
                                ? localization.translate("enter_last_name")
                                : null,
                          ),
                          SizedBox(height: screenHeight * 0.02),
    
                          _buildPhoneField(),
                          SizedBox(height: screenHeight * 0.02),
    
                          buildTextFormField(
                            _controlleremail,
                            localization.translate("Email(Optional)"),
                            Icons.email_outlined,
                            TextInputType.emailAddress,
                            (value) {
                              if (value == null || value.isEmpty) return null;
                              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              return !emailRegex.hasMatch(value) ? 'Please enter a valid email' : null;
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),
    
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value!;
                                      _showTermsError = false;
                                    });
                                  },
                                  activeColor: AppColors.blue,
                                  side: BorderSide(color: AppColors.blue, width: 1.5),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                             // const SizedBox(width: 8),

                             SizedBox(width: 8, ),

                             Expanded(
  child: RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 12, color: Colors.black87),
      children: [
        TextSpan(text: localization.translate("I agree to the"), style: GoogleFonts.nunito()),
        TextSpan(
          text: localization.translate('Terms and Conditions'),
          style: GoogleFonts.nunito(
            decoration: TextDecoration.underline,
            color: AppColors.blue,
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
         ..onTap = () async {
  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: BouncingDotsLoader(
          color: Color(0xFF002970), // Paytm blue or gold
    size: 12.0,
        )
      );
    },
  );

  // Wait for 1 second (optional: simulate loading or API call)
  await Future.delayed(Duration(seconds: 1));

  // Close the loader
  Navigator.of(context).pop();

  // Navigate to TermsAndConditionScreen
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TermsAndConditionsScreen3()),
  );
},

        ),
      ],
    ),
  ),
),

                            ],
                          ),
    
                          SizedBox(height: screenHeight * 0.03), // Extra space before button

                        
                        ],
                      ),
                    ),
                  ),
                ),
    
                // Bottom fixed: Button + login text
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.075,
                    right: screenWidth * 0.075,
                    bottom: screenHeight * 0.030,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.06,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: _isLoading ? null : () => submitForm(),
                          child: Text(
                            localization.translate("Verify Number"),
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      GestureDetector(
                         onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  LoginScreen1()),
                              );
                            },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(localization.translate('Already have an account?')
                              , style: TextStyle(color: Colors.black)),


                            SizedBox(width: 5),

                            Text(
                              localization.translate('Login'),
                                style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold),
                              ),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    
          // Loader
          if (_isLoading)
            Container(
            color: Colors.black.withOpacity(0.7),
              child: Center(
                child: BouncingDotsLoader(
    color: Color(0xFF002970), // Paytm blue or gold
    size: 12.0,
  ),
              ),
            ),
    
        
          if (_showTermsError)
            Positioned(
              top: MediaQuery.of(context).padding.top + 0,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.translate('Please select Terms and Conditions'),
                        style: GoogleFonts.nunito(color: Colors.white),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showTermsError = false;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    ),
  );
}








    Widget buildTextFormField(
    TextEditingController controller,
    String labelText,
    IconData icon,
    TextInputType keyboardType,
    String? Function(String?) validator, {
    int? maxLength,
    
  }) {
     final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: TextFormField(
         inputFormatters: [
   FilteringTextInputFormatter.deny(RegExp("[#&']"))

  ],
        textInputAction: TextInputAction.next,
        controller: controller,
        textCapitalization: TextCapitalization.words,
        keyboardType: keyboardType,
        maxLength: maxLength,
       decoration: InputDecoration(
  counterText: '',
  labelText: labelText,
   labelStyle: GoogleFonts.nunito(fontSize: 14, color: const Color.fromARGB(255, 139, 139, 139)),
  errorStyle: TextStyle(
    fontSize: 9,
    height: 0.18, // NEW: make error text use less vertical space
  ),
  prefixIcon: Icon(icon,color: AppColors.blue,),
  isDense: true, // NEW: reduce default vertical space
  contentPadding: EdgeInsets.symmetric(
    vertical: screenWidth * 0.025, // smaller vertical padding
    horizontal: screenWidth * 0.03,
  ),
  border: const OutlineInputBorder(),
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color.fromARGB(255, 202, 200, 200))),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(color:   AppColors.blue, width: 2),
  ),
  floatingLabelStyle: const TextStyle(color:   AppColors.blue,),
),

        validator: validator,
      ),
    );
  }

 Widget _buildPhoneField() {
  final localization = Provider.of<LocalizationProvider>(context, listen: true);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.number,
      maxLength: 10,
      decoration: InputDecoration(
        counterText: "",
        labelText: localization.translate("Mobile Number"),
        labelStyle: GoogleFonts.nunito(fontSize: 14, color: const Color.fromARGB(255, 139, 139, 139)),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8),
            Image.asset(
              'assets/images/flag.png',  // 👉 +91 image
              width: 30,
              height: 20,
             // color: Colors.black,
            ),
            SizedBox(width: 4),
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 202, 200, 200)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: AppColors.blue,
            width: 2,
          ),
        ),
        floatingLabelStyle: const TextStyle(color: AppColors.blue),
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localization.translate("Please enter a mobile number");
        } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
          return localization.translate("Enter a valid 10-digit mobile number");
        }
        return null;
      },
    ),
  );
}




}
