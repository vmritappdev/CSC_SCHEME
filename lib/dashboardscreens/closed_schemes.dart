import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/saledetails%20page.dart';
import 'package:csc/utillity/constant.dart';

import 'package:csc/localization/localizationpro.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      home: const MyScreen(schemeId: '',),
    ),
  );
}

class MyScreen extends StatefulWidget {
   final String schemeId;
   const MyScreen({super.key, required this.schemeId}); // 🆕 Constructor update


 //  const MyScreen({Key? key, required t}) : super(key: key);
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final bool _isExpanded = false;
  final bool _showDetails = false;
  String lastPayDate = '';
  String totalPayAmount = '';
  String regId = '';
  String schemeStartDate = '';
  String schemeEndDate = '';
  String goldTakenDate = '';
  String saleamount = '';
  String saledate = '';
    String invoiceNumber = '';
    String dateOfPurchase = '';
    String refundAmount = '';
    String refundDate = '';
    String refundBillNumber = '';
    String purchaseAmount = '';
    String purchaseDate = '';
     String invoiceNo = '';
     String billNumber = '';
     String billDate = '';
     String amount = '';
     String saleamount1 = '';
     String salebill1 = '';
     String refoundamount1 = '';
     String refoundbill1 = '';

     String saleamount2 = '';
   String salebill = '';
    String refoundamount = '';
     String refoundbill = '';
     String refounddate = '';
  String totalAmount = '';
  String saleid = '';

  String schemeId = '';
List<dynamic> salesList = [];

  

   final ScrollController _scrollController = ScrollController(); // Scroll controller
  
  bool showClosedScheme = true; // Default UI is visible
  bool isApiCallSuccessful = false; // Track the API call status

   bool showscheme = true; // Default UI is visible
  bool isApiCall = false; // Track the API call status

  @override
  void initState() {
    super.initState();
    fetchClosedSchemeData();
    fetchSchemeDetails();
  }




  Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('mobile_number');
    print("Retrieved Mobile Number: $mobileNumber"); // Debugging line to check the value of mobile number
    return mobileNumber;
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



   

Future<void> fetchClosedSchemeData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    const ErrorScreen();
    return;
  }

  print("Mobile Number for Closed Scheme Data: $mobileNumber"); // Debugging

  if (mobileNumber!.isNotEmpty) {
    try {
      final url = Uri.parse('$baseUrl/closed_scheme.php'); //'https://vmrdemos.com/csc_scheme/closed_scheme.php'
      final response = await http.post(
        url,
        body: {
          'mobile_no': mobileNumber,
          'scheme_id': widget.schemeId, // 🔥 Pass schemeId here
        },
      );

      if (response.statusCode == 200) {
        print("Closed Scheme Response: ${response.body}"); // Debugging

        // Decode response as a List<dynamic> instead of Map<String, dynamic>
        final List<dynamic> responseData = json.decode(response.body);

        // Check if the response indicates no records found
      if (responseData.isEmpty || responseData[0]['response'] == "error" || responseData[0]['message'] == "no records found") {
          print("No records found for closed scheme"); // Debugging line
          // If no records are found, hide the UI and set API call failure status
          setState(() {
            showClosedScheme = false; // Hide UI when no records are found
            isApiCallSuccessful = false; // Set API call failure status
          });
        } else {
          // If records are found, display them
          setState(() {
            lastPayDate = responseData[0]['last_pay_date'] ?? ''; 
            totalPayAmount = responseData[0]['t_pay_amount'] ?? ''; 
            regId = responseData[0]['reg_id'] ?? ''; 
            showClosedScheme = true; // Show UI when records are found
            isApiCallSuccessful = true; // Set API call success status
          });
        }
      } else {
        throw Exception('Failed to load closed scheme data');
      }
    } catch (e) {
      print("Error fetching closed scheme data: $e");
      setState(() {
        showClosedScheme = false; // Hide UI if there is an error
        isApiCallSuccessful = false; // Set API call failure status
      });
    }
  } else {
    print("Mobile number is null or empty");
    setState(() {
      showClosedScheme = false; // Hide UI if mobile number is null or empty
      isApiCallSuccessful = false; // Set API call failure status
    });
  }
}



Future<void> fetchSchemeDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
    return;
  }

  print("Mobile Number for Scheme Details: $mobileNumber"); // Debugging line

  if (mobileNumber!.isNotEmpty) {
    try {
      final url = Uri.parse('$baseUrl/scheme_deatails.php');
      final response = await http.post(
        url,
        body: {
          'mobile_no': mobileNumber,
          'scheme_id': widget.schemeId.toString(), // Ensure this is also string
        },
      );

      if (response.statusCode == 200) {
        print("Scheme Details Response: ${response.body}");
        final data = json.decode(response.body);

        if (data['response'] == 'error' || data['message'] == 'No scheme found for given mobile number') {
          print("No scheme found for given mobile number");
          setState(() {
            showscheme = false;
            isApiCall = false;
          });
        } else {
          setState(() {
            schemeStartDate = data['start_date']?.toString() ?? '';
            schemeEndDate = data['end_date']?.toString() ?? '';
            totalAmount = data['total_amount']?.toString() ?? '';
            schemeId = data['scheme_id']?.toString() ?? '';
            saleamount = data['sale_amount']?.toString() ?? '';
            salebill = data['sale_bill']?.toString() ?? '';
            saledate = data['gold_taken']?.toString() ?? '';
            refoundamount = data['refund_amount']?.toString() ?? '';
            refoundbill = data['refund_bill']?.toString() ?? '';
            refounddate = data['refund_date']?.toString() ?? '';
            saleid = data['sale_id']?.toString() ?? '';
            showscheme = true;
            isApiCall = true;

            salesList = List<Map<String, dynamic>>.from(data['sales'] ?? []);
          });

          // Display sales list
          if (salesList.isNotEmpty) {
            for (var sale in salesList) {
              String saleAmount = sale['sale_amount']?.toString() ?? '0.00';
              String saleDate = sale['gold_date']?.toString() ?? '';
              String invoiceNumber = sale['invoice']?.toString() ?? '';
              print("Sale Amount: ₹$saleAmount, Date: $saleDate, Invoice: $invoiceNumber");
            }
          }
        }
      } else {
        throw Exception('Failed to load scheme details');
      }
    } catch (e) {
      print("Error fetching scheme details: $e");
    }
  } else {
    print("Mobile number is null or empty");
  }
}

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);

    if (!isApiCallSuccessful) {
      return const SizedBox(); // API call fail అయితే ఖాళీ UI
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),


        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
         //   localization.translate("Closed Scheme"),
         '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
             // color: Color.fromRGBO(43, 49, 101, 1),
             color: Colors.red
            ),
          ),
        ),
       // const SizedBox(height: 10),





  if (salesList.isNotEmpty || refoundamount.isNotEmpty) ...[
  const Padding(
    padding: EdgeInsets.only(left: 10, right: 10),
    child: Divider(),
  ),
  const Padding(
    padding: EdgeInsets.only(left: 10),
    child: Row(
      children: [
        Text(
         // "Details Of Closed Scheme", // ✅ correct spacing
          "Details Of Closed Scheme",
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),

    const Padding(
                  padding: EdgeInsets.only(left: 10,right: 10),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scheme Amount and Scheme No
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localization.translate("Scheme Amount"),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            localization.translate("Scheme No"),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                             '₹$totalAmount' , // Add Rupee symbol before the amount
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                             schemeId ,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Scheme Start and End Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localization.translate("Scheme Start Date"),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            localization.translate("Scheme End Date"),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),

                          
                        ],
                      ),

                                            Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                             schemeStartDate , // Add Rupee symbol before the amount
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                             schemeEndDate ,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ]
                  )
                )
],

//buildPadding(localization),
 


        if (_showDetails) buildPadding(localization),
        //if (!showClosedScheme)
         if (!showClosedScheme)
  Column(
    children: [

    
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            localization.translate("No records found"),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ],
  )
else 
  // Your existing code for showing the details when there are records
  buildPadding(localization),


          
      ],
    );
  }
 Widget buildPadding(LocalizationProvider localization) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
            //  _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            
            decoration: BoxDecoration(
              //border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(0),
            ),
            
            child: Column(
              children: [

               
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scheme Amount and Scheme No
                     
                      
                     
                     
                     



                Column(
  children: salesList.where((sale) {
    final amount = sale['sale_amount'];
    return amount != null && amount != 0;
  }).map((sale) {
    String saleAmount = sale['sale_amount']?.toString() ?? '0.00';
    String saleDate = sale['gold_date']?.toString() ?? '';
    String invoiceNumber = sale['invoice']?.toString() ?? '';
    String saleId = sale['sale_id']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BillSummaryScreen(saleId: saleId)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Icon(Icons.arrow_back)
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ornament Purchase Amount:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '₹$saleAmount',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date of Purchase:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  saleDate.isNotEmpty ? saleDate : '[DD-MM-YYYY]',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice Number:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  invoiceNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }).toList(),
),
                    
//else 
  const SizedBox.shrink(),  // If no sales data is available

                      const SizedBox(height: 16),

                      // Refund Details Section Box
                      (double.tryParse(refoundamount) ?? 0) > 0
                     
                     ? Container(
                        padding: const EdgeInsets.all(8.0), // Reduced padding to decrease height
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Refund Details Title
                            const Text(
                              'Refund Details',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4), // Reduced space between title and first row

                            // Refund Amount and Refund Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Refund Amount:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  refoundamount.isNotEmpty ? '₹$refoundamount' : '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4), // Reduced space between rows
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Refund Date:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  refounddate.isNotEmpty ? refounddate : ']',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4), // Reduced space between rows

                            // Refund Bill Number Field
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Refund Bill Number:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  refoundbill.isNotEmpty ? refoundbill : '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8), // Reduced space at the bottom
                          ],
                        ),
                      )
                 : const SizedBox.shrink(), 
                      const SizedBox(height: 16),

                      // View Investment Details Button
                      const SizedBox(height: 10),


                      /*
                       ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(2, 6, 67, 1),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Call fetchSchemeDetails() to fetch the scheme details first
                          fetchSchemeDetails().then((_) {
                            // After fetching scheme details, pass schemeId to the next screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JewelryTransactionScreen(schemeId: schemeId),  // Pass schemeId
                              ),
                            );
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization.translate("View Investment Details"),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                       ),

                       */
                    ],
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















}
