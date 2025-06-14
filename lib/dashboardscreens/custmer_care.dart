
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/api_services.dart/custmer_care%20api.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/localization/localizationpro.dart';


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
// Import url_launcher

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home:const CustomerCare(),
    ),
  );
}

class CustomerCare extends StatefulWidget {
  const CustomerCare({super.key});

  @override
  State<CustomerCare> createState() => _CustomerCareState();
}

class _CustomerCareState extends State<CustomerCare> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _message = '';

  String firstName = "User";
  String phoneNumber = '';

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? "User";
      _phoneController.text = prefs.getString('phoneNumber') ?? '';
      _nameController.text = firstName;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserDetails();
    requestCallPermission();
    
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


Future<void> submitForm() async {
  bool hasInternet = await ApiService().checkInternet();
  if (!hasInternet) {
   // _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
   const ErrorScreen();
    return;
  }

  if (_formKey.currentState!.validate()) {
    final responseData = await ApiService().submitForm(
      _nameController.text,
      _phoneController.text,
      _descriptionController.text,
    );

    setState(() {
      _message = responseData['response'] == 'success'
          ? 'Success: ${responseData['message']}'
          : 'Error: ${responseData['faild']}';
    });


    if (responseData['response'] == 'success') {

      _descriptionController.clear();
      // Form reset cheyyali ante:
      
    }

     Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _message = '';
      });
    });
  }
}






Future<void> makePhoneCall() async {
  const String phoneNumber = "9490657008"; // ✅ Default number
  final Uri phoneUri = Uri.parse('tel:$phoneNumber');

  try {
    bool launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    if (!launched) {
      print("Could not launch phone dialer.");
    }
  } catch (e) {
    print("Error launching phone dialer: $e");
  }
}


Future<void> requestCallPermission() async {
  var status = await Permission.phone.status;
  if (!status.isGranted) {
    await Permission.phone.request();
  }
}



  // Function to open WhatsApp chat
  void _openWhatsApp() async {
  const String phoneNumber = "9490657008"; // ✅ Default number
  final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');

  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri);
  } else {
    print("Could not open WhatsApp");
  }
}
  @override
  Widget build(BuildContext context) {
   final localization = Provider.of<LocalizationProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05;
    double fontSize = screenWidth * 0.040;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const BackButton(color: Colors.white),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
          title: Text(
           localization.translate("Enquiry Form"),
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //SizedBox(height: padding),
                  buildLabel(localization.translate('Name*'), fontSize),
                  TextFormField(
                    
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: const OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localization.translate('Please enter your name');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: padding),
                  buildLabel(localization.translate('Mobile Number*'), fontSize),


                  TextFormField(
                    readOnly: true,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: const OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localization.translate('Please enter your mobile number');
                      } else if (value.length != 10) {
                        return 'Please enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: padding),
                  buildLabel(localization.translate('Description*'), fontSize),
      
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: const OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: localization.translate('Enter your complaint details...',),
                      hintStyle: const TextStyle(fontSize: 14),
                    ),
                    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return localization.translate("Please enter description");
      }
      return null;
        },
                  ),
                  const SizedBox(height: 20),
                 
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          const Color.fromRGBO(2, 5, 62, 1),
                        ),
                      ),
                     // onPressed: submitForm,
                     onPressed: () async {
  print('📍 Submit button tapped');
  await submitForm();
},

                      
                      child: Text(
                        localization.translate('SUBMIT'),
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
      
      
                  const SizedBox(height: 10,),
      
                 Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
      GestureDetector(
        onTap: makePhoneCall,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green,
              child: Icon(Icons.phone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              localization.translate('Phone Call'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      GestureDetector(
        onTap: _openWhatsApp,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green,
              child: Icon(Icons.chat, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              localization.translate('WhatsApp Chat'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
        ],
      ),
      
      
      const SizedBox(height: 10,),
      
      
      
      const SizedBox(height: 8),
      
      
      
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child:  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adding the "Communication Address" box
        Text(
           localization.translate('Communication Address:'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
        
        SizedBox(height: 12),  // Space between the label and the address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: Color(0xFF023344), size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                   localization.translate('Csc Jewellerys'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
      localization.translate('Mandapal Street,'),
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Text(
                       localization.translate('Nellore - 524001'),
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
      localization.translate('Andhra Pradesh'),
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Text(
                     localization.translate('Mobile: 9490657008'),
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
        ),
      ),
      
      
      
      if (_message.isNotEmpty)
        Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _message.startsWith('Success') ? Colors.green[50] : Colors.red[50],
        border: Border.all(
          color: _message.startsWith('Success') ? Colors.green : Colors.red,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _message.startsWith('Success') ? Icons.check_circle : Icons.error,
            color: _message.startsWith('Success') ? Colors.green : Colors.red,
          ),
      
      
      
      
          const SizedBox(width: 10),
      
      
          Expanded(
            child: Text(
              _message,
              style: TextStyle(
                color: _message.startsWith('Success') ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.w600,
              ),
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
      ),
    );
  }

  Widget buildLabel(String label, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 5),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
