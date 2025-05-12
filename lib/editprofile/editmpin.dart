import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/mpinscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
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
      home: const EditMPINScreen(),
    ),
  );
}

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
  int _timerSeconds = 30;
  String? receivedOtp;
  DateTime? otpSentTime;
bool _isOtpExpired = false;



   String phoneNumber = '';

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
    super.dispose();
  }


   Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      
      _controllerMobileNumber.text = prefs.getString('phoneNumber') ?? '';
      
    });
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
 

Future<bool> checkInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  
  // **Extra Check: Mobile lo net unda leda ani verify chestam**
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }

  return false;
}
  






 bool _isSendOtpDisabled = false;

Future<void> fetchOtpApi() async {
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
    //  _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
    const ErrorScreen();
      return;
    }
  String mobileNumber = _controllerMobileNumber.text;
  if (mobileNumber.isEmpty || mobileNumber.length < 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.read<LocalizationProvider>().translate("Enter a valid mobile number or email ID"))),
    );
    return;
  }

  setState(() {
    _isSendOtpDisabled = true; // Disable the button after click
  });

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/otp.php'),
      body: {'mobile_no': mobileNumber},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      setState(() {
        receivedOtp = responseData['otp'].toString();
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
    }
  } catch (e) {
    print("🔴 API Call Failed: $e");
    setState(() {
      _isSendOtpDisabled = false; // Re-enable the button if API fails
    });
  }
}

void _startOtpExpiryTimer() {
  Future.delayed(const Duration(minutes: 10), () {
    if (mounted && otpSentTime != null) {
      final now = DateTime.now();
      final difference = now.difference(otpSentTime!).inMinutes;
      if (difference >= 10 && !_isOtpExpired) {
        setState(() {
          _isOtpExpired = true;
        });
        _showInvalidOTPDialog("⏰ OTP expired. Please resend a new OTP.");
      }
    }
  });
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateMpinScreen5()),
      );
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  

 void _onResendOtp() {
  if (_isResendAvailable) {
    setState(() {
      _isResendAvailable = false; // Resend తర్వాత మళ్లీ టైమర్ రీసెట్ చేయాలి
      _timerSeconds = 30; // టైమర్ మళ్లీ 30 సెకన్లకి సెట్ చేయాలి
    });
    fetchOtpApi(); // కొత్త OTP కోసం API కాల్
  }
}


  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
 double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
   
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 90,
        backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
        centerTitle: true,
        title: Column(
          children: [
           Image.asset(
  'assets/images/csc2.png',
  color: Colors.white,
  height: MediaQuery.of(context).size.height * 0.06, // 8% of screen height
  width: MediaQuery.of(context).size.width * 0.19,  // 13% of screen width
),

            Text(
              localization.translate('Jewellers'),
              style:  TextStyle(
                color: Colors.white,
               fontSize: MediaQuery.of(context).size.width * 0.035, // Scales with screen width

                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Scales padding dynamically

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),

              Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025),

                child: Text(
                  localization.translate('If you want to change your MPIN, you need to verify your Mobile Number or Email ID.'),
                  style: GoogleFonts.roboto(textStyle: TextStyle(color: Colors.grey[500])),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              SizedBox(
               height: MediaQuery.of(context).size.height * 0.05,

                child: TextFormField(
                  readOnly: true,
                  controller: _controllerMobileNumber,
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: localization.translate('Mobile Number*'),
                    labelStyle:  TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,
),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),


           SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            SizedBox(
  width: double.infinity,
  height: MediaQuery.of(context).size.height * 0.055,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(2, 5, 62, 1)),
    onPressed: (_isSendOtpDisabled || _isOtpVisible) 
        ? null 
        : fetchOtpApi,
    child: Text(
      localization.translate('Send OTP'),
      style: TextStyle(
        color: Colors.white,
        fontSize: MediaQuery.of(context).size.width * 0.05,
      ),
    ),
  ),
),

              if (_isOtpVisible) ...[
               SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                Text(localization.translate('Enter the 6-digit OTP sent to your number'), style: TextStyle(color: Colors.grey[500])),
               SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              Pinput(
  length: 6,
  controller: _controllerOtp,
  keyboardType: TextInputType.number,
  autofocus: true, // ఫీల్డ్ ఓపెన్ అవ్వగానే ఫోకస్
  showCursor: true, // కర్సర్ చూపించాలి
  pinAnimationType: PinAnimationType.slide, // Smooth animation
  defaultPinTheme: PinTheme(
    width: 50,
    height: 50,
    textStyle: const TextStyle(fontSize: 20, color: Colors.black),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey), // బోర్డర్ కలర్
      borderRadius: BorderRadius.circular(10), // గుండ్రంగా బోర్డర్
    ),
  ),
  focusedPinTheme: PinTheme(
    width: 50,
    height: 50,
    textStyle: const TextStyle(fontSize: 20, color: Colors.black),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue), // Focus లో బ్లూ కలర్
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  submittedPinTheme: PinTheme(
    width: 50,
    height: 50,
    textStyle: const TextStyle(fontSize: 20, color: Colors.black),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 11, 1, 46)), // Enter చేసిన తర్వాత గ్రీన్ కలర్
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  errorPinTheme: PinTheme(
    width: 50,
    height: 50,
    textStyle: const TextStyle(fontSize: 20, color: Colors.red),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.red), // Error ayithe Red color
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  onChanged: (value) {
    print('OTP: $value');
    _checkOtpMatch(); // OTP ఎంటర్ అవుతున్నప్పుడు చెక్ చేయడం
  },
),

               SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      _isResendAvailable
          ? "${localization.translate("Didn't receive the OTP?")} "
          : (_timerSeconds == 1
              ? localization.translate("Resend in 1 second") 
              : localization.translate("Resend OTP in $_timerSeconds seconds")),
      style: const TextStyle(color: Colors.grey),
    ),
    if (_isResendAvailable)
      TextButton(
        onPressed: _onResendOtp,
        child: Text(
          localization.translate('Resend'),
          style: const TextStyle(color: Color.fromRGBO(4, 6, 30, 1),fontWeight: FontWeight.bold),
        ),
      ),
  ],
),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isOtpCorrect ? _onVerifyOtp : null, // OTP correct ayithe matrame enable
                    child: Text(localization.translate('Verify OTP'), style:  TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.05,
)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
