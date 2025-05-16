// Full updated Flutter code with smooth OTP handling, validation, timer, and user experience improvements

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/mpinscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';

class EditMPINScreen extends StatefulWidget {
  const EditMPINScreen({super.key});

  @override
  State<EditMPINScreen> createState() => _EditMPINScreenState();
}

class _EditMPINScreenState extends State<EditMPINScreen> {
  final TextEditingController _controllerMobileNumber = TextEditingController();
  final TextEditingController _controllerOtp = TextEditingController();

  bool _isOtpVisible = false;
  bool _isResendAvailable = false;
  bool _isOtpCorrect = false;
  bool _isOtpExpired = false;
  bool _isSendOtpDisabled = false;

  int _timerSeconds = 30;
  String? receivedOtp;
  DateTime? otpSentTime;

  Timer? _resendTimer;
  Timer? _otpExpireTimer;

  @override
  void initState() {
    super.initState();
    _controllerOtp.addListener(_checkOtpMatch);
    loadUserDetails();
  }

  @override
  void dispose() {
    _controllerMobileNumber.dispose();
    _controllerOtp.dispose();
    _resendTimer?.cancel();
    _otpExpireTimer?.cancel();
    super.dispose();
  }

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _controllerMobileNumber.text = prefs.getString('phoneNumber') ?? '';
    });
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<void> fetchOtpApi() async {
    if (!await checkInternet()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ErrorScreen()));
      return;
    }

    String mobileNumber = _controllerMobileNumber.text;
    if (mobileNumber.isEmpty || mobileNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<LocalizationProvider>().translate("Enter a valid mobile number or email ID")),
      ));
      return;
    }

    setState(() => _isSendOtpDisabled = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp.php'),
        body: {'mobile_no': mobileNumber},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          receivedOtp = responseData['otp'].toString();
           _controllerOtp.clear();
            _isOtpCorrect = false;  
           _isOtpVisible = true;
          _isOtpVisible = true;
          _isResendAvailable = false;
          _timerSeconds = 30;
          otpSentTime = DateTime.now();
          _isOtpExpired = false;
        });

        _startResendTimer();
        _startOtpExpiryTimer();

        print("✅ OTP Received: $receivedOtp");
      } else {
        print("🔴 API Error: ${response.statusCode}");
        _isSendOtpDisabled = false;
      }
    } catch (e) {
      print("🔴 API Call Failed: $e");
      _isSendOtpDisabled = false;
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        setState(() => _isResendAvailable = true);
        timer.cancel();
      }
    });
  }

  void _startOtpExpiryTimer() {
    _otpExpireTimer?.cancel();
    _otpExpireTimer = Timer(const Duration(minutes: 10), () {
      setState(() => _isOtpExpired = true);
      _showInvalidOTPDialog("⏰ OTP expired. Please resend a new OTP.");
    });
  }

  void _checkOtpMatch() {
    setState(() {
      _isOtpCorrect = _controllerOtp.text == receivedOtp;
    });
  }

  void _onVerifyOtp() {
    if (_isOtpExpired) {
      _showInvalidOTPDialog("⏰ OTP expired. Please resend a new OTP.");
      return;
    }
    if (_isOtpCorrect) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CreateMpinScreen5()));
    } else {
      _showInvalidOTPDialog("❌ Invalid OTP. Please try again.");
    }
  }

void _onResendOtp() {
  if (_isResendAvailable) {
    setState(() {
      _isResendAvailable = false;
      _timerSeconds = 30;

      // ✅ Clear previous OTP and entered pin
      receivedOtp = null;
      _controllerOtp.clear();
      _isOtpCorrect = false;
    });
    fetchOtpApi();
  }
}

  void _showInvalidOTPDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                style: GoogleFonts.lato(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              color: const Color.fromRGBO(2, 5, 62, 1),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
        centerTitle: true,
        title: Column(
          children: [
            Image.asset('assets/images/csc2.png', color: Colors.white, height: 40),
            Text(localization.translate('Jewellers'),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic))
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              localization.translate('If you want to change your MPIN, you need to verify your Mobile Number or Email ID.'),
              style: GoogleFonts.roboto(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              readOnly: true,
              controller: _controllerMobileNumber,
              decoration: const InputDecoration(
                labelText: 'Mobile Number*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isOtpVisible) ...[
              Pinput(
                length: 6,
                controller: _controllerOtp,
                androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                autofocus: true,
                defaultPinTheme: PinTheme(
                  height: 50,
                  width: 45,
                  textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onVerifyOtp,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(2, 5, 62, 1)),
                  child: const Text("Verify",style: TextStyle(color: Colors.white),),
                ),
              ),
              const SizedBox(height: 8),
              if (!_isResendAvailable)
                Text("Resend OTP in $_timerSeconds sec", style: const TextStyle(color: Colors.grey)),
              if (_isResendAvailable)
                TextButton(onPressed: _onResendOtp, child: const Text("Resend OTP",style: TextStyle(color: Color.fromARGB(255, 5, 23, 38),fontWeight: FontWeight.bold),)),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSendOtpDisabled ? null : fetchOtpApi,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(2, 5, 62, 1)),
                  child: const Text("Send OTP",style: TextStyle(color: Colors.white),),
                ),
              )
          ],
        ),
      ),
    );
  }
}
