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
// Control loading screen

  int timerSeconds = 60;
  bool _isResendAvailable = false;

  /// No need for lists now, so remove focus traversal logic

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  
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
    phoneNumber = prefs.getString('userPhoneNumber') ?? "";
  }

  String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 10) return phoneNumber;
    return 'XXXXXX${phoneNumber.substring(phoneNumber.length - 4)}';
  }

  void _showInvalidOTPDialog(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    Provider.of<LocalizationProvider>(context, listen: false);

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
      isOtpMessageReceived = false;
    });

    final responseData = await fetchOtpFromApiHelper();
    if (responseData != null && responseData['otp'] != null) {
      setState(() {
        receivedOtp = responseData['otp'].toString();
        otpReceivedTime = DateTime.now();
        isOtpMessageReceived = true;
        _isResendAvailable = false;
        timerSeconds = 60;
      });
      _startResendTimer();
    } else {
    }
  }




  showProceedBottomSheet(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, -15),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium icon with subtle accent
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10194E).withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10194E).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),

                      )
                    ],
                  ),
                  child: const Icon(Icons.verified_outlined, 
                    size: 36, 
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // Elegant typography
                Text(
                  localization.translate('OTP Verified!'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: -0.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  localization.translate("Click 'I Have Proceed' to continue."),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Professional button with subtle effects
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      navigateToNextScreen();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10194E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                    ),
                    child: Text(
                      localization.translate('Proceed'),
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                
                // Additional legal text for professionalism
                const SizedBox(height: 20),
                Text(
                  localization.translate('Secured by AES-256 encryption'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 12,
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

void showStylishSuccessSheet(BuildContext context) {
  final localization = context.read<LocalizationProvider>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Bottom Sheet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 72, 24, 32), // top: 72 for space under icon
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verification Successful!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localization.translate("Your OTP has been verified successfully. You may now proceed."),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          navigateToNextScreen();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          localization.translate('Continue'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                   
                  ],
                ),
              ),

              // Floating Success Icon (No margin, use Positioned)
              Positioned(
                top: -25, // move up outside the sheet
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_circle_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
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
    final localization = Provider.of<LocalizationProvider>(context,listen: false);
    final enteredOtp = otpController.text.trim();
    final now = DateTime.now();

    if (enteredOtp.length < 6) {
      _showInvalidOTPDialog(localization.translate("Please enter valid 6 digits OTP"));
      otpController.clear();
      FocusScope.of(context).requestFocus(FocusNode());
      return;
    }

    if (now.difference(otpReceivedTime).inMinutes >= 10) {
      _showInvalidOTPDialog(localization.translate("OTP expired, please resend"));
      otpController.clear();
      return;
    }

    if (enteredOtp == receivedOtp) {
      showStylishSuccessSheet(context);
    } else {
      _showInvalidOTPDialog(localization.translate("Incorrect OTP, please try again"));
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
        timerSeconds = 60;
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
    text: "${localization.translate("Verification Code Sent to")} +${maskPhoneNumber(phoneNumber)}",
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
                Text(localization.translate("Enter OTP Here")),
                SizedBox(height: screenHeight * 0.02),

                /// -------------------- SINGLE OTP TEXTFIELD -------------------
                SizedBox(
                  width: screenWidth * 0.8,
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
                      hintText: localization.translate('Enter OTP'),hintStyle: TextStyle(letterSpacing: 8),
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
