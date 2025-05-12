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
import 'package:qr_flutter/qr_flutter.dart';
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


    const url = '$baseUrl/get_installment.php';   //'https://vmrdemos.com/csc_scheme/get_installment.php'

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
    final localization = Provider.of<LocalizationProvider>(context);

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

          
    const Align(
      alignment: Alignment.centerLeft,
      child: Text(
                'UPI Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
    ),
            const SizedBox(height: 8),

             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('UPI ID:', style: TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 45),
                      child: Text('Chinnipavan-2@okhdfcbank'),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: 'Chinnipavan-2@okhdfcbank'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('UPI ID copied')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 13, color: Colors.teal),
                    ),
                  ],
                ),
              ],
            ),


Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Bank Details',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.teal,
      ),
    ),
   // const SizedBox(height: 8),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Bank Name:', style: TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 130),
              child: Text('HDFC Bank',style: TextStyle(fontSize: 12)),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'HDFC Bank'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bank Name copied')),
                );
              },
              icon: const Icon(Icons.copy, size: 13, color: Colors.teal),
            ),
          ],
        ),
      ],
    ),

  //  const SizedBox(height: 6),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Account No:', style: TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 95),
              child: Text('50200103097351',style: TextStyle(fontSize: 12)),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: '50200103097351'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account number copied')),
                );
              },
              icon: const Icon(Icons.copy, size: 13, color: Colors.teal),
            ),
          ],
        ),
      ],
    ),

   // const SizedBox(height: 6),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('IFSC Code:', style: TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 115),
              child: Text('HDFC0002043',style: TextStyle(fontSize: 12)),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'HDFC0002043'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IFSC Code copied')),
                );
              },
              icon: const Icon(Icons.copy, size: 13, color: Colors.teal),
            ),
          ],
        ),
      ],
    ),

   // const SizedBox(height: 6),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('A/C Holder:', style: TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            const Text('Chinni Srinivasulu Chetty Jewellers',style: TextStyle(fontSize: 12),),
            IconButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'Chinni Srinivasulu Chetty Jewellers'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account Holder copied')),
                );
              },
              icon: const Icon(Icons.copy, size: 13, color: Colors.teal),
            ),
          ],
        ),
      ],
    ),


      SizedBox(height: screenHeight * 0.01),

   
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
              Text(
               localization.translate('Scheme Amount'),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                ),
              ),
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
    fontSize: screenWidth * 0.045,
  ),
),



            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.00),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              installmentLabel,
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
            ),
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


}
