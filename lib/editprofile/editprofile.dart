import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dainamicsizes.dart/dainamicsizes.dart';
import 'package:csc/dashboardscreens/user_profile.dart';
import 'package:csc/localization/localizationpro.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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
      home: const EditProfileScreen(),
    ),
  );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String _message = '';
  String? _savedMobileNumber;





  void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home:const EditProfileScreen(),
    ),
  );
}

  @override
  void initState() {
    super.initState();
   // loadUserDetails();  // Load user details when screen is created
    _loadSavedMobileNumber();
    loadUserDetails();  // Load saved mobile number
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
  

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    _firstNameController.text = prefs.getString('firstName') ?? '';
    _lastNameController.text = prefs.getString('lastName') ?? '';
    _phoneController.text = prefs.getString('phoneNumber') ?? '';
    _emailController.text = prefs.getString('email') ?? '';
  }

  Future<void> saveUpdatedDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstNameController.text);
    await prefs.setString('lastName', _lastNameController.text);
    await prefs.setString('phoneNumber', _phoneController.text);
    await prefs.setString('email', _emailController.text);

    
  }

  // Load saved mobile number from SharedPreferences
  Future<void> _loadSavedMobileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedMobileNumber = prefs.getString('phoneNumber') ?? '';
    });

    if (_savedMobileNumber != null && _savedMobileNumber!.isNotEmpty) {
      _phoneController.text = _savedMobileNumber!;  // Pre-fill the phone number
    }
  }

  // Update profile by sending data to the server
  Future<void> _updateProfile() async {

      bool hasInternet = await checkInternet();
    if (!hasInternet) {
      _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = ''; // Reset message while waiting for response
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reg_edit.php'),
        body: {
          'f_name': _firstNameController.text,
          'l_name': _lastNameController.text,
          'mobile_no': _savedMobileNumber ?? _phoneController.text,  // Send saved mobile or new one
          'email_id': _emailController.text,
          'new_mobile_no': _phoneController.text,  // new mobile number field
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['response'] == 'success') {
          setState(() {
            _message = 'Profile updated successfully';
          });
          
          // Save updated details in SharedPreferences
          await saveUpdatedDetails();

          // Optionally, navigate to another screen after success
          Future.delayed(const Duration(seconds: 1), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen(schemeID: '',)), // Replace with your actual next screen
    );
  });
        } else {
          setState(() {
            _message = responseData['message'] ?? 'Update failed';
          });
        }
      } else {
        setState(() {
          _message = 'Failed to update. Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'An error occurred. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      final localization = Provider.of<LocalizationProvider>(context);
     bool isSmallScreen = ScreenUtils.isSmallScreen(context);
    bool isLargeScreen = ScreenUtils.isLargeScreen(context);
    bool isMediumScreen = ScreenUtils.isMediumScreen(context);


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            children: [
              Image.asset(
                'assets/images/csc2.png',
                height: MediaQuery.of(context).size.height * 0.05,  // 5% of screen height
        width: MediaQuery.of(context).size.width * 0.2, 
                color: Colors.white,
              ),
               Text(
               localization.translate("jewellarys"),
                style: TextStyle(
                  color: Colors.white,
                 fontSize: MediaQuery.of(context).size.width * 0.035,  // 3.5% of the screen width
      
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
           padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),  // 4% of the screen width
      
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children:  [
                        Text(
                         localization.translate("Edit Profile Details"),
                          style: TextStyle(
                            color: const Color.fromRGBO(43, 49, 101, 1),
                            fontWeight: FontWeight.bold,
                           fontSize: MediaQuery.of(context).size.width * 0.05,  // 5% of the screen width
      
                          ),
                        ),
                        const Icon(Icons.person, color: Color.fromRGBO(43, 49, 101, 1)),
                      ],
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),  // 3% of the screen height
      
                    _buildTextField(localization.translate('First Name*'), _firstNameController),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),  // 2% of the screen height
      
                    _buildTextField(localization.translate('Last Name*'), _lastNameController),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),  // 2% of the screen height
      
                    _buildPhoneNumberField(),
                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),  // 2% of the screen height
      
                    _buildEmailField(),  
                    // Specific method for email
                   SizedBox(height: MediaQuery.of(context).size.height * 0.09),  // 9% of the screen height
      
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.05,  // 5% of the screen height
      
                        child: ElevatedButton(
                          onPressed:
                           _updateProfile,
      
                        // await  saveUpdatedDetails();
                          
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(2, 6, 67, 1),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          ),
                          child:  Text(
                            localization.translate('Update Profile'),
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05,  // 4% of the screen width
       color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                   SizedBox(height: MediaQuery.of(context).size.height * 0.02),  // 2% of the screen height
      
                  if (_message.isNotEmpty)
       Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
      color: _message == "Profile updated successfully"
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      border: Border.all(
        color: _message == "Profile updated successfully" ? Colors.green : Colors.red,
      ),
      borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
      children: [
        Icon(
          _message == "Profile updated successfully" ? Icons.check_circle : Icons.error,
          color: _message == "Profile updated successfully" ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            localization.translate(
              _message == "Profile updated successfully"
                ? "Profile updated successfully"
                : "Profile update failed",
            ),
            style: TextStyle(
              color: _message == "Profile updated successfully" ? Colors.green : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
        ),
      )
      
      
                  ],
                ),
              ),
            ),
            if (_isLoading) ...[
              const CircularProgressIndicator(
                strokeWidth: 4,
                color: Color.fromARGB(255, 7, 1, 39),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = true}) {
    return SizedBox(
     height: MediaQuery.of(context).size.height * 0.06,  // 5% of the screen height

      child: TextFormField(
        inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        enabled: true,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
      final localization = Provider.of<LocalizationProvider>(context);
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.06, 
      child: TextFormField(
        inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
        controller: _emailController,
        decoration: InputDecoration(
          labelText: localization.translate('Email'),
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        enabled: true,
      ),
    );
  }

 Widget _buildPhoneNumberField() {
  final localization = Provider.of<LocalizationProvider>(context);
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.06,
    child: TextFormField(
      
      readOnly: true,
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly,  FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
,],
      maxLength: 10,
      decoration: InputDecoration(
        counterText: '',
        labelText: localization.translate("Mobile Number*"),
        
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding for proper alignment
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/flag.png', // Use your own asset image path
                width: 30,
              ),
              const SizedBox(width: 6), // Space between flag and "+91"
              const Text(
                '+91',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
             // const SizedBox(width: 10), // Space between "+91" and input field
            ],
          ),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.fromLTRB(8, 12, 12, 12), // Adjust padding for text inside the field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      enabled: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone Number is required';
        }
        if (value.length != 10) {
          return 'Phone Number must be 10 digits';
        }
        return null;
      },
    ),
  );
}

}
