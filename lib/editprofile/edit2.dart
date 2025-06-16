import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/dashboardscreens/view%20details.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/constant.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: Editscheme(schemeId: ''),
    ),
  );
}


enum ImageType {
  pan,
  adhar,
  nominee,
}

class Editscheme extends StatefulWidget {
  final String schemeId;
  Editscheme({required this.schemeId});

  @override
  _EditschemeState createState() => _EditschemeState();
}

class _EditschemeState extends State<Editscheme> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController doorNoController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController adharController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController branchLocationController = TextEditingController();
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController nomineeMobileController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController nomineeRelationship = TextEditingController();
  final TextEditingController holderName = TextEditingController();
  final TextEditingController emailController = TextEditingController();
final TextEditingController schemController = TextEditingController();
final TextEditingController countryController = TextEditingController();
final TextEditingController nomineeadharController = TextEditingController();
final TextEditingController otherController = TextEditingController();
final TextEditingController gendController = TextEditingController();

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


bool isUnder18 = false;

  String? adharImage;
  String? panImage;
  String? nomineeImage;
 // String? nomineeimage;
  bool isLoading = true;
    File? _image;

    bool isNomineeImageValid = true;


  final ImagePicker _picker = ImagePicker();

  List<String> relationships = ['Mother', 'Father', 'Brother', 'Sister', 'Wife', 'Husband','Other'];
String? selectedRelationship;

String? selectedGender;
bool isOtherRelationVisible = false;



  @override
  void initState() {
    super.initState();
    loadSavedImages();
    fetchSchemeDetails();
  }


  String schemeAmount = ''; // Holds Scheme Amount
String regId = '';        // Holds Registration ID



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
              decoration: BoxDecoration(
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


  Future<void> updateSchemeDetails() async {
        final localization = Provider.of<LocalizationProvider>(context,listen: false);

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");
      return  ;
    }


  final url = Uri.parse('$baseUrl/edit_reg_app.php');

  print("🔵 Sending data to API: $url");
  
  final body = {
    'id': widget.schemeId.toString(),  
    'scheme_amount': '15000', 
    'f_name': firstNameController.text,
    'l_name': lastNameController.text,
    'mobile_no': phoneController.text,
    'date_of_birth': dobController.text,
    'email_id': emailController.text,  
    'door_no': doorNoController.text,
    'address_line1': address1Controller.text,
    'address_line2': address2Controller.text,
    'city': cityController.text,
    'pincode': pincodeController.text,
    'country': 'India',
    'state': stateController.text,
    'disrict': districtController.text,
    'referral': referralController.text,
    'bank_name': bankNameController.text,
    'holder_name': holderName.text,
    'account_no': accountNoController.text,
    'ifsc_code': ifscCodeController.text,
    'branch_location': branchLocationController.text,
    'nominee_name': nomineeNameController.text,
    'relationship': nomineeRelationship.text,
    'nominee_mobile': nomineeMobileController.text,
    'adhar_no': adharController.text,
    'pan_no': panController.text,
    'scheme_type': 'Gold',
    'nominee_adhar': nomineeadharController.text,
    'otherRelationship': otherController.text,
    'gender': selectedGender ?? '' ,
  };



    panImage = (body['pan_image'] != null && body['pan_image']?.isNotEmpty == true)
              ? '$baseUrl/images/${body['pan_image']}'
              : '';

          adharImage = (body['adhar_image'] != null && body['adhar_image']?.isNotEmpty == true)
              ? '$baseUrl/images/${body['adhar_image']}'
              : '';

          nomineeImage = (body['nominee_adhar_image'] != null &&
                  body['nominee_adhar_image']?.isNotEmpty == true)
              ? '$baseUrl/images/${body['nominee_image']}'
              : '';


  print("📤 Request Body: $body");

  try {
    final response = await http.post(url, body: body);

    print("🟢 Response Status Code: ${response.statusCode}");
    print("🟡 Raw Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ Decoded JSON Data: $data");

      if (data['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          
          SnackBar(content: Text(localization.translate("✅ Scheme updated successfully!"),
          style: GoogleFonts.lato(color: Colors.white),),backgroundColor: Color.fromRGBO(2, 5, 62, 1),),
        );

        Future.delayed(Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => JewelryTransactionScreen(schemeId: widget.schemeId)), // Replace with your actual next screen
    );
  });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Update failed: ${data['message']}")),
        );
      }
    }
  } catch (e) {
    print("❌ Error updating scheme: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed to update scheme.")),
    );
  }
}

  /// **🔹 SharedPreferences లో స్టోర్ చేసిన ఇమేజ్‌లు లోడ్ చేయడం**
  Future<void> loadSavedImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adharImage = prefs.getString('adharImage');
      panImage = prefs.getString('panImage');
      nomineeImage = prefs.getString('nomineeImage');
    });
  }

  /// **🔹 Scheme Details API నుండి డేటా తీసుకోవడం**
  Future<void> fetchSchemeDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');
    if (mobileNumber == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('$baseUrl/get_scheme_details.php');
    try {
      final response = await http.post(url, body: {
        'mobile_no': mobileNumber,
        'scheme_id': widget.schemeId.toString(),
      });

      print("🟢 Response Status Code: ${response.statusCode}");
print("🟡 Raw Response Body: ${response.body}"); // **👉 PRINT THE FULL RESPONSE HERE**

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 && data['message'] == "Successfull Response") {
          var details = data['scheme_details'][0];

         print("📸 PAN Image: ${details['pan_image']}");
    print("📸 Aadhar Image: ${details['adhar_image']}"); 
    print("📸 Nominee Image: ${details['nominee_adhar_image']}"); 
          setState(() {
           firstNameController.text = details['f_name'] ?? 'N/A';
  lastNameController.text = details['l_name'] ?? 'N/A';
  phoneController.text = details['mobile_no'] ?? 'N/A';
  dobController.text = details['date_of_birth'] ?? 'N/A';
  address1Controller.text = details['address_line1'] ?? 'N/A';
  address2Controller.text = details['address_line2'] ?? 'N/A';
  cityController.text = details['city'] ?? 'N/A';
   selectedGender = details['gender'];
  nomineeRelationship.text = details['relationship'] ?? 'N/A';
    otherController.text = details['other_relationship'] ?? 'N/A';
  selectedRelationship = details['relationship']; // **Here we set the dropdown value**
  districtController.text = details['disrict'] ?? 'N/A';
  stateController.text = details['state'] ?? 'N/A';
  pincodeController.text = details['pincode'] ?? 'N/A';
  countryController.text = details['country'] ?? 'N/A';
  adharController.text = details['adhar_no'] ?? 'N/A';
  panController.text = details['pan_no'] ?? 'N/A';
  doorNoController.text = details['door_no'] ?? 'N/A';
  bankNameController.text = details['bank_name'] ?? 'N/A';
  accountNoController.text = details['account_no'] ?? 'N/A';
  ifscCodeController.text = details['ifsc_code'] ?? 'N/A';
  branchLocationController.text = details['branch_location'] ?? 'N/A';
  nomineeMobileController.text = details['nominee_mobile'] ?? 'N/A';
  nomineeNameController.text = details['nominee_name'] ?? 'N/A';
  referralController.text = details['referral'] ?? 'N/A';
  holderName.text = details['holder_name'] ?? 'N/A';
  emailController.text = details['email_id'] ?? 'N/A';
  schemController.text = details['scheme_type'] ?? 'N/A';
  nomineeadharController.text = details['nominee_adhar']  ?? 'N/A';

   final apiRelationship = details['relationship']?.toString().trim();

   if (apiRelationship == null || apiRelationship.isEmpty) {
            selectedRelationship = null;
          } else {
            selectedRelationship = apiRelationship;
            if (!relationships.contains(apiRelationship)) {
              relationships.add(apiRelationship);
            }
          }

          nomineeRelationship.text = selectedRelationship ?? '';
          isOtherRelationVisible = selectedRelationship == 'Other';
          otherController.text = details['other_relationship'] ?? '';


schemeAmount = details['scheme_amount'] ?? 'N/A';
          regId = details['reg_id'] ?? 'N/A';

           panImage = (details['pan_image'] != null && details['pan_image'].isNotEmpty)
      ? '$baseUrl/images/${details['pan_image']}'
      : '';

  adharImage = (details['adhar_image'] != null && details['adhar_image'].isNotEmpty)
      ? '$baseUrl/images/${details['adhar_image']}'
      : '';

      nomineeImage = (details['nominee_adhar_image'] != null && details['nominee_adhar_image'].isNotEmpty)
  ? '$baseUrl/images/${details['nominee_adhar_image']}'
  : '';

          });
        }
      }
    } catch (e) {
      print("Error fetching scheme details: $e");
    }
    setState(() => isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(localization.translate("Edit Scheme",),
      style: TextStyle(color: Colors.white),
      ),
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Color.fromRGBO(2, 6, 67, 1),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                  
                  
                  
                      Align(child: Text(localization.translate("Edit Customer Information"),
                      style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black)),
                      alignment: Alignment.bottomLeft,
                      ),
                  
                  
                  
                  
                      Row(
                        children: [
                         Text(
  "${localization.translate("Scheme Amount")} ₹$schemeAmount",
  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
),

                  
                              SizedBox(width: 15,),
                  
                              Text(
  "${localization.translate("Scheme No")} $regId",
  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
),

                        ],
                      ),
                  
                  
                        SizedBox(
                       height: MediaQuery.of(context).size.height * 0.02, // 6% of screen height
                     ),
                     
                     //_buildTextField(schemController, localization.translate("Scheme Type")),
                      _buildTextField(firstNameController, localization.translate("First Name*"),readOnly: true),
                      _buildTextField(lastNameController, localization.translate("Last Name*"),readOnly: true),
                      _buildTextField(phoneController, localization.translate("Mobile Number*"), readOnly: true),
                        SizedBox(
                      // height: MediaQuery.of(context).size.height * 0.02, // 6% of screen height
                     ),
                    //  _buildTextField(dobController, localization.translate("Date of Birth*")),
                  
                   _buildDateField(
  dobController,
  localization.translate("Date of Birth*"),
  isRequired: true,
  errorMessage: localization.translate("Please select date of birth"),
),

                  
                     SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
                  
                  
                      _buildEmailField(),
                  
                        
                     
                     SizedBox(
                       height: MediaQuery.of(context).size.height * 0.03, // 6% of screen height
                     ),
                  
                        genderDropdown(context),

                        
                         SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
_buildTextField(
  doorNoController,
  localization.translate("Door No*"),
    isRequired: true,
  errorMessage: localization.translate("Please enter Door Number"),
),

                      _buildTextField(
  address1Controller,
  localization.translate("Address Line 1*"),
  isRequired: true,
  errorMessage: localization.translate("Please enter Address Line 1"),
),

                      _buildTextField(address2Controller, localization.translate("Address Line 2/Land Mark")),
                          _buildTextField(
  pincodeController,
  localization.translate("Pincode*"),
    isRequired: true,
  errorMessage: localization.translate("Please enter Pincode"),
),

                          _buildTextField(
  countryController,
  localization.translate("Country*"),
  isRequired: true,
  errorMessage: localization.translate("Please enter country"),
),

_buildTextField(
  stateController,
  localization.translate("State*"),
  isRequired: true,
  errorMessage: localization.translate("Please enter state"),  // add this line
),
                     _buildTextField(
  districtController,
  localization.translate("District*"),
    isRequired: true,
  errorMessage: localization.translate("Please enter district"),
),

                        _buildTextField(
  cityController,
  localization.translate("City*"),
  isRequired: true,
  errorMessage: localization.translate("Please enter city"),
),

                      _buildDocumentRow(localization.translate("Aadhar Number*"), adharController, adharImage,12, false,),
                        _buildDocumentRow(localization.translate("PAN Card Number*"), panController, panImage,10, true),
                     
                       _buildTextField(referralController,localization.translate( "Referral Name/Number")),
                  
                         SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
                  
                       Align(child: Text('Bank Deatails',style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                       alignment: Alignment.bottomLeft,
                       ),
                  
                         SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
                     _buildTextField(
  bankNameController,
  localization.translate("Bank Name*"),
  isRequired: true,
  errorMessage: localization.translate("Please enter bank name"),
),

_buildTextField(
  holderName,
  localization.translate("Bank Account Holder Name*"),
    isRequired: true,
  errorMessage: localization.translate("Please enter account holder name"),
),

_buildTextField(
  accountNoController,
  localization.translate("Bank Account No*"),
    isRequired: true,
  errorMessage: localization.translate("Please enter account number"),
),

_buildTextField(
  ifscCodeController,
  localization.translate("IFSC Code"),
    isRequired: true,
  errorMessage: localization.translate("Please enter IFSC code"),
),

_buildTextField(
  branchLocationController,
  localization.translate("Branch Location*"),
    isRequired: true,
  errorMessage: localization.translate("Please enter branch location"),
),

                     
                  
                           SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
                  
                       Align(child: Text('Nominee Deatails',style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                       alignment: Alignment.bottomLeft,
                       ),
                  
                         SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
_buildTextField(
  nomineeNameController,
  localization.translate("Nominee Full Name"),
    isRequired:false,
  errorMessage: localization.translate("Please enter nominee full name"),
),

                  
                      
                  
                      
                    buildnominee(),
                  
                      //  _buildTextField(nomineeadharController, localization.translate("Nominee Adhaar Number"),maxLength: 12,keyboardType: TextInputType.number),
                  
                  
                         _buildNomineeRelationshipDropdown(),
                                if (isOtherRelationVisible) _buildOtherRelationshipField(),
                  
                      _buildTextField(nomineeMobileController, localization.translate("Nominee Phone Number (Optional)")),
                     
                     // _buildTextField(nomineeRelationship, localization.translate("Nominee Relationship*")),
                                 
                    
                     
                       
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025), // 2.5% of screen height
                  
                  
                    SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
  FocusScope.of(context).unfocus();

  // Check form validation
  bool isFormValid = _formKey.currentState!.validate();

  // Nominee image validation
  if (_image == null && (nomineeImage == null || nomineeImage!.isEmpty)) {
    isNomineeImageValid = false;
    isFormValid = false;
  } else {
    isNomineeImageValid = true;
  }

  setState(() {}); // Refresh UI to show error if needed

  if (isFormValid) {
    await updateSchemeDetails();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.translate("Please fill in all the mandatory fields."))),
    );
  }
},

    child: Text(
      localization.translate("Save Changes"),
      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
    ),
  ),
)

                    ],
                  ),
                ),
              ),
            ),
    );
  }

_buildDocumentRow(
  String label,
  TextEditingController controller,
  String? imageUrl,
  int? maxLength,
  bool isPanCard, {
  bool readOnly = true,
}) {
  return Row(
    children: [
      Expanded(
        child: _buildTextField(
          controller,
          label,
          readOnly: readOnly,
          maxLength: maxLength, // ✅ Pass maxLength here
        ),
      ),
      SizedBox(width: MediaQuery.of(context).size.width * 0.025),
      _buildImageWidget(imageUrl, isPanCard),
    ],
  );
}

 Widget _buildImageWidget(String? imageUrl, bool isPanCard) {
  return GestureDetector(
    onTap: () {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.9), // dark background
          builder: (_) => Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
              Center(
                child: Hero(
                  tag: imageUrl,
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.clear, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.width * 0.15,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            )
          : Icon(Icons.image, size: 40, color: Colors.grey),
    ),
  );
}


Widget _buildTextField(
  TextEditingController controller,
  String label, {
  bool readOnly = false,
  int? maxLength,
  TextInputType keyboardType = TextInputType.text,
  bool isRequired = false,
  String? errorMessage, // 👈 New parameter
}) {
  Provider.of<LocalizationProvider>(context, listen: false);

  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.height * 0.01,
    ),
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r"[#&']")),
        ],
        readOnly: readOnly,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12),
          counterText: '',
          border: OutlineInputBorder(),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade200 : null,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return errorMessage; // 👈 Show custom message
          }
          return null;
        },
      ),
    ),
  );
}







Widget _buildDateField(
  TextEditingController controller,
  String label, {
  bool isRequired = false,
  String? errorMessage,   // 👈 add this
}) {
   final localization = Provider.of<LocalizationProvider>(context,listen: false);
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.height * 0.01,
    ),
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return errorMessage;  // 👈 use errorMessage if provided
          }
          if (isUnder18) {
            return localization.translate('You must be at least 18 years old');
          }
          return null;
        },
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            int age = _calculateAge(pickedDate);
            if (age < 18) {
              controller.clear();
              _showUnderAgeSnackbar();
              setState(() {
                isUnder18 = true;
              });
            } else {
              String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
              controller.text = formattedDate;
              setState(() {
                isUnder18 = false;
              });
            }
          }
        },
      ),
    ),
  );
}

int _calculateAge(DateTime birthDate) {
  DateTime today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}


void _showUnderAgeSnackbar() {
   final localization = Provider.of<LocalizationProvider>(context,listen: false);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        localization.translate("❌ Users under 18 years of age are not allowed."),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}




Widget _buildNomineeRelationshipDropdown() {
   final localization = Provider.of<LocalizationProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: relationships.contains(selectedRelationship)
            ? selectedRelationship
            : null,
        decoration:  InputDecoration(
          labelText:localization.translate("Nominee Relationship*"),labelStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(),
        ),
        items: relationships.toSet().map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
         validator: (value) {
        if (value == null || value.isEmpty) {
          return localization.translate('Please select nominee relationship');
        }
        return null;
      },
        onChanged: (String? newValue) {
          setState(() {
            selectedRelationship = newValue;
            nomineeRelationship.text = newValue ?? '';
            isOtherRelationVisible = newValue == 'Other';
          });
        },
      ),
    );
  }


Widget _buildEmailField() {
  final localization = Provider.of<LocalizationProvider>(context);
  return SizedBox(
    child: TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r"[#&']")), // Blocks # & '
      ],
      controller: emailController,
      decoration: InputDecoration(
        labelText: localization.translate("Email ID(Optional)"),
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      enabled: true,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction, // auto validation
     validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Optional field, empty is allowed
  }
  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  if (!emailRegex.hasMatch(value.trim())) {
    return localization.translate("Please enter a valid email address");
  }
  return null; // Valid email
},

    ),
  );
}




  Widget _buildOtherRelationshipField() {
      final localization = Provider.of<LocalizationProvider>(context);
    return Visibility(
      visible: isOtherRelationVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
          controller: otherController,
          decoration:  InputDecoration(
            labelText: localization.translate("Enter Custom Relationship"),labelStyle: TextStyle(fontSize: 12),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
          if (isOtherRelationVisible) {
            if (value == null || value.trim().isEmpty) {
              return localization.translate("Please enter custom relationship");
            }
          }
          return null;
        },
        ),
      ),
    );
  }


Widget genderDropdown(BuildContext context) {
  final localization = Provider.of<LocalizationProvider>(context);

  // Step 1: Dropdown items list
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  // Step 2: Check if selectedGender is valid
  if (!genderOptions.contains(selectedGender)) {
    selectedGender = null;
  }

  return SizedBox(
    height: 50,
    child: DropdownButtonFormField<String>(
      value: selectedGender, // Step 3: Use only valid value
      onChanged: (String? newValue) async {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          selectedGender = newValue;
        });
        await prefs.setString('gender', selectedGender ?? '');
      },
      decoration: InputDecoration(
        labelText: localization.translate('Gender*'),
        labelStyle: GoogleFonts.lato(),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(2, 5, 62, 1), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color.fromARGB(255, 18, 5, 93), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        floatingLabelStyle: const TextStyle(color: Color.fromRGBO(2, 9, 90, 1)),
      ),
      items: genderOptions
          .map((String gender) => DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
          validator: (value) {
        if (value == null || value.isEmpty) {
          return localization.translate('Please select gender');
        }
        return null;
      },
    ),
  );
}



Future<void> _pickImage1(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              _pickImage1(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage1(ImageSource.gallery );
            },
          ),
        ],
      ),
    );
  }





Widget buildnominee() {
    final localization = Provider.of<LocalizationProvider>(context,listen: false);
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          // height: MediaQuery.of(context).size.height * 0.08,
          child: TextFormField(
            maxLength: 12,
            controller: nomineeadharController,
            decoration: InputDecoration(
              counterText: '',
              labelText:localization.translate('Nominee Adhar Number'),labelStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return localization.translate('Please enter nominee Aadhaar number');
              } else if (value.length != 12) {
                return localization.translate('Aadhaar number must be 12 digits');
              }
              return null;
            },
          ),
        ),
      ),
      SizedBox(width: 5),

      GestureDetector(
        onTap: () {
          if (_image != null || (nomineeImage != null && nomineeImage!.isNotEmpty)) {
            _showImagePreview(context);  // Preview open avvadi
          } else {
            _showImageSourceOptions();  // Image lekapothe camera/gallery open
          }
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(1),
          ),
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                )
              : (nomineeImage != null && nomineeImage!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        nomineeImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.add_a_photo),
        ),
      ),
    ],
  );
}


void _showImagePreview(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Full image display
          Container(
            color: Colors.black,
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.contain)
                : (nomineeImage != null && nomineeImage!.isNotEmpty)
                    ? Image.network(nomineeImage!, fit: BoxFit.contain)
                    : Center(child: Icon(Icons.image, color: Colors.white, size: 100)),
          ),

          // Clear icon (left) with circular background
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.clear, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Edit icon (right) with circular background
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showImageSourceOptions();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}





}
