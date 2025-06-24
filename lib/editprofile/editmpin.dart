

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _pinFocusNode = FocusNode(); 
  
    


  int _timerSeconds = 60;
  String? receivedOtp;
  DateTime? otpSentTime;

  Timer? _resendTimer;
  Timer? _otpExpireTimer;
// 10 minutes

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
          _timerSeconds = 60;
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
      final localization = Provider.of<LocalizationProvider>(context,listen: false);
    _otpExpireTimer?.cancel();
    _otpExpireTimer = Timer(const Duration(minutes: 10), () {
      setState(() => _isOtpExpired = true);
      _showInvalidOTPDialog(localization.translate("⏰ OTP expired. Please resend a new OTP."));
    });
  }

  void _checkOtpMatch() {
    setState(() {
      _isOtpCorrect = _controllerOtp.text == receivedOtp;
    });
  }

  void _onVerifyOtp() {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  if (_isOtpExpired) {
    _controllerOtp.clear();            
    FocusScope.of(context).requestFocus(_pinFocusNode); 
    _showInvalidOTPDialog(
      localization.translate("⏰ OTP expired. Please resend a new OTP."),
    );
    return;
  }

  if (_isOtpCorrect) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateMpinScreen5()),
    );
  } else {
    _controllerOtp.clear();            
    FocusScope.of(context).requestFocus(_pinFocusNode); 
    _showInvalidOTPDialog(
      localization.translate("❌ Invalid OTP. Please try again."),
    );
  }
}
void _onResendOtp() {
    Provider.of<LocalizationProvider>(context,listen: false);
  if (_isResendAvailable) {
    setState(() {
      _isResendAvailable = false;
      _timerSeconds = 60;

      // ✅ Clear previous OTP and entered pin
      receivedOtp = null;
      _controllerOtp.clear();
      _isOtpCorrect = false;
    });
    fetchOtpApi();
  }
}

  void _showInvalidOTPDialog(String message) {
      Provider.of<LocalizationProvider>(context,listen: false);
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
    final localization = Provider.of<LocalizationProvider>(context,listen: false);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
        
              Image.asset('assets/images/otp.4.jpg'),
              const SizedBox(height: 10),
              Text(
                localization.translate('If you want to change your MPIN, you need to verify your Mobile Number or Email ID.'),
                style: GoogleFonts.roboto(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                readOnly: true,
                controller: _controllerMobileNumber,
                decoration:  InputDecoration(
                  labelText: localization.translate('Mobile Number'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_isOtpVisible) ...[
              TextFormField(
  controller: _controllerOtp,
  keyboardType: TextInputType.number,
  maxLength: 6,
  autofillHints: const [AutofillHints.oneTimeCode],
   textAlign: TextAlign.center,
  inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(fontSize: 13, letterSpacing: 20),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: localization.translate('Enter OTP'),hintStyle: TextStyle(letterSpacing: 10),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color.fromRGBO(2, 5, 67, 1), width: 2),
                      ),
                    ),
 
  onChanged: (value) {
    if (value.length == 6) {
      print("OTP entered: $value");
     
    }
  },
),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onVerifyOtp,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(2, 5, 62, 1)),
                    child:  Text(
                      localization.translate("Verify"),
                    style: TextStyle(color: Colors.white),),
                  ),
                ),
                const SizedBox(height: 8),
                if (!_isResendAvailable)
                  Text("${localization.translate("Resend OTP in")} $_timerSeconds ${localization.translate("seconds")}"),
                if (_isResendAvailable)
                  TextButton(onPressed: _onResendOtp, child:  Text(localization.translate("Resend OTP"),
                  style: TextStyle(color: Color.fromARGB(255, 5, 23, 38),fontWeight: FontWeight.bold),)),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSendOtpDisabled ? null : fetchOtpApi,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(2, 5, 62, 1)),
                    child:  Text(
                     localization.translate("Send OTP"),
                    style: TextStyle(color: Colors.white),),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
