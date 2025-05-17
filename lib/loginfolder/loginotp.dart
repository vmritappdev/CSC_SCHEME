// Full code for a smooth and secure Login OTP screen in Flutter using Pinput
// Features:
// ✅ Fast OTP delivery
// ✅ 6-digit OTP validation
// ✅ Error popup for wrong OTP
// ✅ 10-min OTP expiry
// ✅ Resend disables old OTP and clears fields

import 'dart:async';
import 'dart:convert';

import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginOtpScreen extends StatefulWidget {
  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isOtpSent = false;
  bool isLoading = false;
  String? receivedOtp;
  Timer? _otpTimer;
  Timer? _resendTimer;
  int _otpExpireSeconds = 600; // 10 minutes
  int _resendWaitSeconds = 30;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> verifyMobileNumber() async {
    String mobile = mobileController.text.trim();
    if (mobile.length != 10) {
      showError("Please enter a valid 10-digit mobile number");
      return;
    }

    if (!await hasInternet()) {
      showError("No internet connection");
      return;
    }




    

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse("https://vmrdemos.com/csc_scheme/mobile_verification.php"),
      body: {'mobile_no': mobile},
    );

    final data = json.decode(response.body);
    if (data['login'] == 'SUCCESS') {
      await sendOtp(mobile);
    } else {
      showError("No Recods On This Number");
    }
    setState(() => isLoading = false);
  }

 Future<void> sendOtp(String mobile) async {
  final response = await http.post(
    Uri.parse("https://vmrdemos.com/csc_scheme/otp.php"),
    body: {'mobile_no': mobile},
  );

  final data = json.decode(response.body);
  if (response.statusCode == 200 && data['otp'] != null) {
    receivedOtp = data['otp'].toString();

    await savePhoneNumber(mobile);
    await _fetchUserDetails();

    setState(() {
      isOtpSent = true;
      canResend = false;
      otpController.clear();
    });

    startOtpTimer();
    startResendTimer();
  } else {
    showError("Failed to send OTP");
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
    _resendWaitSeconds = 30;
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _resendWaitSeconds--);
      if (_resendWaitSeconds <= 0) {
        canResend = true;
        _resendTimer?.cancel();
      }
    });
  }

 Future<void> validateOtp() async {
  if (_otpExpireSeconds <= 0 || receivedOtp == null) {
    showError("OTP expired. Please resend.");
    return;
  }

  if (otpController.text.trim() == receivedOtp) {
    // ✅ OTP Verified – Navigate to HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme())),
    );
  } else {
    showError("Invalid OTP");
  }
}

  void showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("OK"))],
      ),
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
    return WillPopScope(
       onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen1()),
      );
      return false; // Prevent default back action
    },
      child: Scaffold(
        appBar: AppBar(title: Text("Login with OTP"),
        leading: BackButton(color: Colors.black,
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => LoginScreen1(),
            )
          );
        },
        ),
        ),
      
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Mobile Number",counterText: ''),
                maxLength: 10,
              ),
            SizedBox(
        width: double.infinity,
        child: ElevatedButton(
      onPressed: (isLoading || isOtpSent) ? null : verifyMobileNumber,
      style: ElevatedButton.styleFrom(
        backgroundColor: (isLoading || isOtpSent)
            ? Colors.grey
            : Theme.of(context).primaryColor,
      ),
      child: Text(
        "Get OTP",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
        ),
      ),
      
              if (isOtpSent) ...[
                SizedBox(height: 20),
                Pinput(
                  length: 6,
                  controller: otpController,
                  onSubmitted: (_) => validateOtp(),
                ),
                TextButton(
                  onPressed: canResend ? () => sendOtp(mobileController.text.trim()) : null,
                  child: Text("Resend OTP in ${_resendWaitSeconds}s"),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: validateOtp,
                    child: Text("Verify OTP",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                  ),
                ),
                Text("OTP expires in ${_otpExpireSeconds ~/ 60}:${(_otpExpireSeconds % 60).toString().padLeft(2, '0')}")
              ]
            ],
          ),
        ),
      ),
    );
  }



  Future<void> _fetchUserDetails() async {
  const String apiUrl = "$baseUrl/get_reg_account_details.php";  // "https://vmrdemos.com/csc_scheme/get_reg_account_details.php"

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
