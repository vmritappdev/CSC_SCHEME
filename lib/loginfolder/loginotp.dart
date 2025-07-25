

import 'dart:async';
import 'dart:convert';


import 'package:csc/localization/localizationpro.dart';
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/loginfolder/mpinscreen.dart';

import 'package:csc/utillity/constant.dart';
import 'package:csc/utillity/constantcolor.dart';
import 'package:csc/utillity/netmix.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginOtpScreen extends StatefulWidget {
  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen>  with NetworkMixin  {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isOtpSent = false;
  bool isLoading = false;
  String? receivedOtp;
  Timer? _otpTimer;
  Timer? _resendTimer;
  int _otpExpireSeconds = 600; // 10 minutes
  int _resendWaitSeconds = 60;
  bool canResend = false;

  final _pinFocus = FocusNode();   // optional, keyboard open ఉన్నట్టే ఉంటుంది
  

  @override
  void initState() {
    super.initState();
  }

 Future<void> verifyMobileNumber() async {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);
  String mobile = mobileController.text.trim();

  if (mobile.length != 10) {
    showError(localization.translate("Please enter a valid 10-digit mobile number"));
    return;
  }

  if (!await hasInternet()) {
    showError("No internet connection");
    return;
  }

  setState(() => isLoading = true);

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/mobile_verification.php"),
      body: {'mobile_no': mobile},
    );

    final data = json.decode(response.body);
    if (data['login'] == 'SUCCESS') {
      await sendOtp(mobile);
    } else {
      showError(localization.translate("No Records On This Number"));
    }
  } catch (e) {
    showError("Something went wrong");
  }

  setState(() => isLoading = false);
}

 Future<void> sendOtp(String mobile) async {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);
  final response = await http.post(
    Uri.parse("$baseUrl/otp.php"),
    body: {'mobile_no': mobile},
  );

  final data = json.decode(response.body);
  if (response.statusCode == 200 && data['otp'] != null) {
    receivedOtp = data['otp'].toString();

   // await savePhoneNumber(mobile);
   // await _fetchUserDetails();

    setState(() {
      isOtpSent = true;
      canResend = false;
      otpController.clear();
    });

    startOtpTimer();
    startResendTimer();
  } else {
    showError(localization.translate("Failed to send OTP"));
  }
}

  void startOtpTimer() {
    _otpTimer?.cancel();
    _otpExpireSeconds = 600;
    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _otpExpireSeconds--);
      if (_otpExpireSeconds <= 0) {
        _otpTimer?.cancel();
        receivedOtp = null;
      }
    });
  }

  void startResendTimer() {
    _resendTimer?.cancel();
    _resendWaitSeconds = 60;
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _resendWaitSeconds--);
      if (_resendWaitSeconds <= 0) {
        canResend = true;
        _resendTimer?.cancel();
      }
    });
  }

 Future<void> validateOtp() async {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  // 🔴 OTP expired
  if (_otpExpireSeconds <= 0 || receivedOtp == null) {
    otpController.clear();                         // <-- clear
    FocusScope.of(context).requestFocus(_pinFocus); // optional
    showError(localization.translate("OTP expired. Please resend."));
    return;
  }

  // 🟢 OTP correct
  if (otpController.text.trim() == receivedOtp) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await savePhoneNumber(mobileController.text.trim());
    await _fetchUserDetails();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CreateMpinScreen5()),
    );
  } else {
    // ❌ OTP invalid
    otpController.clear();                         // <-- clear
    FocusScope.of(context).requestFocus(_pinFocus); // optional
    showError(localization.translate("Invalid OTP"));
  }
}

void showError( String message) {
  double fontSize = MediaQuery.of(context).size.width * 0.03;
  fontSize = fontSize.clamp(12, 24);

  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
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
              child: Text(
                localization.translate(message),
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


  Future<bool> hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> savePhoneNumber(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhoneNumber', mobileNumber);
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _resendTimer?.cancel();
    mobileController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final localization = Provider.of<LocalizationProvider>(context);
    return WillPopScope(
       onWillPop: () async {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen1()),
        (Route<dynamic> route) => false,
      );
      return false; // Prevent default back action
    },
      child: Scaffold(
        appBar: AppBar(title: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
           localization.translate("Login with OTP"),
            style: TextStyle(color: Colors.white),),
        ),
        backgroundColor: AppColors.blue,
        leading: BackButton(color: Colors.white,
        onPressed: () {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => LoginScreen1(),
            )
          );
        },
        ),
        ),
      
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
          
          
                Image.asset('assets/images/otp.4.jpg'),
          
                SizedBox(height: 20,),
                TextFormField(
                  
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 
                  
                  localization.translate("Mobile Number"),
                  counterText: '',
                  prefixIcon: Icon(Icons.phone_android)
                  ),
                  maxLength: 10,
                ),
          
          
                SizedBox(height: 20,),

                
            SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: (isLoading || isOtpSent) ? null : verifyMobileNumber,
    style: ElevatedButton.styleFrom(
      backgroundColor: (isLoading || isOtpSent)
          ? Colors.grey
          : AppColors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    child: isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
        : Text(
            localization.translate("Get OTP"),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
  ),
),

                
                if (isOtpSent) ...[
                  SizedBox(height: 20),


             TextFormField(
  controller: otpController,
  focusNode: _pinFocus,
  keyboardType: TextInputType.number,
  maxLength: 6,
  autofillHints: const [AutofillHints.oneTimeCode],
  
   style: TextStyle(
      fontSize: 18,
      letterSpacing: 32, // for spaced digits look
      fontWeight: FontWeight.bold,
    ),
  textAlign: TextAlign.center, // Center the OTP digits
    decoration: InputDecoration(
      counterText: '',
      hintText: localization.translate('Enter OTP'),
      hintStyle: TextStyle(letterSpacing: 2,fontSize: 13),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color:AppColors.blue,
          width: 2,
        ),
      ),
    ),
  onChanged: (value) {
    if (value.length == 6) {
      validateOtp(); // Call your OTP validation function
    }
  },
  onFieldSubmitted: (_) => validateOtp(),
),
                TextButton(
  onPressed: canResend ? () => sendOtp(mobileController.text.trim()) : null,
  child: Text(
    canResend ? 'Resend OTP' : 'Resend OTP in $_resendWaitSeconds s',
    style: TextStyle(
      color: canResend ? Colors.blue : Colors.grey,
    ),
  ),
),



              /*
                  SizedBox(
                    
                    width: double.infinity,
                    child: ElevatedButton(
                      
                      onPressed: validateOtp,
                      child: Text(
                        localization.translate("Verify OTP"),
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                    ),
                  ),

                  */
                 // Text("OTP expires in ${_otpExpireSeconds ~/ 60}:${(_otpExpireSeconds % 60).toString().padLeft(2, '0')}")
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _fetchUserDetails() async {
  String apiUrl = "$baseUrl/get_reg_account_details.php";  // "https://vmrdemos.com/csc_scheme/get_reg_account_details.php"

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // ✅ Ensures latest data is fetched
    String? mobileNumber = prefs.getString('userPhoneNumber');

    if (mobileNumber!.length != 10) {
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



}
