import 'dart:convert';

import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateMpin1Screen extends StatefulWidget {
  const CreateMpin1Screen({super.key});

  @override
  State<CreateMpin1Screen> createState() => _CreateMpin1ScreenState();
}

class _CreateMpin1ScreenState extends State<CreateMpin1Screen> {


  void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home:const CreateMpin1Screen(),
    ),
  );
}






  static const defaultPinTheme = PinTheme(
    width: 80,
    height: 70,
    textStyle: TextStyle(
      color: Colors.black,
      fontSize: 22,
    ),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey)),
    ),
  );

  String mpin = '';
  String confirmMpin = '';
  String errorMessage = '';



 Future<void> saveMobileNumber(String mobileNumber) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('phoneNumber', mobileNumber);
  debugPrint("✅ Mobile Number Saved: $mobileNumber");
}

 Future<String?> loadMobileNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');
  debugPrint("Loaded Mobile Number: $mobileNumber");
  return mobileNumber;
}

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future.delayed(const Duration(seconds: 1)); // 🔴 Extra Delay for Async Storage
    String? mobile = await loadMobileNumber();
    debugPrint("📥 Loaded Mobile Number at CreateMpin1Screen: $mobile");
  });
}




  Future<void> _fetchAndSaveUserDetails() async {
    const String apiUrl = "$baseUrl/get_reg_account_details.php";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobileNumber = prefs.getString('phoneNumber');

      if (mobileNumber!.isEmpty) {
        print("❌ Mobile Number not found in SharedPreferences");
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'mobile_no': mobileNumber},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 200) {
          var userDetails = jsonResponse['account_details'][0];
          await prefs.setString('firstName', userDetails['f_name'] ?? "");
          await prefs.setString('lastName', userDetails['l_name'] ?? "");
          await prefs.setString('phoneNumber', userDetails['mobile_no'] ?? "");
          await prefs.setString('email', userDetails['email_id'] ?? "");
          print("✅ User details saved in SharedPreferences");
        } else {
          print("❌ Error: ${jsonResponse['message']}");
        }
      } else {
        print("❌ Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception in fetching user details: $e");
    }
  }






  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight,
                maxWidth: screenWidth,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(2, 5, 62, 1),
                    Color.fromRGBO(2, 5, 62, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.13),
                  Image.asset(
                    'assets/images/csc2.png',
                    height: 90,
                    fit: BoxFit.fill,
                    color: Colors.white,
                  ),
                  Text(
                    localization.translate('JEWELLERS'),
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.15),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight,
                        maxWidth: screenWidth,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                localization.translate('Create MPIN*'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            buildPinput(
                              onChanged: (value) {
                                setState(() {
                                  mpin = value;
                                  errorMessage = '';
                                });
                              },
                            ),
                            const SizedBox(height: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                localization.translate('Confirm MPIN*'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            buildPinput(
                              onChanged: (value) {
                                setState(() {
                                  confirmMpin = value;
                                  errorMessage = '';
                                });
                              },
                            ),
                            if (errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  
                                  errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            SizedBox(height: screenHeight * 0.09),
                            buildSubmitButton(localization),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPinput({required ValueChanged<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Pinput(
        length: 4,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: const Border(
              bottom: BorderSide(color: Color.fromRGBO(2, 5, 62, 1), width: 2),
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildSubmitButton(LocalizationProvider localization) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () async {
          if (mpin.isEmpty || confirmMpin.isEmpty) {
            setState(() {
              errorMessage = localization.translate('Please enter both MPIN and Confirm MPIN.');
            });
            return;
          }
          if (mpin != confirmMpin) {
            setState(() {
              errorMessage = localization.translate('MPINs do not match!');
            });
            return;
          }

          bool success = await _submitMpinToServer(mpin, confirmMpin);
          if (success) {
            await _fetchAndSaveUserDetails();
            _showCustomBottomSheet(context);
          }
        },
        child: Text(
          localization.translate('SUBMIT'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
 
 /*
  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    
  });
}

*/

  Future<bool> _submitMpinToServer(String mpin, String confirmMpin) async {
    const String phpUrl = "$baseUrl/update_mpin.php";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobileNumber = prefs.getString('phoneNumber');

      if (mobileNumber!.isEmpty) {
        setState(() {
          errorMessage = 'Mobile number not found. Please login again.';
        });
        return false;
      }

      final response = await http.post(
        Uri.parse(phpUrl),
        body: {
          'mpin': mpin,
          'conform_mpin': confirmMpin,
          'mobile_no': mobileNumber,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 200) {
          debugPrint("✅ MPIN Update Successful");
          return true;
        } else {
          setState(() {
            errorMessage = jsonResponse['message'] ?? 'Failed to update MPIN.';
          });
          return false;
        }
      } else {
        setState(() {
          errorMessage = 'Server error. Please try again.';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong: $e';
      });
      return false;
    }
  }
  void _showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  HomeScreen(activescheme: Activescheme(),)),
          );
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(2, 5, 62, 1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set MPIN Successfully',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Lottie.asset(
                      'assets/images/suc.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}