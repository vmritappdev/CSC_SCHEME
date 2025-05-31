import 'dart:async';

import 'package:csc/api_services.dart/otp_api.dart';
import 'package:csc/chaingedscreens.dart/chainge mobile .dart';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/mpinscreen.dart';
import 'package:csc/utillity/check internet.dart';

import 'package:csc/localization/localizationpro.dart';
import 'package:csc/registationfolder/create account.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      home: const OtpScreen(),
    ),
  );
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  /// Single controller instead of 6 controllers
  final TextEditingController otpController = TextEditingController();

  String receivedOtp = ""; // API response lo OTP store cheyyali
  bool isLoading = true;

  late SharedPreferences prefs;
  String phoneNumber = '';

  bool isOtpReceived = false;
  bool isOtpMessageReceived = false; // ✅ OTP Message వచ్చిన తర్వాత Auto‑Fill/Manual Entry కోసం

  DateTime otpReceivedTime = DateTime.now();
  bool _isLoading = false; // Control loading screen

  int timerSeconds = 30;
  bool _isResendAvailable = false;
  bool _isOtpVisible = false;

  /// No need for lists now, so remove focus traversal logic

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  /// OTP Auto‑Fill SMS vachinappudu Ee Method Call Avutundi
  void codeUpdated(String? otpCode) {
    if (otpCode != null && otpCode.isNotEmpty) {
      setState(() {
        otpController.text = otpCode; // OTP Auto‑Fill
      });
      debugPrint("OTP Received: $otpCode");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOtpFromApi();
    startTimer();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber') ?? "";
  }

  String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 10) return phoneNumber;
    return 'XXXXXX${phoneNumber.substring(phoneNumber.length - 4)}';
  }

  void _showInvalidOTPDialog(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localization = Provider.of<LocalizationProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Icon(Icons.error, color: Colors.red, size: screenWidth * 0.1),
              SizedBox(height: screenHeight * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  message,
                  style: GoogleFonts.lato(fontSize: screenWidth * 0.04),
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
                      fontSize: screenWidth * 0.045,
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

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (timerSeconds > 0) {
        setState(() {
          timerSeconds--;
        });
        _startResendTimer();
      } else {
        setState(() {
          _isResendAvailable = true;
        });
      }
    });
  }

  Future<void> fetchOtpFromApi() async {
    if (!await checkInternet()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ErrorScreen()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      isOtpMessageReceived = false;
    });

    final responseData = await fetchOtpFromApiHelper();
    if (responseData != null && responseData['otp'] != null) {
      setState(() {
        receivedOtp = responseData['otp'].toString();
        otpReceivedTime = DateTime.now();
        _isLoading = false;
        _isOtpVisible = true;
        isOtpMessageReceived = true;
        _isResendAvailable = false;
        timerSeconds = 30;
      });
      _startResendTimer();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void showProceedBottomSheet(BuildContext context) {
    final localization = context.read<LocalizationProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -4),
                    blurRadius: 16,
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color.fromARGB(255, 16, 13, 72), Color.fromARGB(255, 16, 13, 72)]),
                    ),
                    child: const Icon(Icons.check, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localization.translate('OTP Verified!'),
                    style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization.translate("Click 'I Have Proceed' to continue."),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        navigateToNextScreen();
                      },
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color.fromARGB(255, 16, 13, 72), Color.fromARGB(255, 16, 13, 72)]),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            localization.translate('Proceed'),
                            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CreateMpinScreen5()),
    );
  }

  void checkOtp() {
    final enteredOtp = otpController.text.trim();
    final now = DateTime.now();

    if (enteredOtp.length < 6) {
      _showInvalidOTPDialog("Please enter valid 6 digits OTP");
      otpController.clear();
      FocusScope.of(context).requestFocus(FocusNode());
      return;
    }

    if (now.difference(otpReceivedTime).inMinutes >= 10) {
      _showInvalidOTPDialog("OTP expired, please resend");
      otpController.clear();
      return;
    }

    if (enteredOtp == receivedOtp) {
      showProceedBottomSheet(context);
    } else {
      _showInvalidOTPDialog("Incorrect OTP, please try again");
      otpController.clear();
    }
  }

  String formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          timerSeconds--;
        });
      }
    });
  }

  void _onResendOtp() {
    if (_isResendAvailable) {
      setState(() {
        _isResendAvailable = false;
        timerSeconds = 30;
        otpController.clear();
        FocusScope.of(context).unfocus();
      });

      fetchOtpFromApi();
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localization = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(3, 4, 22, 1),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          localization.translate("OTP Verification"),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CurvedImageScreen2()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                RichText(
                  text: TextSpan(
                    text: localization.translate(
                      "Verification Code Sent to +${maskPhoneNumber(phoneNumber)}",
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: screenHeight * 0.02,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localization.translate('Change Phone Number'),
                      style: GoogleFonts.lato(
                        color: Colors.red,
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MobileScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 21, color: Colors.red),
                    ),
                  ],
                ),
                Text(localization.translate("Enter OTP")),
                SizedBox(height: screenHeight * 0.02),

                /// -------------------- SINGLE OTP TEXTFIELD -------------------
                SizedBox(
                  width: screenWidth * 0.7,
                  child: TextField(
                    controller: otpController,
                    enabled: isOtpMessageReceived,
                    keyboardType: TextInputType.number,
                    
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(fontSize: 13, letterSpacing: 20),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Enter OTP',
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color.fromRGBO(2, 5, 67, 1), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                SizedBox(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.06,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(2, 5, 62, 1),
                          Color.fromRGBO(78, 67, 138, 1),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: checkOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        localization.translate("Verify OTP"),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.02,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isResendAvailable
                          ? localization.translate("Didn't receive the OTP?")
                          : "${localization.translate("Resend OTP in")} $timerSeconds ${localization.translate("seconds")}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (_isResendAvailable)
                      TextButton(
                        onPressed: _onResendOtp,
                        child: Text(
                          localization.translate('Resend'),
                          style: const TextStyle(
                            color: Color.fromRGBO(6, 8, 34, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
