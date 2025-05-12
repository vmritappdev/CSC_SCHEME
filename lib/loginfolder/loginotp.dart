import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/loginfolder/mpinscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key});

  @override
  _LoginOtpState createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  final TextEditingController mobileController = TextEditingController();
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());

  bool isLoading = false;
  bool isOtpSent = false;
  bool isOtpMessageReceived = false;
  String receivedOtp = "";

   bool _isOtpButtonClicked = false; // Track button click status



   bool _isOtpVisible = false;
  bool _isResendAvailable = false;
  final bool _isOtpCorrect = false;
  int _timerSeconds = 30;

  String? loginPage; // to hold the login_page value from API

  

  // **Step 1: Verify Mobile Number**


   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();



 Future<void> savePhoneNumber(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhoneNumber', mobileNumber);
    await prefs.reload();  // ✅ Ensures the latest value is stored
    
    print("✅ Mobile Number Saved,,,,: $mobileNumber");
  }

  // ✅ Load Mobile Number from SharedPreferences
  Future<void> loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();  // ✅ Reloads latest data
    String? phoneNumber = prefs.getString('userPhoneNumber');

    setState(() {
      
      phoneController.text = phoneNumber!;
    });
    print("✅ Loaded Mobile Number,,,,,: $phoneNumber");
    }




  @override
  void initState() {
    super.initState();
    loadPhoneNumber();
   // verifyMobileNumber();
  
  
    
    
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

void _onResendOtp() async {
  if (_isResendAvailable) {
    setState(() {
      _isResendAvailable = false; // Resend కోసం టైమర్ Reset
      _timerSeconds = 30;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');

    if (mobileNumber!.isEmpty) {
      _showErrorPopup("❌ Mobile Number Not Found! Please Try Again.");
      return;
    }

    print("🔄 Resending OTP to: $mobileNumber");
    await fetchOtpFromApi(mobileNumber); // ✅ Now mobileNumber is passed correctly
  }
}



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



  Future<void> verifyMobileNumber() async {
  String mobileNumber = mobileController.text.trim();
    if (mobileNumber.isEmpty || mobileNumber.length != 10) {
      _showErrorPopup("Enter a valid 10-digit mobile number.");
      return;
    }

     bool hasInternet = await checkInternet();
    if (!hasInternet) {
      _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
      return ;
    }

    setState(() {
      isLoading = true;
      _isOtpButtonClicked = true; 
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile_verification.php'),  //'https://vmrdemos.com/csc_scheme/mobile_verification.php'
        body: {'mobile_no': mobileNumber},
      );

      var responseData = jsonDecode(response.body);
      print("✅ Mobile Verify API Response: $responseData");

      if (responseData['login'] == 'SUCCESS') {
        print("🔹 Login Success, saving phone number: $mobileNumber");
  await savePhoneNumber(mobileNumber);  // Save the phone number here
        fetchOtpFromApi(mobileNumber);
      } else {
        _showErrorPopup("This mobile number not found!");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ API Exception: $e");
      _showErrorPopup("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
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



  // **Step 2: Fetch OTP API**
  Future<void> fetchOtpFromApi(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp.php'), //'https://vmrdemos.com/csc_scheme/otp.php'
        body: {'mobile_no': mobileNumber},
      );


       bool hasInternet = await checkInternet();
    if (!hasInternet) {
      _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
      return ;
    }

      setState(() {
        isLoading = true;
        isOtpMessageReceived = false;
      });

      var responseData = jsonDecode(response.body);
      print("✅ OTP API Response: $responseData");

      if (response.statusCode == 200 && responseData.containsKey('otp')) {
        String apiOtp = responseData['otp'].toString();

        

        
        /*

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ OTP Sent Successfully")),
        );

        */

        String loginPage = responseData['login_page'];


        setState(() {
          receivedOtp = apiOtp;
          isLoading = false;
          isOtpSent = true;
           receivedOtp = responseData['otp'].toString();
        _isOtpVisible = true;
        _isResendAvailable = false;
        _timerSeconds = 30;
          this.loginPage = loginPage; // 👉 Save loginPage to a variable
        });

          _startResendTimer();
            await savePhoneNumber(mobileNumber);

          _fetchUserDetails();

       /*
        Future.delayed(Duration(seconds: 9), () {
          setState(() {
            isOtpMessageReceived = true;
          });

          print("⏳ Auto-filling OTP Fields after 2 sec...");
          autoFillOtp(apiOtp);
        });

        */

      } else {
        _showErrorPopup("Failed to fetch OTP. Try again.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ API Exception: $e");
      _showErrorPopup("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

void _verifyOtpAndProceed() {
  String enteredOtp = otpControllers.map((controller) => controller.text).join();

  if (enteredOtp.length != 6) {
    _showErrorPopup("Please enter 6-digit OTP");
    return;
  }

  if (enteredOtp == receivedOtp) {
    print("✅ OTP Correct: Proceeding based on loginPage: $loginPage");

    if (loginPage == 'create_mpin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateMpinScreen5()),
      );
    } else if (loginPage == 'home') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme())),
      );
    } else {
      _showErrorPopup("Invalid loginPage value received.");
    }
  } else {
    _showInvalidOTPDialog("❌ Invalid OTP. Please try again.");
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


  // **Step 3: Auto-Fill OTP**
  void autoFillOtp(String otp) {
    for (int i = 0; i < otp.length && i < 6; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        if (mounted) {
          setState(() {
            otpControllers[i].text = otp[i]; // Auto-Fill OTP
          });
        }
      });
    }
  }

  // **Error Popup**
  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double fontSize = MediaQuery.of(context).size.width * 0.03;
        fontSize = fontSize.clamp(12, 24);
        final localization = Provider.of<LocalizationProvider>(context);
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
                  style: GoogleFonts.lato(fontSize: 17, color: Colors.red),
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

  @override
  Widget build(BuildContext context) {
     final localization = Provider.of<LocalizationProvider>(context);
    return Scaffold(
      
      appBar: AppBar(
        title: Text(localization.translate("OTP Verification")),
         automaticallyImplyLeading: false,
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen1(),
              ),
            );
          },
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              maxLength: 10,
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: localization.translate("Enter Mobile Number"),
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
               // onPressed: isLoading ? null : verifyMobileNumber,
                onPressed: _isOtpButtonClicked ? null : verifyMobileNumber, // Disable after click
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(localization.translate("Get OTP"),
                        style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            
            if (isOtpSent) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 40,
                    child: TextField(
                              inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
  controller: otpControllers[index],
  keyboardType: TextInputType.number,
  maxLength: 1,
  maxLengthEnforcement: MaxLengthEnforcement.enforced,
  textAlign: TextAlign.center,
  decoration: const InputDecoration(
    counterText: '', // Hide counter
    border: OutlineInputBorder(), // Optional: add visible border
  ),
  onChanged: (value) {
    if (value.length == 1 && index < 5) {
      Future.microtask(() {
        FocusScope.of(context).nextFocus();
      });
    }

     
  },
),

                  );
                }),
              ),
              const SizedBox(height: 10),
           SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      _verifyOtpAndProceed(); // ✅ call the method
    },
    child: Text(
      localization.translate("Verify OTP"),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    ),
  ),
),



                            const SizedBox(height: 20),

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
          style: const TextStyle(color: Color.fromRGBO(6, 8, 34, 1),fontWeight: FontWeight.bold),
        ),
      ),
  ],
),
            ],
          ],
        ),
      ),
    );
  }
}
