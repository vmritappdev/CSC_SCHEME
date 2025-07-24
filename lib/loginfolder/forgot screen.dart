
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/loginfolder/mpin%20login.dart';
import 'package:csc/loginfolder/mpinscreen.dart';

import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/constantcolor.dart';
import 'package:csc/utillity/netmix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
      home: const ForgotScreen(),
    ),
  );
}

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen>    with NetworkMixin {
  final TextEditingController _controllerMobileNumber = TextEditingController();
  final TextEditingController _controllerOtp = TextEditingController();

  bool _isOtpVisible = false;
  bool _isResendAvailable = false;
  bool _isVerifyEnabled = false;
  int _timerSeconds = 30;
  String receivedOtp = "";
  DateTime? otpReceivedTime; // ✅ OTP timestamp

   String phoneNumber = '';

bool _isLoading = false; // declare this in your State



   bool showNewNumberBox = true; // initial state

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      
      _controllerMobileNumber.text = prefs.getString('phoneNumber') ?? '';
      
    });
  }


@override
  void initState() {
    super.initState();
    loadUserDetails();
      
  }





  
  @override
  void dispose() {
    _controllerMobileNumber.dispose();
    _controllerOtp.dispose();
    super.dispose();
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                child:Text(
  message,
  textAlign: TextAlign.center,
  style: GoogleFonts.lato(fontSize: 15, color: Colors.red),
),

              ),
              const SizedBox(height: 20),
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

  bool isVerifyButtonDisabled = false;

 Future<void> verifyMobileNumber() async {
  if (isVerifyButtonDisabled) return;

  setState(() {
    isVerifyButtonDisabled = true;
    _isLoading = true; // show loader
    showNewNumberBox = false;
  });

  String mobileNumber = _controllerMobileNumber.text.trim();
  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  if (mobileNumber.isEmpty || mobileNumber.length != 10) {
    _showErrorPopup(localization.translate("Enter a valid 10-digit mobile number"));
    setState(() {
      isVerifyButtonDisabled = false;
      _isLoading = false; // hide loader
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/mobile_verification.php'),
      body: {'mobile_no': mobileNumber},
    );

    var responseData = jsonDecode(response.body);
    print("✅ API Response: $responseData");

    if (responseData['login'] == 'SUCCESS') {
      setState(() {
        _isOtpVisible = true;
        _isLoading = false; // hide loader
      });
      fetchOtpApi();
    } else {
      _showErrorPopup(localization.translate("This mobile number is not found."));
      setState(() {
        isVerifyButtonDisabled = false;
        _isLoading = false;
      });
    }
  } catch (e) {
    print("❌ API Exception: $e");
    _showErrorPopup("Error: $e");
    setState(() {
      isVerifyButtonDisabled = false;
      _isLoading = false;
    });
  }
}

  Future<void> fetchOtpApi() async {
    String mobileNumber = _controllerMobileNumber.text;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp.php'),
        body: {'mobile_no': mobileNumber},
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          receivedOtp = responseData['otp'].toString();
          _isResendAvailable = false;
          _timerSeconds = 30;
          otpReceivedTime = DateTime.now(); // ✅ Store timestamp
        });

        _startResendTimer();

        print("✅ OTP Received: $receivedOtp");
      } else {
        print("🔴 API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🔴 API Call Failed: $e");
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
        _startResendTimer();
      } else {
        setState(() {
          _isResendAvailable = true;
        });
      }
    });
  }

  void _checkOtpMatch() {
    final enteredOtp = _controllerOtp.text;

    if (enteredOtp.length == 6) {
      setState(() {
        _isVerifyEnabled = true;
      });

      // ✅ Check for expiry (10 mins)
      if (otpReceivedTime != null && DateTime.now().difference(otpReceivedTime!).inMinutes >= 10) {
        _showErrorPopup("⌛OTP timer over, please resend");
          _controllerOtp.clear(); // ❌ Clear OTP field
        setState(() {
          _isVerifyEnabled = false;
        });
        return;
      }

      if (enteredOtp == receivedOtp) {
        print("✅ OTP Verified!");
        _navigateToNextScreen();
      } else {
        _showErrorPopup("Invalid OTP");
          _controllerOtp.clear(); // ❌ Clear OTP field
        setState(() {
          _isVerifyEnabled = false;
        });
      }
    } else {
      setState(() {
        _isVerifyEnabled = false;
      });
    }
  }


  Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 
  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) =>  LoginScreen1()), 
   
      );
  }


  void _navigateToNextScreen() {
    Navigator.push(
    context,
      MaterialPageRoute(builder: (context) => const CreateMpinScreen5()),
    );
  }

  @override
  Widget build(BuildContext context) {
     final localization = Provider.of<LocalizationProvider>(context,listen: false);

    return  Scaffold(
        
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 80),

           Align(
            alignment: Alignment.bottomLeft,
             child: IconButton(
               onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => LoginPage(), )
                );
                
               },
               icon: Icon(Icons.arrow_forward), // ← Left side arrow icon
             ),
           ),

              Image.asset('assets/images/csc2.png', height: 90),
               Text(
               localization.translate('CSCJEWELLERYS'),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color.fromRGBO(43, 49, 101, 1)),
              ),
              const SizedBox(height: 40),
      
              TextFormField(
              inputFormatters: [
      FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
       // Blocks " and ,
        ],
               maxLength: 10,
               readOnly: true,
               controller: _controllerMobileNumber,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                counterText: '',
                  hintText: localization.translate("Mobile Number*"),
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),



              const SizedBox(height: 20),




           SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.blue,
    ),
    onPressed: isVerifyButtonDisabled ? null : verifyMobileNumber,
    child: _isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
        : Text(
            localization.translate("Verify Mobile Number"),
            style: TextStyle(color: Colors.white),
          ),
  ),
),


const SizedBox(height: 20),


  if (showNewNumberBox)
  GestureDetector(
    onTap: () {
   logout();
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color:AppColors.blue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_android, color: Color.fromARGB(255, 2, 20, 36)),
          const SizedBox(width: 8),
          Text(
            localization.translate('New Mobile Number Register Here'),
            style: const TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  )
,
      
              if (_isOtpVisible) ...[
                const SizedBox(height: 20),
      
TextFormField(
  controller: _controllerOtp,
  keyboardType: TextInputType.number,
  maxLength: 6,
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 20,
    color: Colors.black,
    letterSpacing: 29, // 👉 ఇది actual input spacing కి
  ),
  decoration: InputDecoration(
    hintText: localization.translate('Enter OTP'),
    hintStyle: const TextStyle(fontSize: 11, letterSpacing: 10), // optional
    counterText: '',
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color.fromARGB(255, 9, 1, 34)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color.fromARGB(255, 9, 1, 34), width: 2),
    ),
  ),
  onChanged: (value) {
    if (value.length == 6) {
      _checkOtpMatch(); // OTP చెక్ చేయడం
    }
  },
),

                const SizedBox(height: 20),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isResendAvailable
                        ? localization.translate("Didn't receive the OTP?")
                        :  "${localization.translate("Resend OTP in")} $_timerSeconds ${localization.translate("seconds")}"
                        ),
                    if (_isResendAvailable)
                      TextButton(
                        onPressed: fetchOtpApi,
                        child: const Text("Resend", style: TextStyle(color: AppColors.blue)),
                      ),
                  ],
                ),
      
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _isVerifyEnabled ? _checkOtpMatch : null,
                    child:  Text(localization.translate("✅ Verify OTP"), style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      
    );
  }
}

