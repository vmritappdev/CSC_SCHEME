
import 'package:csc/loginfolder/mpinscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: ForgotScreen(),
    ),
  );
}

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final TextEditingController _controllerMobileNumber = TextEditingController();
  final TextEditingController _controllerOtp = TextEditingController();

  bool _isOtpVisible = false;
  bool _isResendAvailable = false;
  bool _isVerifyEnabled = false;
  int _timerSeconds = 30;
  String receivedOtp = "";
  DateTime? otpReceivedTime; // ✅ OTP timestamp

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
          shape: RoundedRectangleBorder(),
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
                  color: Color.fromRGBO(2, 5, 62, 1),
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
    });

    String mobileNumber = _controllerMobileNumber.text.trim();
    final localization = Provider.of<LocalizationProvider>(context, listen: false);

    if (mobileNumber.isEmpty || mobileNumber.length != 10) {
      _showErrorPopup(localization.translate("Enter a valid 10-digit mobile number"));
      setState(() {
        isVerifyButtonDisabled = false;
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
        });
        fetchOtpApi();
      } else {
        _showErrorPopup(localization.translate("This mobile number is not found."));
        setState(() {
          isVerifyButtonDisabled = false;
        });
      }
    } catch (e) {
      print("❌ API Exception: $e");
      _showErrorPopup("Error: $e");
      setState(() {
        isVerifyButtonDisabled = false;
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

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CreateMpinScreen5()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset('assets/images/csc2.png', height: 90),
            const Text(
              'CSCJEWELLERYS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color.fromRGBO(43, 49, 101, 1)),
            ),
            const SizedBox(height: 40),

            TextFormField(
                      inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
              maxLength: 10,
              controller: _controllerMobileNumber,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                counterText: '',
                hintText: "Mobile Number*",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(2, 5, 62, 1)),
                onPressed: isVerifyButtonDisabled ? null : verifyMobileNumber,
                child: const Text("Verify Mobile Number", style: TextStyle(color: Colors.white)),
              ),
            ),

            if (_isOtpVisible) ...[
              const SizedBox(height: 20),

              Pinput(
                controller: _controllerOtp,
                length: 6,
                onChanged: (pin) {
                  _checkOtpMatch();
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isResendAvailable
                      ? "Didn't receive the OTP?"
                      : "Resend OTP in $_timerSeconds seconds"),
                  if (_isResendAvailable)
                    TextButton(
                      onPressed: fetchOtpApi,
                      child: const Text("Resend", style: TextStyle(color: Color.fromRGBO(2, 5, 62, 1))),
                    ),
                ],
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _isVerifyEnabled ? _checkOtpMatch : null,
                  child: const Text("✅ Verify OTP", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

