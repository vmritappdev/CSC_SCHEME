
import 'dart:async';
import 'dart:convert';



import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
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
      home:const PaymentVerificationScreen(id: '',),
    ),
  );
}

class PaymentVerificationScreen extends StatefulWidget {
  final String id;

   const PaymentVerificationScreen({super.key, required this.id});
  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  late int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 48;

 bool isVerifying = false;
 String amount = "";  
String dateTime = "";  
String remaingtimer = "";

Timer? periodicTimer;

// Modify initState
@override
void initState() {
  super.initState();
  SharedPreferences.getInstance().then((prefs) {
    setState(() {
      mobileNumber = prefs.getString('phoneNumber'); // Fetch mobile number
    });

    print("📞 Fetched Mobile Number: $mobileNumber"); // Debugging

    if (mobileNumber != null) {
      // Start periodic API call
      startPeriodicApiCall(mobileNumber!, widget.id);
    } else {
      print("🚨 Mobile number or ID missing!");
    }
  });
}

// Add this function to start periodic API call
void startPeriodicApiCall(String mobileNumber, String id) {
  // Cancel any existing timer
  periodicTimer?.cancel();

  // Start a new periodic timer
  periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    verifyPayment(mobileNumber, id); // Call the API
  });
}

// Don't forget to dispose the timer in dispose method to avoid memory leaks
@override
void dispose() {
  periodicTimer?.cancel();
  super.dispose();
}


 String? mobileNumber; // Define the variable







  Future<void> verifyPayment(String mobileNumber, String id) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');
    setState(() {
      isVerifying = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verification.php'),
        body: {
          'mobile_number': mobileNumber,
          'id': id,
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print("✅ Payment Verification Response: $responseData"); // 🖨️ API Response Print
        
        if (responseData['response'] == 'success') {  // **'response' key ని చెక్ చేయండి**


          setState(() {
    amount = responseData['amount']?.toString() ?? "processing"; 
    dateTime = "${responseData['date']} ${responseData['time']}"; 

    remaingtimer = responseData['remaining_timer']?.toString() ?? "processing"; 

    
  });
          //ScaffoldMessenger.of(context).showSnackBar(
           // SnackBar(content: Text("✅ Payment Verified Successfully!")),
         // );

          
        } else {
          print("❌ Error: ${responseData['message']}"); // 🖨️ API Error Message
          throw Exception(responseData['message']);
        }
      } else {
        print("🔴 API Error: ${response.statusCode}"); // 🖨️ Status Code Print
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🔴 API Call Failed: $e"); // 🖨️ Exception Print
     
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  String formatDate(String? apiDate) {
    if (apiDate == null || apiDate.isEmpty) return "Unknown Date";
    try {
      DateTime parsedDate = DateTime.parse(apiDate);
      return "${parsedDate.day} ${_getMonthName(parsedDate.month)} '${parsedDate.year % 100}, ${_formatTime(parsedDate)}";
    } catch (e) {
      print("🔴 Date Parsing Error: $e");
      return "Invalid Date";
    }
  }

  // 🔹 Month Name Getter
  String _getMonthName(int month) {
    List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  // 🔹 Time Formatter (12-hour format)
  String _formatTime(DateTime date) {
    int hour = date.hour;
    String period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:${date.minute.toString().padLeft(2, '0')} $period";
  }


String processTimer(String remaingtimer) {
  try {
    List<String> parts = remaingtimer.split(":"); // Split by ":"
    if (parts.length == 3) {
      String hours = parts[0].padLeft(2, '0'); // Hours
      String minutes = parts[1].padLeft(2, '0'); // Minutes
      String seconds = parts[2].padLeft(2, '0'); // Seconds
      return "$hours:$minutes:$seconds";
    }
  } catch (e) {
    print("Error processing timer: $e");
  }
  return "00:00:00"; // Default fallback
}


  

  @override
  Widget build(BuildContext context) {

  
    final localization = Provider.of<LocalizationProvider>(context, listen: true);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    

    

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
    // back press ayyaka em work cheyyalo ikkad implement cheyachu
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(activescheme: Activescheme()),
      ),
    );
   
    return false;  
  },
        child: Scaffold(
          appBar: AppBar(
           // iconTheme: IconThemeData(color: Colors.white),
           leading: BackButton(
            color: Colors.white,
            onPressed: () {
             

             
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) => HomeScreen(activescheme: Activescheme()),
                )
              );

              
            },
           ),
            backgroundColor: const Color.fromRGBO(43, 49, 101, 1),
            elevation: 0,
            centerTitle: true,
            title: Text(
              localization.translate("Payment Verification Process"),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05),
               CountdownTimer(
          endTime: endTime,
          widgetBuilder: (_, time) {
        if (time == null) {
          return Text(localization.translate("Time's up!"));
        } else {
          // మాన్యువల్‌గా 48 గంటల కౌంట్‌ను కలిక్యులేట్ చేయడం
// మొత్తం గంటలు
// మిగతా నిమిషాలు
// మిగతా సెకన్లు
        
          return Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              remaingtimer,
             
            // "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: Colors.orange,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
          },
        )
        ,
                SizedBox(height: screenHeight * 0.02),
                Text(
                  localization.translate("Verifying your payment"),
                  style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.01),
        
               Text(
          "${amount.isNotEmpty ? amount : "processing"} • ${dateTime.isNotEmpty ? dateTime : "N/A"}",
          style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black54),
        ),
        
        
                SizedBox(height: screenHeight * 0.02),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.timelapse, color: Colors.orange),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.translate("Payment verification in progress"),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  localization.translate("We will verify your payment details after we receive the payment from your bank."),
                                  style: TextStyle(fontSize: screenWidth * 0.04),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: screenHeight * 0.03, thickness: 1, color: Colors.grey[300]),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Text(
                              localization.translate("Payment will be credited to wallet"),
                              style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: screenWidth * 0.02),
        
                      Expanded(
                        child: Text(
                          localization.translate("Note: This is a manual payment process. Payment verification is in process. Please wait for confirmation."),
                          style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),
                ElevatedButton(
                  onPressed: () {
        
                    // SharedPreferences.getInstance().then((prefs) {
                //  prefs.setBool('isPaymentComplete', true);
                  
               
               // });
        
                Navigator.pop(context); 
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(activescheme: Activescheme(),),
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(),
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    backgroundColor: const Color.fromRGBO(43, 49, 101, 1),
                  ),
                  child: Text(
                    localization.translate("okay"),
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.05),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
