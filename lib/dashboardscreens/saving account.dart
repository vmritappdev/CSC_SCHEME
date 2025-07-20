import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/scner.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/dashboardscreens/join_scheme.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/upidetails/rejected%20screen.dart';
import 'package:csc/upidetails/payment%20verify.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  runApp(MaterialApp(
     builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    home: const SavingsAccountScreen()));
}

class SavingsAccountScreen extends StatefulWidget {
  const SavingsAccountScreen({super.key});

  @override
  _SavingsAccountScreenState createState() => _SavingsAccountScreenState();
}

class _SavingsAccountScreenState extends State<SavingsAccountScreen> {
  bool isGoldSchemeComplete = false;
  bool isTransactionComplete = false;
  bool isPaymentComplete = false;

    final bool _isLoading = false;
    String processStatus = "";
    String id = '';

     final RefreshController _refreshController = RefreshController();

void _onRefresh() async {
  try {
     loadProcessStatus();
    fetchProcessStatus();
   
  } catch (e) {
    print("Error during refresh: $e");
  } finally {
    _refreshController.refreshCompleted();
  }
}

  


  @override
  void initState() {
    super.initState();
    loadProcessStatus();
    fetchProcessStatus();
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


  Future<void> loadProcessStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isGoldSchemeComplete = prefs.getBool('isGoldSchemeComplete') ?? false;
      isTransactionComplete = prefs.getBool('isTransactionComplete') ?? false;
     // isPaymentComplete = prefs.getBool('isPaymentComplete') ?? false;
    });
  }

  Future<void> saveProcessStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isGoldSchemeComplete', isGoldSchemeComplete);
    prefs.setBool('isTransactionComplete', isTransactionComplete);
   // prefs.setBool('isPaymentComplete', isPaymentComplete);
  }

 Future<void> fetchProcessStatus() async {

   bool hasInternet = await checkInternet();
    if (!hasInternet) {
      ErrorScreen();
    //  _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
      return;
    }

    
  String apiUrl = "$baseUrl/process_verification.php";

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'mobile_no': mobileNumber,
      },
    );

     print("Request URI: url"); // Prints the API endpoint
  
    print("Response Status Code: ${response.statusCode}"); // Prints the status code
    print("Response Body: ${response.body}"); // Prints the API response body

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
         processStatus = data['process_status']; 
         id = data.containsKey('reject_id') ? data['reject_id'] ?? '' : '';  // Ensure non-null value
        if (data['process_status'] == "2" || data['process_status'] == "3") {
          // ✅ Step 1: Show Green Color for 1 second
          isGoldSchemeComplete = true;
          isTransactionComplete = true;
          isPaymentComplete = true;

         // Future.delayed(Duration(seconds: 1), () {
            // ✅ Step 2: Remove Green Color (After 1 second)
            setState(() {
              isGoldSchemeComplete = false;
              isTransactionComplete = false;
              isPaymentComplete = false;
            });
         // }
        //  );
        } else {
          // ✅ Normal Process Status Update
          isGoldSchemeComplete = data['process_status'] == "0" || data['process_status'] == "1";
          isTransactionComplete = data['process_status'] == "1";
          isPaymentComplete = false;
        }

        saveProcessStatus();
      });
    }
  } catch (e) {
    debugPrint('Error fetching process status: $e');
  }
}





  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final localization = Provider.of<LocalizationProvider>(context);
    return SafeArea(
      child: Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          elevation: 0,
          title: Text(
            localization.translate('Join Scheme'),
            style: GoogleFonts.lato( color: Colors.black,
            fontSize: screenWidth * 0.045, 
            fontWeight: FontWeight.bold,)
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(context, 
              MaterialPageRoute(
                builder: (context) => HomeScreen(activescheme: Activescheme(),),
              )
              );
            },
          ),
        ),
        body: _isLoading
        ? const CircularProgressIndicator()
       : SmartRefresher(
        controller: _refreshController,
          onRefresh: _onRefresh,
      
            header: const WaterDropHeader(
            complete: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text("Refresh Completed", style: TextStyle(color: Colors.green)),
              ],
            ),
            waterDropColor: Color.fromARGB(255, 4, 2, 29),
          ),
         child: Column(
            children: [
              Container(
               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Image.asset(
                   'assets/images/test2.png', // Update with your asset
                     height: screenHeight * 0.25,
                ),
              ),
               SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(screenWidth * 0.05), // ✅ Dynamic Border Radius
                    topRight: Radius.circular(screenWidth * 0.05),
                    ),
                  ),
                   padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       localization.translate('3 STEPS TO COMPLETE YOUR REGISTRATION'),
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold,
                         fontSize: screenWidth * 0.04,
                          color: Colors.black,)
                      ),
                       SizedBox(height: screenHeight * 0.04), 
                      Expanded(
                        child: ListView(
                          children: [
                            _buildStepItem(localization.translate('Scheme Registration'), isGoldSchemeComplete, false,context),
                            _buildStepItem(localization.translate('Complete Transaction'), isTransactionComplete, false,context),
                            _buildStepItem(localization.translate('Verified Payment'), isPaymentComplete, true,context),
                          ],
                        ),
                      ),
                    SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
               backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
         padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
               shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
               ),
          ),
               
               
               
               
          onPressed: () async {
          await fetchProcessStatus(); // Ensure latest status is fetched
               
          if (processStatus == "4") {
               Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentRejectedScreen(rejectId: id,)), // Rejection screen
          );
          return; // Stop further execution
          }
               
          if (processStatus == "1") {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentVerificationScreen(id: '',)),
               );
               return; // Stop further execution
          }
               
          if (!isGoldSchemeComplete) {
               final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Jionscheme2()),
               );
               if (result == true) {
          setState(() {
            isGoldSchemeComplete = true;
          });
               }
          } else if (!isTransactionComplete) {
               final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scanner(activescheme: Activescheme(),rejectId: id,)),
               );
               if (result == true) {
          setState(() {
            isTransactionComplete = true;
            saveProcessStatus();
          });
               }
          } else if (!isPaymentComplete) {
               Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentVerificationScreen(id: '',)),
               );
          } else {
               setState(() {
          isGoldSchemeComplete = false;
          isTransactionComplete = false;
          isPaymentComplete = false;
          saveProcessStatus();
               });
               
               Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Jionscheme2()),
               );
          }
               },
               
               
          /*
           onPressed: () async {
          await fetchProcessStatus(); // Ensure latest status is fetched
               
          if (processStatus == "1") {
               Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentVerificationScreen(id: '',)),
               );
               return; // Stop further execution
          }
               
          if (!isGoldSchemeComplete) {
               final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Jionscheme2()),
               );
               if (result == true) {
          setState(() {
            isGoldSchemeComplete = true;
          });
               }
          } else if (!isTransactionComplete) {
               final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scanner(activescheme: Activescheme())),
               );
               if (result == true) {
          setState(() {
            isTransactionComplete = true;
            saveProcessStatus();
          });
               }
          } else if (!isPaymentComplete) {
               Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentVerificationScreen(id: '',)),
               );
          } else {
               setState(() {
          isGoldSchemeComplete = false;
          isTransactionComplete = false;
          isPaymentComplete = false;
          saveProcessStatus();
               });
               
               Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Jionscheme2()),
               );
          }
               },
               */
               
          child: Text(
               localization.translate('Get Started'),
               style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.045,
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
       ),
      ),
    );
  }




   Widget _buildStepItem(String title, bool isComplete, bool isLast,BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      decoration: BoxDecoration(
                        color: isComplete ? Colors.green : Colors.white, // ✅ Green only if isComplete is true
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    if (isComplete)
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: screenWidth * 0.04
                      ),
                  ],
                ),
                if (!isLast)
                  Container(
                    width: 2,
                     height: screenWidth * 0.1,
                    color: isComplete ? Colors.green : Colors.grey,
                  ),
              ],
            ),
             SizedBox(width: screenWidth * 0.05),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                 fontSize: screenWidth * 0.04,
              ),
            ),
          ],
        ),
      ],
    );
  }


}