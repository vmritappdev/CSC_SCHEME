import 'dart:convert';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/otpscreen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CurvedImageScreen2 extends StatelessWidget {
  const CurvedImageScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JEWELLERS',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Segoe UI',
      ),
      home: const SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
 bool _isLoading = false; // Control loading screen
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _controlleremail = TextEditingController();
  
  bool _termsAccepted = true;

 String? previousPhoneNumber;







   Future<void> _checkSavedPhoneNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload(); // Ensure the latest data is fetched
  String? savedPhoneNumber = prefs.getString('userPhoneNumber');

  if (savedPhoneNumber!.length == 10) {
    print("✅ Mobile Number Found: $savedPhoneNumber");

    // Navigate directly to the HomeScreen
  
  } else {
    print("❌ Mobile Number Not Found");
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('userPhoneNumber');
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
                color: Color.fromRGBO(2, 5, 62, 1),
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
                  color: Color.fromRGBO(2, 5, 62, 1),
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
  if (_formKey.currentState!.validate()) {

    // **🔥 Correct Network Check Before API Call**
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
    //  _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
     Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ErrorScreen()), // ✅
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

  return Scaffold(
    appBar: AppBar(
      leading: BackButton(color: Colors.white,onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen1()));
      },),
      title: const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'PlayfairDisplay',
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 18, 1, 76),
    ),
    body: Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(255, 18, 1, 76),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
               // const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                      key: _formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/cs.png',
                          height: 50,
                          width: 50,
                          color: const Color.fromRGBO(2, 5, 67, 1),
                        ),
                       // const SizedBox(height: 8),
                        Text(
                          'J E W E L L E R S',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Since 1971',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                    
                        // First Name
                        buildTextFormField(
                          _controllerFirstName,
                          localization.translate("First Name*"),
                          Icons.person_outline,
                          TextInputType.name,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return localization.translate("enter_first_name");
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                    
                        // Last Name
                        buildTextFormField(
                          _controllerLastName,
                          localization.translate("Last Name*"),
                          Icons.person_2,
                          TextInputType.name,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return localization.translate("enter_last_name");
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                    
                        // Mobile Number
                        _buildPhoneField(),
                        SizedBox(height: screenHeight * 0.02),
                    
                        // Email
                        buildTextFormField(
                          _controlleremail,
                          localization.translate("Email(Optional)"),
                          Icons.email_outlined,
                          TextInputType.emailAddress,
                          
                          (value) {
                            if (value == null || value.isEmpty) return null;
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.025),
                    
                        // Terms and Conditions
                     Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value!;
                            });
                          },
                          activeColor: const Color.fromARGB(255, 18, 5, 93), // ✅ Blue checkbox
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline, // ✅ Underline
                                    color: Color.fromARGB(255, 18, 5, 93), // ✅ Blue color
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                    // Optional: Show dialog or navigate
                    print("Terms tapped");
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    
                        SizedBox(height: screenHeight * 0.03),
                    
                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // do signup
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
    child: SizedBox(
      child: TextFormField(
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp("[#&']")),
        ],
        textInputAction: TextInputAction.next,
        controller: controller,
        textCapitalization: TextCapitalization.words,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
         
          counterText: '',
          labelText: labelText,
          labelStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: screenWidth * 0.03,
              color: const Color.fromRGBO(43, 49, 101, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          prefixIcon: Icon(icon),
         // suffixIcon: Icon(icon),

          // ✅ Static green check icon
          suffixIcon: const Icon(
            Icons.check,
            size: 16,
            color: Colors.green,
          ),

          // 👇 Reduced vertical padding for height
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),

          // 👇 No background color
          filled: false,

          // 👇 Light grey border when NOT focused
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 237, 233, 233), // Light grey border
              width: 1.5,
            ),
          ),

          // 👇 Blue border when focused
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 18, 5, 93), // Focused color
              width: 2,
            ),
          ),

          // 👇 Label floating color
          floatingLabelStyle: const TextStyle(
            color: Color.fromRGBO(2, 9, 90, 1),
          ),
        ),
        validator: validator,
      ),
    ),
  );
}

 Widget _buildPhoneField() {
  final localization = Provider.of<LocalizationProvider>(context, listen: true);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0,),
    child: FormField<String>(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localization.translate("Please enter a mobile number");
        } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
          return localization.translate("Enter a valid 10-digit mobile number");
        }
        return null;
      },
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntlPhoneField(
              controller: phoneController,
              initialCountryCode: 'IN',
              decoration: InputDecoration(
                 suffixIcon: const Icon(
            Icons.check,
            size: 16,
            color: Colors.green,
          ),
                labelText: localization.translate("Mobile Number"),
                labelStyle: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 11,
                    color: Color.fromRGBO(43, 49, 101, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 18, 5, 93),
                    width: 2,
                  ),
                ),
                floatingLabelStyle: const TextStyle(color: Color.fromRGBO(2, 9, 90, 1)),
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 237, 233, 233), // Light grey border
              width: 1.5,
            ),
          ),
                errorText: field.errorText,
              ),
              dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              dropdownIconPosition: IconPosition.trailing,
              onChanged: (phone) {
                field.didChange(phone.number); // ✅ update correct value for validator
              },
            ),
          ],
        );
      },
    ),
  );
}

}