

import 'package:csc/api_services.dart/active_api.dart';

import 'package:csc/chaingedscreens.dart/insatllment.dart';
import 'package:csc/utillity/constant.dart';

import 'package:csc/dashboardscreens/faq_screen.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/dashboardscreens/view%20details.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/dashboardscreens/saving%20account.dart';
import 'package:csc/model/SchemeResponseNew.dart';
import 'package:csc/model/activescheme.dart';



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home:const PaymentCard(),
    ),
  );
}

class PaymentCard extends StatefulWidget {
  const PaymentCard({super.key});

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  SchemeResponseNew? activeSchemeNew;
  bool isDataLoaded = false; // Flag to track if data is loaded
  

   bool showDialogFlag = false;

   bool isMyScreenCalled = false; // Add this at the top of your StatefulWidget class.

String overdue = "no";
 bool isButtonActive = false; // Track if button is clicked

 final ActiveSchemeService _service = ActiveSchemeService();

 bool _popupShown = false; // To track if popup is already shown
 bool _isPolling = true; // Flag to control polling
//bool _isPollingStarted = false;

  @override
  void initState() {
    super.initState();
  //  fetchActiveSchemes();
  loadSchemes();
 
   verifyPaymentProcess(context);
     
   _startPolling();
  

    
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



Future<void> checkSchemeDetails(BuildContext currentContext) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  const String apiUrl = "$baseUrl/active_pop.php";   

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'mobile_no': mobileNumber},
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Check if "response" is "success"
      if (responseData['response'] == 'success') {
        // ✅ Success - No popup
        print("Response indicates success. No popup required.");
        return;
      } else {
        // ❌ Response not "success" - Show popup
        print("Response indicates an error. Showing popup.");
        showNoSchemePopup(currentContext);
      }
    } else {
      // ❌ Non-200 response - Show popup
      print("Non-200 status code received. Showing popup.");
      showNoSchemePopup(currentContext);
    }
  } catch (e) {
    // ❌ Exception occurred - Show popup
    print("Exception occurred: $e. Showing popup.");
    showNoSchemePopup(currentContext);
  }
}



void showNoSchemePopup(BuildContext currentContext) {
    final localization = Provider.of<LocalizationProvider>(context, listen: false);
  // Check if the dialog is already shown
  if (isDataLoaded && (activeSchemeNew == null || activeSchemeNew!.schemeDetails.isEmpty) && !showDialogFlag) {
  showDialogFlag = true;  // Prevent showing the dialog again
  Future.microtask(() {
   showDialog(
    context: currentContext,
     barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
      //  borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero, // Remove extra padding
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/csc2.png',
                height: 50,
              ),
              const SizedBox(width: 8),
              Text(
                localization.translate("No Scheme Details"),
                style: GoogleFonts.lato(fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color.fromRGBO(2, 5, 62, 1),)
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              localization.translate("Sorry, you have not joined any schemes. Kindly register to join a scheme."),
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                 fontSize: 13* MediaQuery.of(context).textScaleFactor,
                color: Colors.black,
              )
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actionsPadding: EdgeInsets.zero, // Remove default actions padding
      actions: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(2, 5, 62, 1),
            borderRadius: BorderRadius.only(
              //bottomLeft: Radius.circular(20),
             // bottomRight: Radius.circular(20),
            ),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(activescheme: Activescheme()),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15), // Fix button height
            ),
            child: Text(
              localization.translate("OK"),
              style: TextStyle(
              fontSize: 16 * MediaQuery.of(context).textScaleFactor,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
  });
}
}

  // Submit form and send data to API
 

void loadSchemes() async {
    final result = await _service.fetchActiveSchemes(context);
    if (result != null) {
      setState(() {
        activeSchemeNew = result;
        isDataLoaded = true;
      });

      
  


      
    } else {
      // No need to do anything here because ErrorScreen will be shown from service
      setState(() {
        isDataLoaded = true;
      });


      
    }
  }


 

String getDueText(String dueDate, String schemeStatus) {
  // First check scheme status
  if (schemeStatus.toLowerCase() == "closed") {
    return "Scheme Closed";
  } else if (schemeStatus.toLowerCase() == "suspended") {
    return "Scheme Suspend";
  } else if (schemeStatus.toLowerCase() == "discounted") {
    return "Discounted Scheme";
  }

  // Otherwise, calculate due days normally (only if Active)
  final currentDate = DateTime.now();
  final dueDateTime = DateTime(
    int.parse(dueDate.substring(0, 4)),
    int.parse(dueDate.substring(5, 7)),
    int.parse(dueDate.substring(8, 10)),
  );

  final difference = dueDateTime.difference(DateTime(
    currentDate.year,
    currentDate.month,
    currentDate.day,
  )).inDays;

  overdue = "no"; // Reset overdue status
  if (difference <= -60) {
    overdue = "yes";
  }

  if (difference < 0) {
    return 'Overdue By ${difference.abs()} Days';
  } else if (difference == 0) {
    return 'Due today';
  } else {
    return 'Due in $difference days';
  }
}


String getOverdueStatus(String dueDate) {
  final currentDate = DateTime.now();
  final dueDateTime = DateTime(
    int.parse(dueDate.substring(0, 4)),
    int.parse(dueDate.substring(5, 7)),
    int.parse(dueDate.substring(8, 10)),
  );

  final difference = dueDateTime.difference(DateTime(
    currentDate.year,
    currentDate.month,
    currentDate.day,
  )).inDays;

  if (difference < 0) {
    return "1"; // Overdue
  } else {
    return "0"; // Not overdue
  }
}

Color getDueDateColor(String dueDate, String schemeStatus) {
  final currentDate = DateTime.now();
  final dueDateTime = DateTime.parse(dueDate);

  // Color based on scheme status
  if (schemeStatus.toLowerCase() == "closed") {
    return Colors.red; // Closed Scheme
  } else if (schemeStatus.toLowerCase() == "suspended") {
    return Colors.orange; // Discounted Scheme
  } else if (dueDateTime.isBefore(currentDate)) {
    return Colors.orange; // Overdue
  } else if (dueDateTime.isAtSameMomentAs(currentDate)) {
    return const Color.fromRGBO(244, 67, 54, 1); // Today
  } else {
    return Colors.green; // Active and future dates
  }
}

  String formatDueDate(String dueDate) {
  final dueDateTime = DateTime.parse(dueDate);
  return "${dueDateTime.day.toString().padLeft(2, '0')}-"
         "${dueDateTime.month.toString().padLeft(2, '0')}-"
         "${dueDateTime.year}";
}



void _startPolling() {
  if (!_isPolling || !mounted) return;

  Future.delayed(const Duration(seconds: 1), () async {
    if (_isPolling && mounted) {
      await verifyPaymentProcess(context);
      _startPolling(); // Keep polling until popup shows
    }
  });
}

Future<void> verifyPaymentProcess(BuildContext context) async {
  print("🔔 verifyPaymentProcess called");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  if (mobileNumber!.isEmpty) {
    print("⚠️ Mobile number not found.");
    return;
  }

  final url = Uri.parse('https://vmrdemos.com/csc_scheme/payment_process_verification.php');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'mobile_no': mobileNumber},
    );

    print("🌐 API Response Code: ${response.statusCode}");
    print("📦 API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response'] == 'success') {
        List<dynamic> items = data['data'];

        for (var item in items) {
          String status = item['result_status'];
          String regId = item['reg_id'];
          String id = item['id'];

          if (!_popupShown && mounted) {
            _popupShown = true;
            _isPolling = false;

            showPremiumPopup(
              context,
              status == 'accept' ? "✅ Accepted" : "❌ Rejected",
              "Your scheme $regId was ${status == 'accept' ? 'accepted' : 'rejected'}.",
              id,
            );
          }
        }
      } else {
        print("⚠️ API said failure: ${data['message']}");
      }
    } else {
      print("❌ Unexpected HTTP status: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Exception: $e");
  }
}

Future<void> callClosePayPopApi(String id) async {
  final closeUrl = Uri.parse('https://vmrdemos.com/csc_scheme/close_pay_pop.php');

  try {
    final closeResponse = await http.post(
      closeUrl,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'id': id},
    );

    if (closeResponse.statusCode == 200) {
      final result = json.decode(closeResponse.body);
      print("✅ close_pay_pop Response for ID $id: $result");
    } else {
      print("❌ close_pay_pop Error for ID $id: ${closeResponse.statusCode}");
    }
  } catch (e) {
    print("❌ Exception in close_pay_pop API: $e");
  }
}





void showPremiumPopup(BuildContext context, String title, String message, String id) {

  showDialog(
    context: context,
        barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
      //  borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

           Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(2, 5, 62, 1),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  callClosePayPopApi(id);
                },
                child: const Text(
                  ("OK"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
     final localization = Provider.of<LocalizationProvider>(context, listen: false);
  final currentContext = context;

     double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double padding = screenWidth * 0.05;

     

     // Show popup if activeSchemeNew is null or has no details
  // Show popup if activeSchemeNew is null or has no details after data is loaded

  checkSchemeDetails(currentContext, );



 


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
       backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
        title: Text(
          localization.translate("Advance Gold Purchase Plan"),
          style: GoogleFonts.lato( color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          
            )
          
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [


           

           

             if (activeSchemeNew != null && activeSchemeNew!.activeSchemes.isNotEmpty) ...[
  _buildSectionTitle("Active Schemes"),
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: activeSchemeNew!.activeSchemes.length,
    itemBuilder: (context, index) {
      final schemeDetail = activeSchemeNew!.activeSchemes[index];
      return _buildSchemeCard(
        context,
        title: localization.translate("Advance Gold Purchase"),
        details: [
          localization.translate("100% V.A. Free on Items up to 18% Wastage"),
          localization.translate("Flexible Monthly Investment"),
          localization.translate("Short Term - Great Benefits"),
        ],
        iconWidget: const Icon(Icons.check, color: Colors.green),
        amount: localization.translate("Rs. ${schemeDetail.amount}"),
   dueDate: activeSchemeNew!.activeSchemes.isNotEmpty
    ? getOverdueStatus(schemeDetail.dueDate) == "1"
        ? "" // Don't show anything if overdue
        : localization.translate("Next Installment: ") + formatDueDate(schemeDetail.dueDate)
    : "",


        buttonText1: localization.translate("View details"),
       buttonText2: getOverdueStatus(schemeDetail.dueDate) == "1"
    ? localization.translate("Payment Disabled")
    : 'Pay Rs. ${schemeDetail.amount}',

      

        dueText: getDueText(schemeDetail.dueDate, schemeDetail.schemeStatus),
        dueTextColor: getDueDateColor(schemeDetail.dueDate, schemeDetail.schemeStatus),
        month: schemeDetail.month,
        year: schemeDetail.year,
        schemeID: schemeDetail.schemeId,
        amountRs: schemeDetail.amount.toString(),
        msno: schemeDetail.msNo,
        pay_status: schemeDetail.payStatus,
        name: schemeDetail.name,
        scheme_status: schemeDetail.schemeStatus,
        over_due_status: schemeDetail.overdue,
        buttonText3: ('')
      );
    },
  ),
],


          
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Color.fromRGBO(2, 5, 62, 1),
                thickness: 1,
              ),
            ),

            /*

               Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  localization.translate("Closed Schemes"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(43, 49, 101, 1),
                  ),
                ),
              ),
            ),

            */




                  if (activeSchemeNew?.suspendedSchemes.isNotEmpty == true) ...[
                    _buildSectionTitle("Discontinue Schemes"),
                    _buildSchemeList(activeSchemeNew!.suspendedSchemes),
                  ],


                   if (activeSchemeNew?.closedSchemes.isNotEmpty == true) ...[
                    _buildSectionTitle("Closed Schemes"),
                    _buildSchemeList(activeSchemeNew!.closedSchemes),
                  ],
         // MyScreen(), // Closed schemes or any additional widget


         const SizedBox(  height: 40)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const SavingsAccountScreen(),
            )
          );
        },
        label: Text(
          
          localization.translate("Join Scheme"),
          style: GoogleFonts.lato(color: Colors.white,fontSize: 18),
        ),
       // icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(2, 5, 62, 1),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme(),)),
                  );
                },
              ),
  IconButton(
              icon: Image.asset(
  'assets/images/faq.png',
  width: MediaQuery.of(context).size.width * 0.08,
  height: MediaQuery.of(context).size.width * 0.08,
  color: Colors.white,
),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


  Widget _buildSchemeCard(
    BuildContext context, {
    required String title,
    required List<String> details,
   // required String image,
    required Icon iconWidget,
    required String amount,
    required String dueDate,
    required String buttonText1,
    required String buttonText2,
    required String dueText,
    required Color dueTextColor,
    required String month,
    required String year,
    required String schemeID,
    required String amountRs,
    required String msno, // Added parameter for MS No
     required String pay_status,
     required String name,
    required String scheme_status,
    required String over_due_status,
     required String buttonText3,
  }) {

     final localization = Provider.of<LocalizationProvider>(context);
     double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
     
    return Stack(
      children: [
        Container(
         padding: EdgeInsets.all(screenWidth * 0.05),  // 4% of screen width
  margin: EdgeInsets.symmetric(
    vertical: screenHeight * 0.01,  // 1% of screen height
    horizontal: screenWidth * 0.04,  // 4% of screen width
  ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /*
                 Image.asset(
  image,
  height: MediaQuery.of(context).size.height * 0.04, // 4% of screen height
  width: MediaQuery.of(context).size.width * 0.08,   // 8% of screen width
  fit: BoxFit.contain, // Ensures the image scales properly
),

    */              Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold,
                        fontSize: 14* MediaQuery.of(context).textScaleFactor,
                        color: const Color.fromRGBO(2, 5, 62, 1),)
                    ),
                  ),
            
                  
                  Text(
                    amount,
                    style: GoogleFonts.lato(color: Colors.black,
                      fontSize: 14* MediaQuery.of(context).textScaleFactor,
                      fontWeight: FontWeight.bold,)
                  ),

                  
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                     "${localization.translate("Scheme No")} $msno",
                   // "Scheme No: $msno", // Display MS No here
                    style: GoogleFonts.lato( color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12* MediaQuery.of(context).textScaleFactor,)
                  ),
                 Text(
  capitalizeEachWord(name), // Capitalize each word
  style: GoogleFonts.lato(
    color: const Color.fromRGBO(2, 5, 67, 1),
    fontWeight: FontWeight.bold,
    fontSize: 12 * MediaQuery.of(context).textScaleFactor,
  ),
),


                ],
              ),
              const SizedBox(height: 8.0),
              for (var detail in details)
                Row(
                  children: [
                    Icon(iconWidget.icon, color: iconWidget.color, size: 20),
                    const SizedBox(width: 8.0),
                    Text(detail,style: const TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
                  ],
                ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  dueDate,
                  style: GoogleFonts.lato(fontSize: 11* MediaQuery.of(context).textScaleFactor,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 3, 18, 30),)
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Scheme ID passed: schemeID');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => JewelryTransactionScreen(
                                    schemeId: schemeID,
                                  )
                                  ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      child: Text(
                        buttonText1,
                        
                        style: GoogleFonts.lato( color: Colors.black,
                        // fontSize: *10* MediaQuery.of(context).textScaleFactor,
                          fontSize: 11 * MediaQuery.of(context).textScaleFactor,
                          fontWeight: FontWeight.bold,)
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  
             Expanded(
  child: ElevatedButton(
onPressed: () {
  final status = (scheme_status ?? "").toLowerCase().trim();
  final overdue = (over_due_status ?? "").toLowerCase().trim();

  if (overdue == "over due") {
    showPaymentAccessDisabledBottomSheet(context);
  } else if (status == "closed") {
    showClosedSchemeBottomSheet(context);
  } else if (status == "suspend" || status == "suspended") {
    showSuspendedSchemeBottomSheet(context);
  } else if (status == "active") {
    if (pay_status == "1") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstallmentScreen(schemeId: schemeID),
        ),
      );
    } // else do nothing (user not allowed)
  }
}
,
        
    style:ButtonStyle(
  backgroundColor: WidgetStateProperty.resolveWith<Color>(
    (Set<WidgetState> states) {
      final isOverDue = (over_due_status ?? "").toLowerCase().trim() == "over due";
      final isClosed = scheme_status.toLowerCase().trim() == "closed";
      final isActive = scheme_status.toLowerCase().trim() == "active";

      if (isOverDue || isClosed) {
        return const Color.fromRGBO(2, 5, 62, 1); // Dark blue
      }

      if (isActive) {
        if (pay_status == '') {
          return  const Color.fromRGBO(2, 5, 62, 1); // Grey
        } else {
          return  const Color.fromARGB(255, 233, 231, 231); // Blue
        }
      }

      return const Color.fromRGBO(2, 5, 62, 1); // Default dark blue
    },
  ),
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
),

    child: Text(
      buttonText2,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 11 * MediaQuery.of(context).textScaleFactor,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),


                ],
              ),

             

            ],
          ),
        ),

      
        Positioned(
         top: MediaQuery.of(context).size.height * 0.01, // 1% of screen height
  right: MediaQuery.of(context).size.width * 0.04, // 4% of screen width
          child: Container(
            padding: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width * 0.04,
  //  vertical: MediaQuery.of(context).size.height * 0.01,
  vertical: MediaQuery.of(context).size.height * 0.004
    ),
            decoration: BoxDecoration(
              color: dueTextColor,
            ),
            child: Text(
              dueText,
              style: GoogleFonts.lato(color: Colors.white, fontSize: 10* MediaQuery.of(context).textScaleFactor),
            ),
          ),
        ),


        
      ],
    );
  }




 
 
 
 Widget _buildSchemeList(List<SchemeDetailsNew> schemes) {
    final localization = Provider.of<LocalizationProvider>(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schemes.length,
      itemBuilder: (context, index) {
        final schemeDetail = schemes[index];
        return _buildSchemeCard(
          context,
          title: localization.translate("Advance Gold Purchase"),
          details: [
            localization.translate("100% V.A. Free on Items up to 18% Wastage"),
            localization.translate("Flexible Monthly Investment"),
            localization.translate("Short Term - Great Benefits"),
          ],
          iconWidget: const Icon(Icons.check, color: Colors.green),
          amount: localization.translate("Rs. ${schemeDetail.amount}"),
          dueDate: localization.translate(" "),
          buttonText1: localization.translate("View details"),
          buttonText2: getDueText(schemeDetail.schemeStatus, schemeDetail.schemeStatus),
          dueText: getDueText(schemeDetail.dueDate, schemeDetail.schemeStatus),
          dueTextColor: getDueDateColor(schemeDetail.dueDate,schemeDetail.schemeStatus),
          month: schemeDetail.month,
          year: schemeDetail.year,
          schemeID: schemeDetail.schemeId,
          amountRs: schemeDetail.amount.toString(),
          msno: schemeDetail.msNo,
          pay_status: schemeDetail.payStatus,
          name: schemeDetail.name,
          scheme_status: schemeDetail.schemeStatus,
          over_due_status: schemeDetail.overdue,
          buttonText3: getDueText(schemeDetail.schemeStatus, schemeDetail.schemeStatus),
        );
      },
    );
  }


  



  String capitalizeEachWord(String text) {
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}



void showPaymentAccessDisabledBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Transparent background
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
     initialChildSize: 0.5, // Adjust this value as needed
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const SingleChildScrollView(
          //  controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, color: Color(0xFFEF6C00), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Payment Access Disabled',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF6C00),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'You have not paid your installment for over 60 days. As a result, the direct payment option has been disabled. Please contact CSC Jewellers admin or visit our branch in Nellore.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5D4037),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.phone, size: 20, color: Color(0xFFEF6C00)),
                    SizedBox(width: 8),
                    Text(
                      'Admin Contact: 94906 57008',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBF360C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}



void showClosedSchemeBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // 👈 this is key to avoid default height issues
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets, // keyboard overlap avoid cheyadaniki
        child: Container(
          margin: const EdgeInsets.only(top: 100), // 👈 This ensures it comes from bottom with proper height
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: const Column(
            mainAxisSize: MainAxisSize.min, // 👈 very important to shrink-wrap content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Your Gold Scheme is Closed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF6C00),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'This scheme has been successfully completed or closed. Further payments cannot be made. For more details, please contact the store or start a new scheme.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5D4037),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.phone, size: 20, color: Color(0xFFEF6C00)),
                  SizedBox(width: 8),
                  Text(
                    'Admin Contact: 94906 57008',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBF360C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}



void showSuspendedSchemeBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: Colors.orange.shade700, width: 1.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.deepOrange, size: 18),
              SizedBox(width: 8),
              Text(
                'Your Gold Scheme is Suspended',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF6C00),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'This scheme is currently suspended. Please contact the store to know the reason or request reactivation. Payments are temporarily disabled until the issue is resolved.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF5D4037),
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.phone, size: 20, color: Color(0xFFEF6C00)),
              SizedBox(width: 8),
              Text(
                'Admin Contact: 94906 57008',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBF360C),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}






// Use this method in your code where necessary. 
// For example, when the payment is overdue by 60 days:



}
