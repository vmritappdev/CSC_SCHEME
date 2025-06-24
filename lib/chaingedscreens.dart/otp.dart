import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:csc/api_services.dart/otp_api.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/loginfolder/mpinscreen.dart';
import 'package:csc/utillity/check%20internet.dart';

class OtpScreen1 extends StatefulWidget {
  const OtpScreen1({super.key});

  @override
  _OtpScreen1State createState() => _OtpScreen1State();
}

class _OtpScreen1State extends State<OtpScreen1> {
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  late SharedPreferences prefs;
  String phoneNumber = '';
  String receivedOtp = '';
  bool isOtpMessageReceived = false;
  bool _isResendAvailable = false;
  bool _isLoading = false;
  int timerSeconds = 30;
  DateTime otpReceivedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _fetchOtpFromApi();
    _startResendTimer();
  }

  Future<void> _loadUserDetails() async {
    prefs = await SharedPreferences.getInstance();
    setState(() => phoneNumber = prefs.getString('phoneNumber') ?? "");
  }

  Future<void> _fetchOtpFromApi() async {
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
        isOtpMessageReceived = true;
        _isResendAvailable = false;
        timerSeconds = 30;
      });
      _startResendTimer();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (timerSeconds > 0) {
        setState(() => timerSeconds--);
        _startResendTimer();
      } else {
        setState(() => _isResendAvailable = true);
      }
    });
  }

  void _showInvalidOTPDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final localization = Provider.of<LocalizationProvider>(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localization.translate("OK")),
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkOtp() {
    final enteredOtp = otpControllers.map((e) => e.text).join();
    final now = DateTime.now();

    if (enteredOtp.length < 6) {
      _showInvalidOTPDialog("Please enter valid 6 digits OTP");
      return;
    }

    if (now.difference(otpReceivedTime).inMinutes >= 10) {
      _showInvalidOTPDialog("OTP expired, please resend");
      otpControllers.forEach((controller) => controller.clear());
      focusNodes.first.requestFocus();
      return;
    }

    if (enteredOtp == receivedOtp) {
      _showVerifiedBottomSheet();
    } else {
      _showInvalidOTPDialog("Incorrect OTP, please try again");
    }
  }

  void _showVerifiedBottomSheet() {
    final localization = Provider.of<LocalizationProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localization.translate("✅ OTP Verified!"),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(localization.translate("Click 'I Have Proceed' to continue.")),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToNextScreen(),
                child: Text(localization.translate("I Have Proceed")),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CreateMpinScreen5()),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 40,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: TextField(
            controller: otpControllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
            decoration: const InputDecoration(counterText: ''),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(localization.translate("Enter OTP"))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localization.translate("OTP sent to") + " ${phoneNumber.replaceRange(0, 6, "XXXXXX")}",
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  _buildOtpFields(),
                  const SizedBox(height: 20),
                  Text(
                    _isResendAvailable
                        ? localization.translate("Didn't receive OTP?")
                        : '${localization.translate("Resend available in")} $timerSeconds sec',
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isResendAvailable ? _fetchOtpFromApi : null,
                    child: Text(localization.translate("Resend OTP")),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkOtp,
                    child: Text(localization.translate("Verify OTP")),
                  ),
                ],
              ),
            ),
    );
  }
}