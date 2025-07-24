import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/dashboardscreens/user_profile.dart';
import 'package:csc/utillity/constant.dart';

import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/sample.dart';



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
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
      home: const Editscheme1(schemeId: '',),
    ),
  );
}

class Editscheme1 extends StatefulWidget {
  final String schemeId;
  const Editscheme1({
    super.key,required this.schemeId
    
  });

  @override
  _Editscheme1State createState() => _Editscheme1State();
}

class _Editscheme1State extends State<Editscheme1> {
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

String? selectedGender;

//List<String> relationshipOptions = [];


//List<String> genderOptions = ['Male', 'Female', 'Other'];




bool isOtherRelationVisible = false;
  String? adharImage;
  String? panImage;
   String? nomineeimage;
  bool isLoading = true;
 List<String> relationships = [
  'Father', 'Mother', 'Brother', 'Sister', 'Wife', 'Husband', 'Other'
];
String? selectedRelationship;

//String? selectedRelationship;


  @override
  void initState() {
    super.initState();
    loadSavedImages();
    fetchSchemeDetails();
    if (!relationships.contains('Other')) {
  relationships.add('Other');
}

  }


  String schemeAmount = ''; // Holds Scheme Amount
String regId = '';        // Holds Registration ID





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
  final localization = Provider.of<LocalizationProvider>(context, listen: false);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
     ErrorScreen();
    return;
  }

  final url = Uri.parse('$baseUrl/edit_reg_app.php');
  print("🔵 Sending data to API: $url");

  try {
    var request = http.MultipartRequest('POST', url);

    // Add text fields
    request.fields.addAll({
      'scheme_amount': '15000',
      'f_name': firstNameController.text,
      'l_name': lastNameController.text,
      'mobile_no': mobileNumber ?? '',
      'date_of_birth': dobController.text,
      'email_id': 'example@gmail.com',
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
      'gender': gendController.text,
      'nominee_mobile': nomineeMobileController.text,
      'adhar_no': adharController.text,
      'pan_no': panController.text,
      'scheme_type': 'Gold',
      'nominee_adhar': nomineeadharController.text,
      'otherRelationship': otherController.text,
    });



              panImage = (request.fields['pan_image'] != null && request.fields['pan_image']?.isNotEmpty == true)
              ? '$baseUrl/images/${request.fields['pan_image']}'
              : '';

          adharImage = (request.fields['adhar_image'] != null && request.fields['adhar_image']?.isNotEmpty == true)
              ? '$baseUrl/images/${request.fields['adhar_image']}'
              : '';

          nomineeimage = (request.fields['nominee_adhar_image'] != null &&
                  request.fields['nominee_adhar_image']?.isNotEmpty == true)
              ? '$baseUrl/images/${request.fields['nominee_image']}'
              : '';

    // Print all text fields
    print("📦 Fields being sent to API:");
    request.fields.forEach((key, value) {
      print("  $key: $value");
    });

    // Add image files if new image selected
   
    print("📤 Uploading...");

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("🟢 Response Status Code: ${response.statusCode}");
    print("🟡 Raw Response Body: ${response.body}");
    print("📸 Aadhar Image Path: $adharImage");
print("📸 PAN Image Path: $panImage");
print("📸 Nominee Image Path: $nomineeimage");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ Decoded JSON Data: $data");

      if (data['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localization.translate("✅ Scheme updated successfully!"),
              style: GoogleFonts.lato(color: Colors.white),
            ),
            backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen(schemeID: '')),
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
      const SnackBar(content: Text("❌ Failed to update scheme.")),
    );
  }
}


  /// **🔹 SharedPreferences లో స్టోర్ చేసిన ఇమేజ్‌లు లోడ్ చేయడం**
  Future<void> loadSavedImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adharImage = prefs.getString('adharImage');
      panImage = prefs.getString('panImage');
      nomineeimage = prefs.getString('nomineeimage');
    });
  }

  /// **🔹 Scheme Details API నుండి డేటా తీసుకోవడం**
Future<void> fetchSchemeDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  final url = Uri.parse('$baseUrl/get_scheme_details.php');
  final body = {
    'mobile_no': mobileNumber,
     'scheme_id': widget.schemeId.toString(), // Uncomment if needed
  };

  print("🌐 API URL Called: $url");
  print("📤 Request Body: $body");

  try {
    final response = await http.post(url, body: body);

    print(" Response Status Code: ${response.statusCode}");
    print(" Raw Response code: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 200 && data['message'] == "Successfull Response") {
        var details = data['scheme_details'][0];
        final apiRelationship = details['relationship']?.toString().trim();

        setState(() {
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
        });

        print("✅ Final selectedRelationship: $selectedRelationship");
        print("✅ Final relationships list: $relationships");
        print("📸 PAN Image: ${details['pan_image']}");
        print("📸 Aadhar Image: ${details['adhar_image']}");

        setState(() {
          firstNameController.text = details['f_name'] ?? 'N/A';
          lastNameController.text = details['l_name'] ?? 'N/A';
          phoneController.text = details['mobile_no'] ?? 'N/A';
          dobController.text = details['date_of_birth'] ?? 'N/A';
          address1Controller.text = details['address_line1'] ?? 'N/A';
          address2Controller.text = details['address_line2'] ?? 'N/A';
          cityController.text = details['city'] ?? 'N/A';
          selectedGender = details['gender'];
          selectedRelationship = details['relationship'];
          districtController.text = details['disrict'] ?? 'N/A';
          otherController.text = details['other_relationship'] ?? 'N/A';
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
          nomineeadharController.text = details['nominee_adhar'] ?? 'N/A';

          schemeAmount = details['scheme_amount'] ?? 'N/A';
          regId = details['reg_id'] ?? 'N/A';

          panImage = (details['pan_image'] != null && details['pan_image'].isNotEmpty)
              ? '$baseUrl/images/${details['pan_image']}'
              : '';

          adharImage = (details['adhar_image'] != null && details['adhar_image'].isNotEmpty)
              ? '$baseUrl/images/${details['adhar_image']}'
              : '';

          nomineeimage = (details['nominee_adhar_image'] != null &&
                  details['nominee_adhar_image'].isNotEmpty)
              ? '$baseUrl/images/${details['nominee_adhar_image']}'
              : '';
        });
      }
    }
  } catch (e) {
    print("❌ Error fetching scheme details: $e");
  }

  setState(() => isLoading = false);
}




  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localization.translate("Edit Scheme",),
        style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(2, 6, 67, 1),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
            padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    children: [
      
      
      
                      Align(alignment: Alignment.bottomLeft,child: Text('Edit Custmer Information',style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black)),
                      ),
      
      
      
      
                   
      
                        SizedBox(
                       height: MediaQuery.of(context).size.height * 0.02, // 6% of screen height
                     ),
                     
                     //_buildTextField(schemController, localization.translate("Scheme Type")),
                      _buildTextField(firstNameController, localization.translate("First Name*"),readOnly: true),
                      _buildTextField(lastNameController, localization.translate("Last Name*"),readOnly: true),
                      _buildTextField(phoneController, localization.translate("Mobile Number*"), readOnly: true),
                        SizedBox(
                       height: MediaQuery.of(context).size.height * 0.02, // 6% of screen height
                     ),
                    //  _buildTextField(dobController, localization.translate("Date of Birth*")),
                     _buildDateField(dobController, localization.translate("Date of Birth*")),
      
                                        SizedBox(
                       height: MediaQuery.of(context).size.height * 0.02, // 6% of screen height
                     ),
      
                  //  genderDropdown(),
                  genderDropdown(context),
      
      
                     SizedBox(
                       height: MediaQuery.of(context).size.height * 0.02, // 6% of screen height
                     ),
                       _buildTextField(emailController, localization.translate("Email ID(Optional)")),
                      _buildTextField(doorNoController, localization.translate("Door No*")),
                       _buildTextField(address1Controller, localization.translate("Address Line 1*")),
                      _buildTextField(address2Controller, localization.translate("Address Line 2/Land Mark")),
                          _buildTextField(pincodeController, localization.translate("Pincode*")),
                           _buildTextField(countryController, localization.translate("Country*")),
                           _buildTextField(stateController, localization.translate("State*")),
                      _buildTextField(districtController, localization.translate("District*")),
                        _buildTextField(cityController, localization.translate("City*")),  
                      _buildDocumentRow(localization.translate("Aadhar Number*"), adharController, adharImage, false),
                        _buildDocumentRow(localization.translate("PAN Card Number*"), panController, panImage, true),
                     
                       _buildTextField(referralController,localization.translate( "Referral Name/Number")),
      
                         SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
      
                       Align(alignment: Alignment.bottomLeft,child: Text('Bank Deatails',style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                       ),
      
                         SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
                      _buildTextField(bankNameController, localization.translate("Bank Name*")),
                         _buildTextField(holderName, localization.translate("Bank Account Holder Name*")),
                      _buildTextField(accountNoController, localization.translate("Bank Account No*")),
                      _buildTextField(ifscCodeController, localization.translate("IFSC Code*")),
                      _buildTextField(branchLocationController, localization.translate("Branch Location*")),
                     
      
                           SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
      
                       Align(alignment: Alignment.bottomLeft,child: Text('Nominee Deatails',style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                       ),
      
                         SizedBox(
                       height: MediaQuery.of(context).size.height * 0.01, // 6% of screen height
                     ),
                      _buildTextField(nomineeNameController, localization.translate("Nominee Full Name")),
      
                      //  _buildTextField(nomineeadharController, localization.translate("Nominee Adhaar Number"),maxLength: 12,keyboardType: TextInputType.number),
                        _buildDocumentRow(localization.translate("Nominee Adhar Number*"), nomineeadharController, nomineeimage, true),
      
                         // _buildNomineeRelationshipDropdown(),
                          _buildNomineeRelationshipDropdown(),
              if (isOtherRelationVisible) _buildOtherRelationshipField(),
      
                      _buildTextField(nomineeMobileController, localization.translate("Nominee Phone Number (Optional)")),
                     
                     // _buildTextField(nomineeRelationship, localization.translate("Nominee Relationship*")),
                 
                    
                     
                       
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025), // 2.5% of screen height
      
      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await updateSchemeDetails();
                          },
                          child: Text(
                            localization.translate("Save Changes"),
                            style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDocumentRow(String label, TextEditingController controller, String? imageUrl, bool isPanCard) {
    return Row(
      children: [
        Expanded(child: _buildTextField(controller, label,readOnly: true)),

      SizedBox(width: MediaQuery.of(context).size.width * 0.025), // 2.5% of screen width


        _buildImageWidget(imageUrl, isPanCard),
      ],
    );
  }

 Widget _buildImageWidget(String? imageUrl, bool isPanCard) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.15, // 15% of screen width
    height: MediaQuery.of(context).size.width * 0.15,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
    ),
    child: imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          )
        : const Icon(Icons.image, size: 40, color: Colors.grey),
  );
}


  Widget _buildTextField(
  TextEditingController controller,
  String label, {
  bool readOnly = false,
  int? maxLength, // ✅ Optional maxLength
  TextInputType keyboardType = TextInputType.text, // ✅ Default to text
}) {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: MediaQuery.of(context).size.height * 0.01,
    ),
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.06,
      child: TextField(
        inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
        controller: controller,
        textCapitalization: TextCapitalization.words,
        readOnly: readOnly,
        maxLength: maxLength, // ✅ Limit text
        keyboardType: keyboardType, // ✅ Set keyboard type
        decoration: InputDecoration(
          labelText: label,
          counterText: '', // ✅ Hide character counter if needed
          border: const OutlineInputBorder(),
        ),
      ),
    ),
  );
}



  Widget _buildDateField(TextEditingController controller, String label) {
  return SizedBox(
     height: MediaQuery.of(context).size.height * 0.06, // 6% of screen height
    child: TextField(
      inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
      controller: controller,
      readOnly: true,
      
      decoration: InputDecoration(
        labelText: label,
        
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
    
        String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate!);
        controller.text = formattedDate;
            },
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
          labelText:localization.translate("Nominee Relationship*"),
          border: OutlineInputBorder(),
        ),
        items: relationships.toSet().map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
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

  Widget _buildOtherRelationshipField() {
      final localization = Provider.of<LocalizationProvider>(context);
    return Visibility(
      visible: isOtherRelationVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
          controller: otherController,
          decoration:  InputDecoration(
            labelText: localization.translate("Enter Custom Relationship"),
            border: OutlineInputBorder(),
          ),
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
    ),
  );
}

}
