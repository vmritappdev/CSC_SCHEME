import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/api_services.dart/otp_api.dart';
import 'package:csc/chaingedscreens.dart/chainge%20mobile%20.dart';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/loginfolder/mpinscreen.dart';
import 'package:csc/utillity/check%20internet.dart';

import 'package:csc/localization/localizationpro.dart';
import 'package:csc/registationfolder/create%20account.dart';


import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home:OtpScreen(),
    ),
  );
}

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  
  String receivedOtp = ""; // API response lo OTP store cheyyali
   bool isLoading = true;

  late SharedPreferences prefs;
String phoneNumber = '';
  
  bool isOtpReceived = false; 
   bool isOtpMessageReceived = false; // ✅ OTP Message వచ్చిన తర్వాత Auto-Fill/Manual Entry కోసం

  // ✅ **User OTP enter chesinaka API call avvali**

  DateTime otpReceivedTime = DateTime.now();
 bool _isLoading = false; // Control loading screen


int timerSeconds = 30;
 bool _isResendAvailable = false;
   bool _isOtpVisible = false;
  
  bool _isOtpCorrect = false;

  
   bool isOtpSent = false;

    TextEditingController otpController = TextEditingController();

   




  @override
  void dispose() {
   // SmsAutoFill().unregisterListener(); // Cleanup
    super.dispose();
  }


   // ✅ **OTP Auto-Fill SMS vachinappudu Ee Method Call Avutundi**
  @override
  void codeUpdated(String? otpCode) {  // `codeUpdated` correct format lo use cheyyi
    if (otpCode != null && otpCode.isNotEmpty) {
      setState(() {
        otpController.text = otpCode; // OTP Auto-Fill
      });
      print("OTP Received: $otpCode");
    }
  }





  
 @override
  void initState() {
    super.initState();
    fetchOtpFromApi();
    startTimer();
   
    loadUserDetails();
  
         otpControllers = List.generate(6, (index) => TextEditingController());
  focusNodes = List.generate(6, (index) => FocusNode());

     
    
  }
   Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber') ?? "";
   
  }

  

  String maskPhoneNumber(String phoneNumber) {
  if (phoneNumber.length < 10) return phoneNumber; // If number is less than 10 digits, return as is
  return 'XXXXXX${phoneNumber.substring(phoneNumber.length - 4)}'; // Mask first 8 digits
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
              decoration: BoxDecoration(
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasInternet = await checkInternet();

    if (!hasInternet) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ErrorScreen()),
      );
      return;
    }

    setState(() {
      isLoading = true;
      isOtpMessageReceived = false;
    });

    final responseData = await fetchOtpFromApiHelper();

    if (responseData != null && responseData['otp'] != null) {
      setState(() {
        receivedOtp = responseData['otp'].toString();
        isLoading = false;
        isOtpSent = true;
        _isOtpVisible = true;
        _isResendAvailable = false;
        timerSeconds = 30;
        isOtpMessageReceived = true;
      });
      _startResendTimer();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  

  


  

  void showProceedBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 👈 Full Screen Support
    isDismissible: false,
    builder: (BuildContext context) {
      return Container(
        
        width: double.infinity, // 👈 Full Width
        padding: EdgeInsets.all(20),
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "✅ OTP Verified!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Click 'I Have Proceed' to continue."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close Bottom Sheet
                navigateToNextScreen();
              },
              child: Text("I Have Proceed",style: GoogleFonts.lato(color: Colors.white),),
            ),
          ],
        ),
      );
    },
  );
}

  void navigateToNextScreen() {
    print("✅ Navigating to Next Screen...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CreateMpinScreen5()),
    );
  }


void checkOtp() {
  String enteredOtp = otpControllers.map((e) => e.text).join();

   if (enteredOtp.length < 6) {
    // 🛑 6 డిజిట్స్ ఫిల్ అవ్వలేదు అంటే ఎంటర్ చేయలేదు అని అర్థం
    _showInvalidOTPDialog("Please enter valid 6 digits OTP");
    return;
  }

   setState(() {
      _isLoading = true;
    });

  // ✅ Step 3: Check if 10 mins are over
  final now = DateTime.now();
  final diffInMinutes = now.difference(otpReceivedTime).inMinutes;

 if (diffInMinutes >= 10) {
  _showInvalidOTPDialog("OTP expired, please resend");
  
  // ✅ Clear OTP textfields
  for (var controller in otpControllers) {
    controller.clear();
  }

  // ✅ First field లో focus పెట్టండి
  focusNodes.first.requestFocus();

  return;
}


  if (enteredOtp == receivedOtp) {
    showProceedBottomSheet(); // ✅ బాటమ్ షీట్ చూపించాలి
 
  } else {
      showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LayoutBuilder(
        
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth * 0.03; // Dynamic font size
          fontSize = fontSize.clamp(12, 24); // Set min/max limits
  final localization = Provider.of<LocalizationProvider>(context);
          return AlertDialog(
            shape: RoundedRectangleBorder(
             // borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                SizedBox(
                  height: constraints.maxWidth * 0.08, // Dynamic height
                  width: constraints.maxWidth * 0.08,  // Dynamic width
                  child: Image.asset(
                    'assets/images/csc2.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    localization.translate('Please Enter Valid OTP'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: fontSize, // Dynamic font size
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(2, 5, 62, 1),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    
                    },
                    child: Text(
                      localization.translate("OK"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize * 0.8, // Adjusted button font size
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
    },
  );
  }
}

   

  String formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  // Check if all OTP fields are filled
  bool isOtpComplete() {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }


  void startTimer() {
  Timer.periodic(Duration(seconds: 10), (timer) {
    if (timerSeconds == 0) {
      timer.cancel();
    //  fetchOtpFromApi(); // ✅ Call API when timer ends
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
      _isResendAvailable = false; // Resend తర్వాత మళ్లీ టైమర్ రీసెట్ చేయాలి
      timerSeconds = 30; // టైమర్ మళ్లీ 30 సెకన్లకి సెట్ చేయాలి
    });
    fetchOtpFromApi(); // కొత్త OTP కోసం API కాల్
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: BackButton(
          onPressed: (){
              Navigator.pushReplacement(
              context, 
                      MaterialPageRoute(
                        builder: (context) => CurvedImageScreen2(),
                      )
                    );
          } ,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
          //   keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
             
              children: [
            SizedBox(height: screenHeight * 0),  
                  Image.asset('assets/images/otpauthenticate.jpg'),
                  SizedBox(height: screenHeight * 0.02),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                    localization.translate("OTP Verification"),
                      style: GoogleFonts.lato(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
               RichText(
            text: TextSpan(
              text: localization.translate(
          "Verification Code Sent to +${maskPhoneNumber(phoneNumber)}",
              ),
              style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          ),
          
                  SizedBox(height: screenHeight * 0.02),
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                       localization.translate('Change Phone Number'),
                        style: GoogleFonts.lato(color: Colors.red, fontSize: MediaQuery.of(context).size.height * 0.02, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => MobileScreen(),
                            )
                          );
                        },
                        icon: Icon(Icons.edit, size: 21, color: Colors.red),
                      ),
                    ],
                  ),
            
            
                Text(
                  localization.translate("Enter OTP"),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          
                  
                            Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
          width: screenWidth * 0.11, // Slightly smaller width
          height: 55, // Optional: fixed height for uniform shape
          child: TextField(
            controller: otpControllers[index],
            focusNode: focusNodes[index],
            enabled: isOtpMessageReceived,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(fontSize: 22),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.symmetric(vertical: 12), // Reduce padding
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5), // Make it rounded
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Color.fromRGBO(2, 5, 67, 1), width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              }
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
              }
            },
          ),
              );
            }),
          ),
          
          /*
           if (isOtpComplete()) {
          checkOtp(); // Only if all fields are filled
              }
            */
                SizedBox(height: screenHeight * 0.06),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.06,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(2, 5, 62, 1), // First color
                Color.fromRGBO(78, 67, 138, 1), // Second color
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
                 // borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                      child: ElevatedButton(

                      
          
                         onPressed: () => checkOtp(),
                       // onPressed: () {
                        //  String otp = otpControllers.map((e) => e.text).join();
                         // print("Entered OTP: $otp");
                          // Add OTP verification logic here
                       // },
                        style: ElevatedButton.styleFrom(
                         // backgroundColor: Color.fromRGBO(33, 36, 86, 1),
                          backgroundColor: Colors.transparent, // Make button background transparent
                          shadowColor: Colors.transparent, // Remove shadow if any
                          shape: RoundedRectangleBorder(
                           // borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                         localization.translate("Verify OTP"),
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height * 0.02,
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
              ? localization.translate("Didn't receive the OTP?") + " "
              : (timerSeconds == 1
                  ? localization.translate("Resend in 1 second") 
                  : localization.translate("Resend OTP in $timerSeconds seconds")),
          style: const TextStyle(color: Colors.grey),
              ),
              if (_isResendAvailable)
          TextButton(
            onPressed: _onResendOtp,
            child: Text(
              localization.translate('Resend'),
              style: const TextStyle(color: Color.fromRGBO(6, 8, 34, 1),fontWeight: FontWeight.bold),
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
