import 'dart:convert';

import 'package:csc/api_services.dart/view_api.dart';




import 'package:csc/chaingedscreens.dart/pd%20frecipit.dart';
import 'package:csc/chaingedscreens.dart/scner.dart';

import 'package:csc/dashboardscreens/closed_schemes.dart';

import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
      home: const JewelryTransactionScreen(schemeId: ''),
    ),
  );
}

class JewelryTransactionScreen extends StatefulWidget {
  final String schemeId;

  const JewelryTransactionScreen({super.key, required this.schemeId});

  @override
  State<JewelryTransactionScreen> createState() => _JewelryTransactionScreenState();
}

class _JewelryTransactionScreenState extends State<JewelryTransactionScreen> {
  static const Color headerBackgroundColor = Color.fromRGBO(2, 5, 62, 1);
  final Color cardBackgroundColor = Colors.white;
  static const Color titleTextColor = Color.fromRGBO(2, 5, 62, 1);
  final Color bodyTextColor = Colors.black87;
  final RefreshController _refreshController = RefreshController();

   void _onRefresh() async {
  await fetchData(); // Wait for fresh data
  _refreshController.refreshCompleted(); // Then complete refresh
}

   //String mobile_number = "Loading...";

  bool isLoading = true;
  String name = "";
  String phone = "";
  String regNo = "";
  
  String  totalAmount = '';
   String  amount = '';
  String balanceAmount = '';
  String paidInstallments = "0";

  bool showDialogFlag = false;

  bool isMyScreenCalled = false; 
 
  
  List accountDetails = [];
  String message = "";

   bool isNoRecordsFound = false; // Add this flag to track if no records are found.

 // bool isMyScreenCalled = false; // Add this at the top of your StatefulWidget class.
  
 late bool allPaid;

 @override
 void initState() {
   super.initState();
    print("Received Scheme ID in JewelryTransactionScreen: ${widget.schemeId}");
   // fetchActiveSchemes();
   fetchData();
   verifyPaymentProcess();
   allPaid = accountDetails.isNotEmpty && accountDetails.every((installment) {
     return installment['payment_status'].toString() == '0';

     
   });
 }





  

 Future<void> fetchData() async {
    final data = await fetchInstallmentHistory(widget.schemeId);

    if (data == null) {
      setState(() {
        message = "Failed to load data.";
        isLoading = false;
      });
      return;
    }

    if (data['status'] == 200 && data['message'] == "Successfull Response") {
      setState(() {
        name = data['name'] ?? 'N/A';
        phone = data['phone_no'] ?? 'N/A';
        regNo = data['reg_no'] ?? 'N/A';
        paidInstallments = data['paid_installments']?.toString() ?? '0';
        message = data['message'];
        isLoading = false;

        totalAmount = data['total_paid_amount']?.toString() ?? '0';
        balanceAmount = data['balance_amount']?.toString() ?? '0';
        amount = data['amount']?.toString() ?? '0';

        final accountData = data['account_details'];
        if (accountData != null && accountData is List) {
          accountDetails = accountData
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else {
          accountDetails = [];
        }
      });
    } else {
      setState(() {
        message = data['message'] ?? 'Something went wrong';
        accountDetails = [];
        isLoading = false;
      });
    }
  }



Future<void> verifyPaymentProcess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');

    print("📱 Mobile Number for API: $mobileNumber");

    final url = Uri.parse('https://vmrdemos.com/csc_scheme/payment_process_verification.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'mobile_no': mobileNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("🔍 API Response: $data");

        if (data['response'] == 'success') {
          print("✅ Verification Successful");
        } else {
          print("⚠️ API Error: ${data['message']}");
        }
      } else {
        print("❌ Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error during API call: $e");
    }
  }





  Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mobile_number');
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
 






  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context,listen: false);
     double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
   

    return SafeArea(
      child: Scaffold(
       // backgroundColor: const Color.fromARGB(255, 212, 210, 210),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: headerBackgroundColor,
          centerTitle: true,
          title: Text(
            localization.translate("Installments History"),
            style: TextStyle(
              fontSize: 18* MediaQuery.of(context).textScaleFactor,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SmartRefresher(
               controller: _refreshController,
          onRefresh: _onRefresh,
      
            header: WaterDropHeader(
            complete: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text("Refresh Completed", style: TextStyle(color: Colors.green)),
              ],
            ),
           waterDropColor: const Color.fromARGB(255, 4, 2, 29),
          ),
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildUserInfo(localization),
                      ...accountDetails.map((installment) {
                        return _buildTransactionCard(
               installmentNumber: accountDetails.indexOf(installment) + 1,
                  date: installment['date'],
                  receiptNo: installment['receipt_no'],
                  amount: installment['amount'],
                  payid: installment['pay_id'],
                  paymentStatus: installment['payment_status']?.toString() ?? "0", // Ensure payment_status is a String
                  installment: installment['installment']?.toString() ?? '0', // Ensure installment is a String
                  context: context,
                );
                      }),
              
              
              
                        MyScreen(schemeId: widget.schemeId,),
                       
              
              
              
              
              
                      
                    ],
              
              
                    
                  ),
                ),
            ),
      ),
    );
  }

  Widget _buildUserInfo(LocalizationProvider localization) {
  int totalInstallments = 11;
  int paid = int.tryParse(paidInstallments) ?? 0;
  double progress = (paid / totalInstallments).clamp(0.0, 1.0);

  return Column(
    children: [

      
     Container(
  margin: const EdgeInsets.all(16), // Space outside the box
  padding: const EdgeInsets.all(16), // Space inside the box
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12), // Rounded corners
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3), // Shadow color
        spreadRadius: 2,
        blurRadius: 8,
        offset: const Offset(0, 3), // Shadow position
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.01),

      

      // Total Paid Amount Label
      Row(
        children: [
          Text(
            localization.translate("Total Paid Amount"),
            style: GoogleFonts.lato(
              color: Colors.black, 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),


    
      // Total Amount + Installment Amount
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.green),

          Text(
            "₹ $totalAmount",
            style: GoogleFonts.lato(
              color: Colors.green, 
              fontWeight: FontWeight.bold, 
              fontSize: 18 * MediaQuery.of(context).textScaleFactor,
            ),
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.04),

          Text(
            "Installment ₹$amount",
            style: GoogleFonts.lato(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12 * MediaQuery.of(context).textScaleFactor,
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      // Progress Indicator
      LinearProgressIndicator(
        value: progress, // Your progress value (0.0 to 1.0)
        color: Colors.green,
        backgroundColor: Colors.grey.shade300,
        minHeight: 8,
      ),

      const SizedBox(height: 12),

      // Outstanding Amount
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localization.translate("Outstanding Amount"),
            style: GoogleFonts.lato(
              color: Colors.red, 
              fontWeight: FontWeight.bold
            ),
          ),
          const Text(':', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(
            '₹ $balanceAmount',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ],
  ),
),



      SizedBox(
       // height: 50,
        width: double.infinity,
        child: Card(
      margin: EdgeInsets.symmetric(
  vertical: MediaQuery.of(context).size.height * 0.01, // 1% of screen height
  horizontal: MediaQuery.of(context).size.width * 0.04, // 4% of screen width
),

          //  color: cardBackgroundColor,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
            ),
          child: Column(

            children: [ 

             // SizedBox(height: 30,) ,
             

           Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
  Text(
            capitalizeEachWord(name), // Capitalize each word
            style: GoogleFonts.lato(
              color: const Color.fromRGBO(2, 5, 67, 1),
              fontWeight: FontWeight.bold,
              fontSize: 14 * MediaQuery.of(context).textScaleFactor,
            ),
          ),

                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(phone, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    infoRow('Scheme No',regNo),
                    infoRow('Total Installments',   '$totalInstallments'),
                    infoRow('Paid Installments',    paidInstallments,),
                  ],
                ),
              ),
        
        ],
          ),
        ),
      ),



    
    ],
  );
}



 Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }




Widget _buildTransactionCard({
  required int installmentNumber,
  required String installment,
  required String date,
  required String receiptNo,
  required String amount,
  required String payid,
  required String paymentStatus,
  required BuildContext context,
}) {
  var localization = Provider.of<LocalizationProvider>(context);
  double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;


  


String status = paymentStatus.toString().trim(); // ✅ Trim చెయ్యడం ముఖ్యం
print("DEBUG: Processed payment_status = '$status'"); // ✅ Debugging print
 localization = Provider.of<LocalizationProvider>(context, listen: false);

Color paymentStatusColor;
String paymentStatusText;
IconData? paymentStatusIcon;

switch (status) {
  case "1":
    paymentStatusColor = Colors.green;
    paymentStatusText = localization.translate("Completed");
    paymentStatusIcon = Icons.check; 
    break;
  case "2":
    paymentStatusColor = Colors.green;
    paymentStatusText = localization.translate("Pay");
     paymentStatusIcon = Icons.payment; // Icon చూపించకూడదు అంటే
    
    break;
  case "0":
    paymentStatusColor = Colors.orange;
    paymentStatusText = localization.translate("Process");
    paymentStatusIcon = Icons.hourglass_empty;
    break;
  default:
    paymentStatusColor = Colors.grey;
    paymentStatusText = localization.translate("Unknown");
    paymentStatusIcon = Icons.help_outline;
    break;
}
  

  return SizedBox(
   // height: 190,
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      //color: cardBackgroundColor,
       color: Colors.white, // White background
    shadowColor: Colors.grey.withOpacity(0.3), // Optional: shadow color
    elevation: 4, // Elevation for subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // 4% of screen width
    
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    
    
      
     Text(
    localization.translate(installment),
    style: GoogleFonts.lato(
      fontSize: 14,
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
    ),
    
      
    GestureDetector(
    onTap: paymentStatusText == "Pay" 
     // onTap: paymentStatusText == localization.translate("pay") // Compare with the localized string
        ? () {
            // Fetch required details from accountDetails
            if (accountDetails.isNotEmpty) {
              final String amount = accountDetails[0]['amount'] ?? '0'; // Assuming you want the first record
              final String id = accountDetails[0]['id'] ?? '';
              final String month = accountDetails[0]['month'] ?? '';
              final String year = accountDetails[0]['year'] ?? '';
              final String payId = accountDetails[0]['pay_id'] ?? ''; // Fetch the pay_id
    
              // Print the fetched details for verification
              print("Reject clicked: Amount: $amount, ID: $id, Month: $month, Year: $year, Pay ID: $payid");
    
              // Pass the details to the next screen using arguments
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scanner(activescheme: Activescheme(
                    amountRs: amount,
                    month: month,
                    year: year,
                    payId: payId
                    
                  ),
                  rejectId: payId,
                  ),
    
    
                ),
              );
            } else {
              print("No account details available");
            }
          }
        : null, // For other statuses, no action will be triggered
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.005,
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      decoration: BoxDecoration(
        color: paymentStatusText == "pay" ? Colors.green : paymentStatusColor, // Dynamic color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paymentStatusIcon,
            color: Colors.white,
            size: 12 * MediaQuery.of(context).textScaleFactor,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Text(
            paymentStatusText, // Dynamic status text
            style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 12),
          ),
        ],
      ),
    
    
    ),
    ),
    
    ],
    ),
    
    
    
    
         
    
           
    
     SizedBox(height: MediaQuery.of(context).size.height * 0.012), // 1.2% of screen height
    
                _buildTransactionRow(localization.translate("Date"), date),
                _buildTransactionRow(localization.translate("Receipt No."), receiptNo),
                _buildTransactionRow(localization.translate("Amount"), amount),
    
    
              SizedBox(height: MediaQuery.of(context).size.height * 0.012), // 1.2% of screen height
    
    
    GestureDetector(
    onTap: (paymentStatusText == localization.translate("Completed")) 
        ? () async {
            print("Downloading for ID: ${widget.schemeId}");
            ReceiptPDFGenerator pdfGenerator = ReceiptPDFGenerator(payId: payid);
            await pdfGenerator.generatePDF(context);
          }
        : (paymentStatusText == localization.translate("Reject") || 
           paymentStatusText == localization.translate("Process"))
            ? () {
                _showErrorDialog(context, message);
              }
            : null,
    child: Opacity(
      opacity: paymentStatusText == localization.translate("Completed") ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: paymentStatusText != localization.translate("Completed"),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.005,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(2, 5, 62, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 12 * MediaQuery.of(context).textScaleFactor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    localization.translate("Download"),
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    
    
    
              ],
            ),
          ),
         
        ],
      ),
    ),
  );
}





void _showErrorDialog(BuildContext context, String message) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => Dialog(
      shape: const RoundedRectangleBorder(
       // borderRadius: BorderRadius.circular(16), // Rounded corners for dialog
      ),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dialog content
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.03, // Dynamic vertical padding
              horizontal: screenWidth * 0.05, // Dynamic horizontal padding
            ),
            child: Column(
              children: [
                // Info Icon with Blue Background
                CircleAvatar(
                  radius: screenWidth * 0.06, // Dynamic icon size
                  backgroundColor: Colors.red.shade100,
                  child: Icon(
                    Icons.error_outline, // Error icon
                    color: Colors.red,
                    size: screenWidth * 0.10, // Dynamic icon size
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Title Text
                Text(
                 localization.translate("Your payment has been rejected, so the download operation will not work."),
// Title
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03, // Dynamic text size
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // Title color
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Message Text
               
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),

          // Full-Width Button at the Bottom
          Container(
            width: double.infinity, // Full width button
            decoration: const BoxDecoration(
              color: Color.fromRGBO(2, 5, 62, 1), // Button background color
              borderRadius: BorderRadius.only(
              //  bottomLeft: Radius.circular(16),
               // bottomRight: Radius.circular(16),
              ), // Rounded corners at the bottom
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close popup
              },
              child: Text(
                localization.translate("OK"), // OK Button Text
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045, // Dynamic font size
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}




 Widget _buildTransactionRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: .0), // Added horizontal padding for better alignment
    child: Row(
      children: [
        Expanded(
          flex: 3, // Ensures label text aligns properly
          child: Text(
            label,
            style:GoogleFonts.lato(fontWeight: FontWeight.bold, color: bodyTextColor,fontSize: 12),
          ),
        ),

       
        Expanded(
          flex: 2, // Keeps values aligned properly
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: GoogleFonts.lato(color: bodyTextColor,fontSize: 12),
            ),
          ),
        ),
      ],
    ),
  );
}

  String getInstallmentSuffix(int installmentNumber) {
    if (installmentNumber == 1) return '1st Installment';
    if (installmentNumber == 2) return '2nd Installment';
    if (installmentNumber == 3) return '3rd Installment';
    return '$installmentNumber' 'th Installment';
  }

  void downloadRecepit(String receiptNo) {
    // Logic to handle the invoice download based on the receipt number
    print("Downloading invoice for receipt no: $receiptNo");

    // Example: Send request to the server or download file logic here.
  }


 String capitalizeEachWord(String text) {
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}



  
}
