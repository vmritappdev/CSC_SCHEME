import 'dart:convert';
import 'dart:io';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/upidetails/payment%20page.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: Scanner(activescheme: Activescheme(),rejectId: '',),
    ),
  );
}

class Scanner extends StatefulWidget {
  final Activescheme activescheme;
  final String rejectId;

  const Scanner({super.key, required this.activescheme,required this.rejectId});

  

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {

  

  bool _isChecked = false;
  String installmentAmount = '';
  String installmentLabel = '';
  String installmentid = '';

   File? _selectedImage;



  void _shareImage() {
  if (_selectedImage != null) {
    try {
      Share.shareXFiles(
        [XFile(_selectedImage!.path)],
        text: "Check out this image!",
      );
    } catch (e) {
      print("Error sharing image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing image: $e")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No image to share.")),
    );
  }
}


  // Download Image
  void _downloadImage() async {
    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final fileName = _selectedImage!.path.split('/').last;
    final newFilePath = '${directory.path}/$fileName';

    final newFile = await _selectedImage!.copy(newFilePath);

    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Image saved to: ${newFile.path}")),
    );
  }



   final List<String> upiIds = [
    '9493302738-4@ybl',
    
  ];


  void _copyToClipboard(BuildContext context, String upiId) {
    Clipboard.setData(ClipboardData(text: upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$upiId"'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchInstallmentDetails();
     print("Scanner Screen -> Received Reject ID: ${widget.rejectId}");
     print("Scanner Screen - amountRs: ${widget.activescheme.amountRs}");

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

  Future<void> _fetchInstallmentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');
    String schemeId = widget.activescheme.schemeID ?? '';

    if (mobileNumber!.isEmpty) return;

 bool hasInternet = await checkInternet();
    if (!hasInternet) {
      _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
      return  ;
    }


    var url = '$baseUrl/get_installment.php';   

    try {
      final response = await http.post(Uri.parse(url), body: {
        'mobile_no': mobileNumber,
        'scheme_id': schemeId,
      });

      print('API Response: ${response.body}'); // 👈 Add this line

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['response'] == 'success' && data['status'] == 200) {
         
          setState(() {
            installmentLabel = data['installment'] ?? 'No Installment';
            installmentAmount = data['amount']?.toString() ?? '0.00'; 
            installmentid =  data['schemeNo']?.toString() ?? '';
             print("✅ Installment ID: $installmentid");
          });
        }
      }
    } catch (e) {
      print("Error fetching installment details: $e");
    }
  }

 void _navigateToPaymentScreen() {
  print("Navigating to PaymentDetailsScreen -> rejectId: ${widget.rejectId}");
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(
          payid: widget.rejectId.isNotEmpty ? widget.rejectId : widget.activescheme.payId ?? '',
          activescheme: widget.activescheme,
          
          rejectId: widget.rejectId,  // Pass rejectId from Scanner
        ),
      ),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final localization = Provider.of<LocalizationProvider>(context,listen: false);
    double labelWidth = screenWidth * 0.3; // ఉదాహరణకు 30% స్క్రీన్ వెడల్పు


    return WillPopScope(
      onWillPop: () async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme(),)),
      (route) => false, // Remove all previous routes
    );
    return false; // Prevent default back action
  },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
          centerTitle: true,
          title: Text(
            localization.translate("UPI Transaction"),
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.045,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.01,
          ),
          child: Column(
            children: [
              Text(
                localization.translate('This is a manual payment process. Please make the payment for the scheme amount using the following UPI details.'),
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
               localization.translate('CHINNI SRINIVSSULU JEWELLERS'),
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
           
              SizedBox(height: screenHeight * 0.01),
             SizedBox(
  width: screenWidth * 0.4,
  height: screenWidth * 0.5,
  child: Image.asset(
    'assets/images/qrcode.jpg', // నీ asset path ఇక్కడ పెడాలి
    fit: BoxFit.cover, // లేదా BoxFit.contain, అవసరాన్ని బట్టి మార్చవచ్చు
  ),
),

              SizedBox(height: screenHeight * 0.02),

          
   
            

           _buildDetailCard(
  title: localization.translate('UPI Details'),
  entries: [
    _buildCopyRow(
      '${localization.translate('UPI ID')}:',
      'Chinnipavan-2@okhdfcbank',
      context,
      MediaQuery.of(context).size.width,
    ),
  ],
),


_buildDetailCard(
  title: localization.translate('Bank Details'),
  entries: [
    _buildCopyRow(
      '${localization.translate('Bank Name')}:',
      'HDFC Bank',
      context,
      MediaQuery.of(context).size.width,
    ),
    _buildCopyRow(
      '${localization.translate('Account No')}:',
      '50200103097351',
      context,
      MediaQuery.of(context).size.width,
    ),
    _buildCopyRow(
      '${localization.translate('IFSC Code')}:',
      'HDFC0002043',
      context,
      MediaQuery.of(context).size.width,
    ),
    _buildCopyRow(
      '${localization.translate('A/C Holder')}:',
      'Chinni Srinivasulu Chetty Jewellers',
      context,
      MediaQuery.of(context).size.width,
    ),
  ],
),





              

 
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPaymentAppIcon('assets/images/gpay.png', screenWidth),
                  _buildPaymentAppIcon('assets/images/ptm.png', screenWidth),
                  _buildPaymentAppIcon('assets/images/phonepay.png', screenWidth),
                  _buildPaymentAppIcon('assets/images/zon.png', screenWidth),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildSchemeDetails(screenWidth),
              SizedBox(height: screenHeight * 0.02),
              _buildCheckbox(screenWidth),
              SizedBox(height: screenHeight * 0.02),
              _buildPaymentButton(screenWidth),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildPaymentAppIcon(String assetPath, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Image.asset(assetPath, width: screenWidth * 0.1),
    );
  }

  Widget _buildSchemeDetails(double screenWidth) {
     final localization = Provider.of<LocalizationProvider>(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.00),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                   localization.translate('Scheme Amount'),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.040,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.030),
                    child: Text(installmentid),
                  ),
                ],
              ),
             Column(
               children: [
                 Text(
                   ': Rs. ${widget.activescheme.amountRs.isNotEmpty == true
                       ? widget.activescheme.amountRs
                       : widget.activescheme.balanceAmount.isNotEmpty == true
                           ? widget.activescheme.balanceAmount
                           : widget.activescheme.installmentAmount.isNotEmpty == true
                  ? widget.activescheme.installmentAmount
                  : installmentAmount}', // Use fetched value finally
                   style: TextStyle(
                     color: Colors.black,
                     fontWeight: FontWeight.bold,
                     fontSize: screenWidth * 0.040,
                   ),
                 ),


                   Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.00),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  installmentLabel,
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03),
                ),
              ),
            ),
               ],
             ),






            ],
          ),
        ),
        


        


       
      ],
    );
  }

  Widget _buildCheckbox(double screenWidth) {
     final localization = Provider.of<LocalizationProvider>(context);
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (bool? value) {
            setState(() {
              _isChecked = value ?? false;
            });
          },
          activeColor: const Color.fromRGBO(2, 5, 62, 1),
        ),
        Expanded(
          child: Text(
           localization.translate('I have successfully made the payment to the provided UPI details.'),
            style: GoogleFonts.lato(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(double screenWidth) {
    final localization = Provider.of<LocalizationProvider>(context);
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(2, 5, 62, 1)),
        onPressed: _isChecked ? _navigateToPaymentScreen : null,
        child: Text(
         localization.translate("I Have Paid"), 
        style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white)),
      ),
    );
  }



String _getSchemeAmount() {
  final amountRs = widget.activescheme.amountRs;
  final balanceAmount = widget.activescheme.balanceAmount;

  if (amountRs.isNotEmpty) {
    return amountRs;
  } else if (balanceAmount.isNotEmpty) {
    return balanceAmount;
  } else {
    return '0';
  }
}



// Reusable UPI detail row
Widget buildUpiRow(String label, String value, {VoidCallback? onCopy}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.teal),
                  onPressed: onCopy,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}



Widget _buildDetailCard({required String title, required List<Widget> entries}) {
  final localization = Provider.of<LocalizationProvider>(context,listen: false);
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              )),
          const SizedBox(height: 8),
          ...entries,
        ],
      ),
    ),
  );
}

Widget _buildCopyRow(String label, String value, BuildContext context,double screenWidth) {
   final localization = Provider.of<LocalizationProvider>(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0), // కొంచెం పైకే దిగువకు gap
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center, // text vertical alignment center
      children: [
        SizedBox(
         width: screenWidth * 0.3, // మీకు తగినట్టు adjust చేయండి
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copied')),
            );
          },
          icon: const Icon(Icons.copy, size: 14, color: Colors.teal),
        ),
      ],
    ),
  );
}


}
   




   