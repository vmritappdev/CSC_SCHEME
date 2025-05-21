import 'dart:convert';
import 'dart:async'; // Import for async operations
import 'dart:io';






import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/chaingedscreens.dart/otpscreen.dart';
import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home:const CurvedImageScreen2(),
    ),
  );
}


class CurvedImageScreen2 extends StatefulWidget {
  const CurvedImageScreen2({super.key});

  @override
  State<CurvedImageScreen2> createState() => _CurvedImageScreen2State();
}

class _CurvedImageScreen2State extends State<CurvedImageScreen2> {





  bool _isLoading = false; // Control loading screen
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _controlleremail = TextEditingController();
  String _message = ''; // Message to show after submission
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
    phoneController.text = phoneNumber!;
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
  void showErrorDialog(String message) {
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
            message,
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
                  child: const Text(
                    "OK",
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
          _message = responseData['response'] == 'success'
              ? 'Success: ${responseData['message']}'
              : 'Error: ${responseData['message']}';
        });

        if (responseData['response'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstName', _controllerFirstName.text);
          await prefs.setString('lastName', _controllerLastName.text);
          await prefs.setString('phoneNumber', phoneController.text);
          await prefs.setString('email', _controlleremail.text);

          previousPhoneNumber = phoneController.text;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OtpScreen()),
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
      
      body: Stack(
        
        children: [
          
          SafeArea(
  child: Column(
    children: [
      // Top Header Section (unchanged)
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen1()),
                    );
                  },
                ),
              ),
              Image.asset(
                'assets/images/csc2.png',
                height: screenHeight * 0.1,
              ),
              Text(
                localization.translate("JEWELLERS"),
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: const Color.fromRGBO(2, 5, 67, 1),
                ),
              ),
            ],
          ),
        ),
      ),

      // Remaining content wrapped in Expanded
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05), 
                    child: Text(
                      localization.translate("Register"),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: const Color.fromRGBO(2, 5, 69, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05), 
                    child: Text(
                      localization.translate("Please provide your basic information"),
                      style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
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
                  _buildPhoneField(),
                  SizedBox(height: screenHeight * 0.02),


                  buildTextFormField(
                    _controlleremail,
                    localization.translate("Email(Optional)"),
                    Icons.email_outlined,
                    TextInputType.emailAddress,
                    
                  (value) {
  if (value == null || value.isEmpty) {
    return null; // 
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email'; // 
  }
  return null; // 
},

                    
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),

      // Fixed Button
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.075,
          vertical: screenHeight * 0.025,
        ),
        child: SizedBox(
          width: double.infinity,
          height: screenHeight * 0.06,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: _isLoading ? null : () => submitForm(),
            child: Text(
              localization.translate("Verify Number"),
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),


          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Image.asset(
                  'assets/images/gif.gif', // Replace with your Lottie loader
                  height: 100,
                  width: 100,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build text form field method
  Widget buildTextFormField(
    TextEditingController controller,
    String labelText,
    IconData icon,
    TextInputType keyboardType,
    String? Function(String?) validator, {
    int? maxLength,
    
  }) {
     final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
          
          labelStyle: GoogleFonts.lato(
            textStyle: TextStyle(fontSize: screenWidth * 0.04, color: const Color.fromRGBO(43, 49, 101, 1),fontWeight: FontWeight.bold),
          ),
          prefixIcon: Icon(icon),
         // contentPadding: EdgeInsets.all(15),
          border: const OutlineInputBorder(),
           focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color.fromARGB(255, 18, 5, 93), width: 2),
        ),
        floatingLabelStyle: const TextStyle(color: Color.fromRGBO(2, 9, 90, 1)),
           // contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Reduce padding
             contentPadding: EdgeInsets.all(screenWidth * 0.03),
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
       inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))

  ],
      textInputAction: TextInputAction.next,
      controller: phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 10, // Ensures only 10 digits can be entered
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
        labelText:localization.translate("Mobile Number"),
      //  labelStyle: const TextStyle(color: Colors.black),
       labelStyle: GoogleFonts.lato(
            textStyle: const TextStyle(fontSize: 15, color: Color.fromRGBO(43, 49, 101, 1),fontWeight: FontWeight.bold),
          ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/flag.png",
                height: 20,
              ),
              const SizedBox(width: 6),
              const Text("+91", style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromRGBO(43, 49, 101, 1),)),
              const SizedBox(width: 6),
            ],
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color.fromARGB(255, 18, 5, 93), width: 2),
        ),
        floatingLabelStyle: const TextStyle(color: Color.fromRGBO(2, 9, 90, 1)),
        counterText: "", // Hides the default character count indicator
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localization.translate("Please enter a mobile number");
        } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
          return "Enter a valid 10-digit mobile number";
        }
        return null;
      },
    ),
  );
}





}
