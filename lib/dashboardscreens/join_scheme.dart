import 'dart:convert';
import 'dart:io';

import 'package:csc/api_services.dart/ifsc_codeapi.dart';

import 'package:csc/api_services.dart/scheme_fetchdetails.dart';
import 'package:csc/api_services.dart/scheme_submitform.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/scner.dart';
import 'package:csc/utillity/bouncing.dart';
import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/dashboardscreens/termcondition.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/utillity/constantcolor.dart';
import 'package:csc/utillity/netmix.dart';







import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
      home: const Jionscheme2(),
    ),
  );
}



class Jionscheme2 extends StatefulWidget {
  const Jionscheme2({super.key});

  @override
  _Jionscheme2State createState() => _Jionscheme2State();
}

class _Jionscheme2State extends State<Jionscheme2> with NetworkMixin{

   bool isButtonVisible = true;
   bool isAdharReadOnly = false;
   bool isPanReadOnly = false;
   
 bool areNomineeFieldsValid({
    required String nomineeAadhar,
    required String nomineeAadharNumber,
    required String nomineeMobileNumber,
    required String userMobileNumber,
  }) {
    if (nomineeAadhar == nomineeAadharNumber) {
      // Check if Aadhar number and nominee Aadhar are same
      return false;
    } 
    if (nomineeMobileNumber == userMobileNumber) {
      // Check if Nominee mobile and User mobile are same
      return false;
    }
    return true;
  }



   void _Form() {
  if (_formKey.currentState!.validate()) {
    final nomineeAadhar = adharController.text;
    final nomineeAadharNumber = nomineeadharController.text;
    final nomineeMobileNumber = nomineeMobileController.text;
    final userMobileNumber = _phoneController.text;

    if (!areNomineeFieldsValid(
      nomineeAadhar: nomineeAadhar,
      nomineeAadharNumber: nomineeAadharNumber,
      nomineeMobileNumber: nomineeMobileNumber,
      userMobileNumber: userMobileNumber,
    )) {
      // Show custom stylish popup
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Icon(Icons.error_outline, color: Colors.red, size: screenWidth * 0.12),
                SizedBox(height: screenHeight * 0.015),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    'Nominee Aadhar number and nominee mobile number cannot be the same as your details. Please enter unique values.',
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(screenWidth * 0.02),
                      bottomRight: Radius.circular(screenWidth * 0.02),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
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
   
  }
}

  //  String schemeId = '';


  

 // String selectedDepositType = "Gold"; // Default selection

 

  bool isFocused = false; // Track focus state

 String? adharImage;
  String? panImage;
   String? nomineeimage;

   String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String email = '';

  bool isTermsAccepted = false;
  bool _termsAccepted = false;

 File? _adharImage; // Adhar image
File? _panImage;   // PAN image
 File? _nomineeadharImage;

Future<void> _pickImage(int containerNumber) async {
  final pickedOption = await showDialog<ImageSource>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Choose an option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );

  if (pickedOption == null) return;

  final XFile? pickedImage = await ImagePicker().pickImage(source: pickedOption);

  if (pickedImage != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imagePath = pickedImage.path;

    setState(() {
      if (containerNumber == 1) {
        _adharImage = File(imagePath);
        prefs.setString('adharImage', imagePath);
      } else if (containerNumber == 2) {
        _panImage = File(imagePath);
        prefs.setString('panImage', imagePath);
      } else if (containerNumber == 3) {
        _nomineeadharImage = File(imagePath);
        prefs.setString('nomineeimage', imagePath);
      }
    });
  }
}

 


// Second container ki image

 // String _message = '';
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   
String schemeId  = '';

 String? ifscError;


   

  // Text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController doorNoController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController adharController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController holderNameController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController branchLocationController = TextEditingController();
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController nomineeMobileController = TextEditingController();
   final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController nomineeadharController = TextEditingController();
   final TextEditingController genderController = TextEditingController();
   
  
  
  



 
  final FocusNode _termsFocus = FocusNode(); // Focus for Terms and Conditions

final FocusNode _ifscFocusNode = FocusNode();

 



   void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // When app is paused (closed or moved to background), clear other fields and only keep the firstName
      _saveSharedPreferences();
    }
  }
   

  // Dropdown options

   List<String>  amountOptions = [];
    final TextEditingController _amountController = TextEditingController(); // Controller for the TextField

   bool isLoading = true;


  String? selectedValue;
  TextEditingController otherController = TextEditingController();

  
 
  final List<String> nomineeOptions = ['Mother', 'Father', 'Brother', 'Sister', 'Wife', 'Husband', 'Other'];
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
 final List<String> depositTypes = ["Gold", "Silver"]; 

   String? selectedGender;

  
  String? selectedAmount;
  String? selectedCountry;
  String? selectedState;
  String? selectedDistrict;
  String? selectedNomineeRelation;
  String? selectedDepositType;


bool isPanRequired = false;
bool isnomineeadhearRequired = false;
bool isadhearRequired = false;

String schemeAmount = '';


  Future<void> fetchAmounts() async {
  String url = "$baseUrl/get_amount.php";
  
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 200) {
        setState(() {
          amountOptions = (data['amount_details'] as List)
              .map((item) => item['amount'].toString())
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print("Error fetching data: $e");
    setState(() {
      
      isLoading = false;
    });
  }
}



Future<void> fetchVerifiedAmount() async {
  final url = Uri.parse("$baseUrl/amount_verification.php");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  print("🔗 API URL: $url");
  print("📤 Sending Parameters: mobile_no=$mobileNumber, scheme_amount=${_amountController.text}");

  try {
    final response = await http.post(
      url,
      body: {
        'mobile_no': mobileNumber,
        'scheme_amount': _amountController.text
      },
    );

    print("📥 Response Status Code: ${response.statusCode}");
    print("📥 Full Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print("✅ Decoded Response: $data");

      if (data['amount'] != null) {
        final fetchedAmount = double.tryParse(data['amount'].toString()) ?? 0;

        setState(() {
        //  _amountController.text = fetchedAmount.toString();
         isPanRequired = fetchedAmount >= 15000; // ✅ Correct condition
        });

        print("📊 PAN Required: $isPanRequired");
      } else {
        print("⚠️ 'amount' not found in response");
      }
    } else {
    print("❌ Failed to load amount. Status: ${response.statusCode}");
    }
  } catch (e) {
  print("❗ Error occurred: $e");
  }
}

Future<void> loadSavedImages() async {
SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    final adharPath = prefs.getString('adharImage');
    final panPath = prefs.getString('panImage');
    final nomineePath = prefs.getString('nomineeimage');

    if (adharPath != null && adharPath.startsWith('http')) {
    adharImage = adharPath;
    } else if (adharPath != null) {
      _adharImage = File(adharPath);
    }

    if (panPath != null && panPath.startsWith('http')) {
      panImage = panPath;
    } else if (panPath != null) {
     _panImage = File(panPath);
    }

    if (nomineePath != null && nomineePath.startsWith('http')) {
      nomineeimage = nomineePath;
    } else if (nomineePath != null) {
     _nomineeadharImage = File(nomineePath);
    }
  });
}


   Future<void> fetchRegistrationDetails() async {
    final registrationService = RegistrationService();
    final reg = await registrationService.fetchRegistrationDetails();

    if (reg != null) {
setState(() {
          _firstNameController.text = reg['f_name'] ?? '';
          _lastNameController.text = reg['l_name'] ?? '';
          _phoneController.text = reg['mobile_no'] ?? '';
         if (reg['date_of_birth'] != null && reg['date_of_birth'].isNotEmpty) {
  DateTime parsedDate = DateTime.parse(reg['date_of_birth']);
  dobController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
} else {
  dobController.text = '';
}

          _emailController.text = reg['email_id'] ?? '';
          doorNoController.text = reg['door_no'] ?? '';
          address1Controller.text = reg['address_line1'] ?? '';
          address2Controller.text = reg['address_line2'] ?? '';
          cityController.text = reg['city'] ?? '';
          pincodeController.text = reg['pincode'] ?? '';
          countryController.text = reg['country'] ?? '';
          stateController.text = reg['state'] ?? '';
          districtController.text = reg['disrict'] ?? '';
          adharController.text = reg['adhar_no'] ?? '';
           isAdharReadOnly = adharController.text.isNotEmpty;
      
          panController.text = reg['pan_no'] ?? '';
         isPanReadOnly = panController.text.isNotEmpty;



          referralController.text = reg['referral'] ?? '';
          bankNameController.text = reg['bank_name'] ?? '';
          holderNameController.text = reg['holder_name'] ?? '';
          accountNoController.text = reg['account_no'] ?? '';
          ifscCodeController.text = reg['ifsc_code'] ?? '';
          branchLocationController.text = reg['branch_location'] ?? '';
          nomineeNameController.text = reg['nominee_name'] ?? '';
          nomineeMobileController.text = reg['nominee_mobile'] ?? '';
          nomineeadharController.text = reg['nominee_adhar'] ?? '';
          genderController.text = reg['gender'] ?? '';

          selectedNomineeRelation = reg['relationship'];
          selectedGender = reg['gender'];
          otherController.text = reg['other_relationship'] ?? '';


          schemeAmount = reg['scheme_amount'] ?? 'N/A';
         // regId = details['reg_id'] ?? 'N/A';

          print("📸 PAN Image: ${reg['pan_image']}");
          
    print("📸 Aadhar Image: ${reg['adhar_image']}"); 


           panImage = (reg['pan_image'] != null && reg['pan_image'].isNotEmpty)
      ? '$baseUrl/images/${reg['pan_image']}'
      : '';

  adharImage = (reg['adhar_image'] != null && reg['adhar_image'].isNotEmpty)
      ? '$baseUrl/images/${reg['adhar_image']}'
      : '';


        nomineeimage = (reg['nominee_adhar_image'] != null && reg['nominee_adhar_image'].isNotEmpty)
      ? '$baseUrl/images/${reg['nominee_adhar_image']}'
      : '';



      

        });
    } else {
      print("⚠️ No registration details found.");
    }
  }








  


  Future<void> saveMobileNumber(String mobileNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('mobile_number', mobileNumber);
  print("Mobile number saved: $mobileNumber");
}


Future<String?> getMobileNumber() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString('mobile_number');

}



 

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
     fetchRegistrationDetails();
     
     

     _ifscFocusNode.addListener(() {
    if (!_ifscFocusNode.hasFocus) {
      // Field lost focus
      final value = ifscCodeController.text.trim().toUpperCase();
      if (value.length != 11 || !RegExp(r'^[A-Z]{4}[0][A-Z0-9]{6}$').hasMatch(value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid IFSC Code')),
        );
        setState(() {
          bankNameController.clear();
          branchLocationController.clear();
        });
      }
    }
  });
     
    fetchAmounts();
    //fetchVerifiedAmount();

   

    
           
  }


  


  

  Future<void> getSavedAmount() async {
  final prefs = await SharedPreferences.getInstance();
  String? savedAmount = prefs.getString('selectedAmount');
  print("Saved Amount: $savedAmount");
}


  



  Future<void> _loadSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {

       
      _firstNameController.text = prefs.getString('firstName') ?? '';
      _lastNameController.text = prefs.getString('lastName') ?? '';
      _phoneController.text = prefs.getString('phoneNumber') ?? '';
      _emailController.text = prefs.getString('email') ?? '';

      selectedGender = prefs.getString('gender');


      dobController.clear();                      
      doorNoController.clear();                          
      address1Controller.clear();                            
      address2Controller.clear() ;                                
      cityController.clear();                                       
      pincodeController.clear();                                       
      adharController.clear();                                               
      panController.clear();                                                            
      referralController.clear();                                                        
      bankNameController. clear();                                                            
      holderNameController.clear();                                                        
      accountNoController.clear();                                                            
      ifscCodeController.clear();                                                     
      branchLocationController. clear();                                         
      nomineeNameController. clear();                                                  
      nomineeMobileController.clear() ;                                            
     
     

       selectedAmount = null;
      selectedCountry = null;
      selectedState = null;
      selectedDistrict = null;
      selectedNomineeRelation = null;
      selectedDepositType = null;

      


      
    });
    

    // Debug logs
    print("Loaded firstName: ${prefs.getString('firstName')}");
     print("Loaded FirstName: ${prefs.getString('firstName')}");
    print("Loaded LastName: ${prefs.getString('lastName')}");
    print("Loaded MobileNumber: ${prefs.getString('phoneNumber')}");
  }

  Future<void> _saveSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('firstName', _firstNameController.text);
    await prefs.setString('lastName', _lastNameController.text);
    await prefs.setString('phoneNumber', _phoneController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('gender', selectedGender ?? '');
   await prefs.setString('dob', dobController.text);
    await prefs.setString('doorNo', doorNoController.text);
    await prefs.setString('address1', address1Controller.text);
    await prefs.setString('address2', address2Controller.text);
    await prefs.setString('city', cityController.text);
    await prefs.setString('pincode', pincodeController.text);
    await prefs.setString('adharNo', adharController.text);
    await prefs.setString('panNo', panController.text);
    await prefs.setString('referral', referralController.text);
    await prefs.setString('bankName', bankNameController.text);
    await prefs.setString('holderName', holderNameController.text);
    await prefs.setString('accountNo', accountNoController.text);
    await prefs.setString('ifscCode', ifscCodeController.text);
    await prefs.setString('branchLocation', branchLocationController.text);
    await prefs.setString('nomineeName', nomineeNameController.text);
    await prefs.setString('nomineeMobile', nomineeMobileController.text);
    await prefs.setString('gender', selectedGender ?? '');


    
    await prefs.setBool('isFormCompleted', true); // Save flag


    // Dropdown values
   
   await prefs.setString('schemeAmount', selectedAmount ?? '');
    await prefs.setString('country', selectedCountry ?? '');
    await prefs.setString('state', selectedState ?? '');
    await prefs.setString('district', selectedDistrict ?? '');
    await prefs.setString('nomineeRelationship', selectedNomineeRelation ?? '');
   await prefs.setString('nomineeRelationship', selectedDepositType ?? '');

   

    // Debug logs
    print("Saved firstName: ${_firstNameController.text}");
  }


 




  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    dobController.dispose();
    doorNoController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    pincodeController.dispose();
    adharController.dispose();
    panController.dispose();
    referralController.dispose();
    bankNameController.dispose();
    holderNameController.dispose();
    accountNoController.dispose();
    ifscCodeController.dispose();
    branchLocationController.dispose();
    nomineeNameController.dispose();
    nomineeMobileController.dispose();
    countryController.dispose();
    stateController.dispose();
    districtController.dispose();
     _termsFocus.dispose();
    super.dispose();
  }




Future<void> submitForm() async {
  if (_formKey.currentState!.validate()) {
    await _saveSharedPreferences();

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ErrorScreen()),
      );
      return;
    }

    final Map<String, String> data = {
      'scheme_id': schemeId,
      'scheme_amount': _amountController.text,
      'f_name': _firstNameController.text,
      'l_name': _lastNameController.text,
      'mobile_no': _phoneController.text,
      'date_of_birth': dobController.text,
      'email_id': _emailController.text,
      'door_no': doorNoController.text,
      'address_line1': address1Controller.text,
      'address_line2': address2Controller.text,
      'city': cityController.text,
      'country': countryController.text,
      'state': stateController.text,
      'disrict': districtController.text,
      'referral': referralController.text,
      'pincode': pincodeController.text,
      'adhar_no': adharController.text,
      'pan_no': panController.text,
      'bank_name': bankNameController.text,
      'holder_name': holderNameController.text,
      'account_no': accountNoController.text,
      'ifsc_code': ifscCodeController.text,
      'branch_location': branchLocationController.text,
      'nominee_name': nomineeNameController.text,
      'relationship': selectedNomineeRelation ?? '',
      'scheme_type': selectedDepositType ?? '',
      'nominee_mobile': nomineeMobileController.text,
      'nominee_adhar': nomineeadharController.text,
      'otherRelationship': otherController.text,
      'gender': selectedGender ?? ''
    };

    final response = await submitRegistrationForm(
      data: data,
      adharImage: _adharImage,
      panImage: _panImage,
      nomineeAdharImage: _nomineeadharImage,
     // baseUrl: baseUrl,
    );

    if (response != null) {
      String schemeId = response['schemeId']?.toString() ?? '';

      Activescheme activescheme = Activescheme.customparams(
        schemeID: schemeId,
        amountRs: response['amount'],
        month: response['month'],
        year: response['year'],
        payId: '',
        rejectId: '',
        balanceAmount: '',
        installmentAmount: '',
      );

      _submitForm(context, activescheme);
    }
  }
}

DateTime? selectedDate;

 void _selectDate(BuildContext context) async {
   final localization = Provider.of<LocalizationProvider>(context,listen: false);
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.orange,
            onPrimary: Colors.white,
            surface: Colors.black,
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.black),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    if (_is18OrOlder(picked)) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    } else {
      setState(() {
        dobController.text = ''; // ❌ Clear the text field
      });

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(localization.translate('You must be 18 years or older to select this date.'),style: TextStyle(fontSize: 10),),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  bool _is18OrOlder(DateTime date) {
    DateTime today = DateTime.now();
    int age = today.year - date.year;
    if (today.month < date.month || (today.month == date.month && today.day < date.day)) {
      age--;
    }
    return age >= 18;
  }



  

  @override
  Widget build(BuildContext context) {

   


  final localization = Provider.of<LocalizationProvider>(context,listen: false);

  



    return Stack(
      children: [
        Scaffold(
          
            
           appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 100,
               elevation: 0,
              shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
              backgroundColor: AppColors.blue,
              title: Padding(
               padding: const EdgeInsets.only(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(activescheme: Activescheme(),),
                                ));
                         },
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white,size: 29,),
                       ),

                         Text(
                         // 'Registration',

          
                         localization.translate("Registration"),
                        
                            style: GoogleFonts.nunito(color: Colors.white, fontSize: 22)
                            ),
                        Column(
                          children: [
                            Image.asset('assets/images/csc2.png',
                               height: 50, color: Colors.white),

                               Text(localization.translate('Since 1971'), 
                               style: GoogleFonts.nunito(color: Colors.white, fontSize: 12))
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 30),

                    
                  
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                
                padding: const EdgeInsets.all(16.0),
                
                child: SingleChildScrollView(
                 // controller:  _scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                         // 'SCHEME REGISTRATION',
                         localization.translate("SCHEME REGISTRATION"),
                            style:GoogleFonts.lato( color: AppColors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)
                                ),
                        Text(
                          //'Continue to Register',
                          localization.translate("Customer Information"),
                            style: GoogleFonts.lato(color: AppColors.blue, fontSize: 15)
                                ),
                       // const Divider(color: Color.fromRGBO(2, 5, 62, 1),thickness: 1,),
                        
                        
                        Textamount(),
                        
                          //  SizedBox(height: 16,),
                        
                 
                    
                        buildrow(),
                        
                        const SizedBox(height: 16,),
                        // Mobile Number
                      _buildTextField(
              controller: _phoneController,
              label: localization.translate("Mobile Number*"),
              readOnly: true,
              prefixIcon:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/flag.png",
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text("+91", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                        if (value == null || value.isEmpty) {
              return localization.translate('Please enter your mobile number');
                        }
                        return null;
              },
                        ),
                        
                        //SizedBox(height: 16,),
                        
                        
                        
                        // Date of Birth
              
                     _buildTextField(
              controller: dobController,
              label: (localization.translate("Date of Birth*")),
              validator: (value) {
                        if (value == null || value.isEmpty) {
              return (localization.translate("Please enter Date of Birth"));
                        }
                        return null;
              },
              readOnly: true,
              suffixIcon: IconButton(
                        icon: const Icon(
              Icons.calendar_today,
              color: AppColors.blue,
                        ),
                        onPressed: () => _selectDate(context),
              ),
                        ),
                        
              
              
              
              
               
              
              
              
              
                buildGenderDropdown(),
                        
                        
                        
               const SizedBox(height: 16,),
                        
                        // Email ID
                      _buildTextField(
              controller: _emailController,
              label: localization.translate("Email ID(Optional)"),
                         // readOnly: true,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                        if (value != null && value.isNotEmpty) {
              // Check for a valid email format if provided
              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return localization.translate("Please enter a valid email address");
              }
                        }
                        // No validation error if the field is empty since it's optional
                        return null;
              },
                        ),
                        
                    
                          _buildTextField(
              controller: doorNoController,
              label: localization.translate("Door No*"),
              
              validator: (value) =>
                        value!.isEmpty ? localization.translate("Please enter door number") : null,
                        ),
                        
                    
                         _buildTextField(
              controller: address1Controller,
              label: localization.translate("Address Line 1*"),
              
              validator: (value) {
                        if (value == null || value.isEmpty) {
              return localization.translate("Please enter Address");
                        }
                        return null;
              },
                        ),
                        
                    
                    
                             _buildTextField(
              controller: address2Controller,
              label: localization.translate("Address Line 2/Land Mark"),
                        ),
                        
                    
                        
                        
                    
                      _buildTextField(
                         keyboardType: TextInputType.number,
                         maxLength: 6,
                        onChanged: (value) {
                    if (value.length == 6) {
                      getPincodeDetails(value); // Trigger the API call when 6-digit pincode is entered
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return localization.translate('Please enter a valid 6-digit pincode');
                    }
                    return null;
                  }, 
              controller: pincodeController,
              label: localization.translate("Pincode*"),
              
                        ),
                        
              _buildTextField(
              controller:countryController,
              label: localization.translate("Country*"),
              readOnly: false
                         
                        ),
                        
                         _buildTextField(
              controller:   stateController,
              label: localization.translate("State*"),
              readOnly: false
                         
                        ),
                        
                         _buildTextField(
              controller:   districtController,
              label: localization.translate("District*"),
              readOnly: false
                         
                        ),
                        
                         _buildTextField(
              controller:   cityController,
              label: localization.translate("City*"),
              readOnly: false
                         
                        ),
                        
                        
                        
                        
                       // SizedBox(height: 16,),
                        
                  
                        
                  //  _buildDropdownField2(),
                        
                        
                        
                        _buildTextField1(
              controller: adharController,
              label: localization.translate("Aadhar Number*"), // Localized label
              
              selectedImage: _adharImage, // Selected image for the field
              onPickImage: () => _pickImage(1), // Image picker callback
              maxLength: 12, // Adhar number should be 12 digits
                         // hintText: "456788883", // Hint text for Adhar number
                         isadhearRequired: isadhearRequired
                         
                        ),
                        
                        _buildTextField2(
              controller: panController,
              label: localization.translate("PAN Card Number*"),
              
              selectedImage: _panImage,
              onPickImage: () => _pickImage(2),
              maxLength: 10,
              hintText: "ABCDE1234F",
              isPanRequired: isPanRequired, // pass the flag dynamically
                        ),
                        
                        
                     
                        
              const SizedBox(height: 5,),
                    
                        _buildTextField(controller: referralController,
                         label: 
                         //'Refferal Name/Number'
                          localization.translate("Referral Name/Number"),
                          
                         
                    ),
                         
                    
                    
                        const SizedBox(height: 20,),
                    
                    
                         Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                           // 'Bank Details',
                            localization.translate("Bank Details"),
                    
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                    
                        
                                        const SizedBox(height: 20,),
                    
                    
                        _buildTextField4(
                         // controller: _ifscController, // <-- Add this line
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localization.translate('Please enter IFSC Code');
                }
                if (!RegExp(r'^[A-Z]{4}[0][A-Z0-9]{6}$').hasMatch(value)) {
                  return 'Invalid IFSC Code';
                }
                return null;
              },
               onChanged: (value) {
                value = value.toUpperCase();
                        
                if (value.length == 11) {
                  if (RegExp(r'^[A-Z]{4}[0][A-Z0-9]{6}$').hasMatch(value)) {
                        fetchBankDetails(value); // ✅ valid, call API
                  } else {
                        bankNameController.clear();
                        branchLocationController.clear();
                        
                        // ✅ Show Snackbar for invalid code
                        ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid IFSC Code')),
                        );
                  }
                } else {
                  bankNameController.clear();
                  branchLocationController.clear();
                }
              },
                        ),
                         const SizedBox(height: 10),
                        
                    
                       //  BankDetails(),
                    
                          _buildTextField(controller: bankNameController,
                         label: 
                         //'Refferal Name/Number'
                          localization.translate("Bank Name*"),
                           validator: (value) {
              if (value == null || value.isEmpty) {
                return localization.translate('Please enter the bank name'); // Validator message
              }
              return null; // Valid input
                        },
                          
                         
                    ),
                        
                        //SizedBox(height: 16),
                        
                        
                        
                         _buildTextField(controller:  branchLocationController, 
                        label:  localization.translate("Branch Location*"),
                         validator: (value) {
              if (value == null || value.isEmpty) {
               return localization.translate('Please enter the bank location'); // Validator message
              }
              return null; // Valid input
                        },
                     
                        ),
                    
                    
                        
                        
                          _buildTextField(controller: holderNameController,
                         label: 
                         //'Refferal Name/Number'
                          localization.translate("Bank Account Holder Name*"),
                           validator: (value) {
              if (value == null || value.isEmpty) {
              return  localization.translate('Please enter the bank a/c holder name'); // Validator message
              }
              return null; // Valid input
                        },
                          
                         
                    ),
                    
                    
                    
                        // SizedBox(height: 16),
                        
                         _buildTextField(controller:accountNoController, 
                         label:   localization.translate("Bank Account No*"),
                         keyboardType: TextInputType.number,
                         maxLength: 18,
                          validator: (value) {
              if (value == null || value.isEmpty) {
                return localization.translate('Please enter the bank account number'); // Validator message
              }
              return null; // Valid input
                        },
                         ),
                         
                    
                    
                         
                    
                    
                     
                        
                  
                        //HDFC0001234
                    
                        
                        const SizedBox(height: 16,),
                        
                       
                       
                    
                         const SizedBox(height: 16,),
                    
                          Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                          // 'Nominee Details',
                            localization.translate("Nominee Details"),
                    
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                    
                    
                    
                        SizedBox(height: 20,),
                    
                    
                     _buildTextField(
  controller: nomineeNameController,
  label: localization.translate("Nominee Full Name"),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter the nominee name ";
    }
   
    return null;
  },
),

                    
                     
                          
                    //SizedBox(height: 16,),
                       
                      
                        buildDropdownField(localization.translate("Nominee Relationship*"), nomineeOptions, selectedNomineeRelation, (value) {
                          setState(() => selectedNomineeRelation = value);
                        }),
                    
                        const SizedBox(height: 5,),
                        
                      
                    /*
                    
                      _buildTextField(controller:  nomineeadharController,
                      keyboardType: TextInputType.number, 
                      maxLength: 12,
                      label:  localization.translate("Nominee Adhar Number*"),
                        validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter nominee adhar number";
                } else if (value.length != 12) {
                  return "Adhar number must be 12 digits";
                }
                return null;
              },
                        
                      ),
                        
                      */
                        
                        
                      _buildTextField3(
              controller: nomineeadharController,
              label: localization.translate("Nominee Adhar Number*"), // Localized label
              selectedImage: _nomineeadharImage, // Selected image for the field
              onPickImage: () => _pickImage(3), // Image picker callback
              maxLength: 12, // Adhar number should be 12 digits
                         // hintText: "456788883", // Hint text for Adhar number
                         isnomineeadhearRequired: isPanRequired, // pass the flag dynamically
              // Optional: Add a v
                        
                         /*
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter  nominee adhar number";
                } else if (value.length != 12) {
                  return "Adhar number must be 12 digits";
                }
                return null;
              },
                        
              */
                        ),
                    
                      const SizedBox(height: 10,),
                       
                        SizedBox(
                         // height: 50,
                          child: TextField(
                            maxLength: 10,
                            controller: nomineeMobileController,
                            decoration: InputDecoration(
                              counterText: '',
                              border: const OutlineInputBorder(),
                               focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.blue, width: 2), // Focus border color
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                     floatingLabelStyle: const TextStyle(color: AppColors.blue),
                               // Remove border
                            //  filled: true,
                              //fillColor: Colors.grey[200], // Fill color for TextField
                              labelText:localization.translate( "Nominee Phone Number (Optional)"),labelStyle: GoogleFonts.lato()
                            ),
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                    
                    
                    
                        const SizedBox(height: 16,),
                    
                    buildRow4(),
                       
                    
                      
                      const SizedBox(height: 5,),
                    
                      SizedBox(
              height: 50,
              width: double.infinity,
              child:
              
                        ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                  ),
                ),
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.blue,
                ),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
              FocusScope.of(context).unfocus();
                        
              
              // Step 1: Validate form fields
              if (!_formKey.currentState!.validate()) {
                 ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localization.translate('Please fill in all the mandatory fields.')),
                  backgroundColor: Colors.red,
                ),
              );
                return; // Field-level validation will show errors
              }
                        
              
                        
              // Step 2: Check if terms accepted
              if (!_termsAccepted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localization.translate("Please accept the Terms and Conditions to proceed.")),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }
                        
               // Step 3: Check if nominee and user details are same (custom validation)
                        final nomineeAadhar = adharController.text.trim();
                        final nomineeAadharNumber = nomineeadharController.text.trim();
                        final nomineeMobileNumber = nomineeMobileController.text.trim();
                        final userMobileNumber = _phoneController.text.trim();
                        
                        if (nomineeAadhar == nomineeAadharNumber &&
                nomineeMobileNumber == userMobileNumber) {
              _Form(); // Call your validation popup method here
              return;
                        }
                        
                        
              
                        
              setState(() {
                isLoading = true;
              });
                        
              // Step 3: Save important fields
              final preservedFirstName = _firstNameController.text;
              final preservedLastName = _lastNameController.text;
              final preservedPhone = _phoneController.text;
              final preservedEmail = _emailController.text;
                        
              await submitForm();
              await _saveSharedPreferences();
                        
              // Step 4: Clear only other fields
              setState(() {
                _amountController.clear();
                dobController.clear();
                doorNoController.clear();
                address1Controller.clear();
                address2Controller.clear();
                cityController.clear();
                pincodeController.clear();
                adharController.clear();
                panController.clear();
                referralController.clear();
                bankNameController.clear();
                holderNameController.clear();
                accountNoController.clear();
                ifscCodeController.clear();
                branchLocationController.clear();
                nomineeNameController.clear();
                nomineeMobileController.clear();
                nomineeadharController.clear();
                otherController.clear();
                        
                selectedAmount = null;
                selectedCountry = null;
                selectedDate = null;
                selectedDistrict = null;
                selectedNomineeRelation = null;
                selectedState = null;
                selectedGender = null;
                        
                adharImage = null;
                panImage = null;
                nomineeimage = null;
               
                        
               
                
                        
                // Restore preserved fields
                _firstNameController.text = preservedFirstName;
                _lastNameController.text = preservedLastName;
                _phoneController.text = preservedPhone;
                _emailController.text = preservedEmail;
                        
                isLoading = false;
                        
                
              });
                        },
              child: Text(
                localization.translate("continue"),
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
                        )
                        ),
               
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
        ),


          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
  child: BouncingDotsLoader(
    color: Color(0xFF002970), // Paytm blue or gold
    size: 12.0,
  ),
),
            ),
      ],
    );
  }


  

  void _submitForm(BuildContext context, activescheme) {
     final localization = Provider.of<LocalizationProvider>(context,listen: false);
     final currentContext = context;
  if (_formKey.currentState?.validate() ?? false) {
    if (_termsAccepted) {
      setState(() {
        isLoading = true; // Set loading state
         isButtonVisible = false; // Hides the button
      });

      // Simulate a network request
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false; // Reset loading state
           isButtonVisible = false; // Hides the button
        });

        // Show Lottie Animation Popup (AlertDialog)
       showDialog(
    barrierDismissible: false,
     context: currentContext,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
      //  borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero, // Remove extra padding
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Lottie.asset(
            'assets/images/suc.json',
            width: 60,
            height: 60,
            repeat: false, // Play animation only once
          ),
          const SizedBox(height: 10),
          Text(
            localization.translate("Success!"),
            style:GoogleFonts.lato(fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,)
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              localization.translate("Scheme Registration submitted successfully!"),
              textAlign: TextAlign.center,style: GoogleFonts.lato(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actionsPadding: EdgeInsets.zero, // Remove default padding from actions
      actions: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.only(
            //  bottomLeft: Radius.circular(20),
             // bottomRight: Radius.circular(20),
            ),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scanner(activescheme: activescheme,rejectId: schemeId,),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15), // Fix button height
            ),
            child: Text(
             localization.translate('OK'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
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
}








Widget buildRow3() {
  return Row(
   // mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Checkbox(
        activeColor: AppColors.blue,
        value: _termsAccepted,
        onChanged: (value) {
          setState(() {
            _termsAccepted = value!;
          });
        },
         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // smaller box
  visualDensity: VisualDensity(horizontal: -4, vertical: -4), // make it more compact
      ),
      GestureDetector(
        onTap: () async {
          // Save all form data before navigation
          await _saveSharedPreferences();
          // Navigate to the Terms and Conditions screen
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const TermsAndConditionsScreen2(),
            ),
          );
        },
        child: Focus(
          focusNode: _termsFocus,
          child: const Text(
            'By joining this scheme, you agree to our\nterms and conditions and privacy policy.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black, // Optional: Highlight text as a link
              //decoration: TextDecoration.underline, // Optional: Underline the text to show it's a link
            ),
          ),
        ),
      ),


     

      
    ],
  );
}


Widget buildRow4(){
   final localization = Provider.of<LocalizationProvider>(context);
  return Row(
    
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (value) {
                     setState(() {
            _termsAccepted = value!;
          });
                  },
                  activeColor:AppColors.blue, // Checkbox fill color
  checkColor: Colors.white,
   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // smaller box
  visualDensity: VisualDensity(horizontal: -4, vertical: -4), // make it more compact // Tick color
                ),

                SizedBox(width: 8,),
                Expanded(
                  child: GestureDetector(
                     onTap: () async {
          // Save all form data before navigation
          await _saveSharedPreferences();
          // Navigate to the Terms and Conditions screen
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const TermsAndConditionsScreen2(),
            ),
          );
        },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(text: localization.translate("By signing up you agree to our"),style: GoogleFonts.lato()),
                          TextSpan(
                            text: localization.translate("Terms and Conditions"),
                            style: GoogleFonts.lato( color: Colors.red,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,)
                            // Add your link handling here
                          ),
                    
                         
                          TextSpan(text:localization.translate( "and "),style: GoogleFonts.lato()),
                          TextSpan(
                            text: localization.translate("Privacy Policy."),
                            style: GoogleFonts.lato( color: Colors.red,
                               fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,)
                            // Add your link handling here
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );

}


  Widget Textamount(){
     final localization = Provider.of<LocalizationProvider>(context);
    return  SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 


                  const SizedBox(height: 16),

                  // Deposit Amount
                   Text(
                    localization.translate("Deposit Amount"),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
               TextFormField(
                readOnly: true,
                controller: _amountController,
               // focusNode: _amountFocusNode,
                decoration:  InputDecoration(
                   border: const UnderlineInputBorder(),
                   focusedBorder:const UnderlineInputBorder(
                     borderSide: BorderSide(color: AppColors.blue, width: 2), // Focus border color
                   ),
                 floatingLabelStyle: const TextStyle(color: AppColors.blue),

                  hintText: localization.translate("Enter Amount"),
                  //border: UnderlineInputBorder(),
                ),
               // keyboardType: TextInputType.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localization.translate('Please enter an amount');
                  }
                  return null;
                
                },
              ),
          
                  const SizedBox(height: 16),

                  // Amount Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: amountOptions
                        .map((amount) =>
                        buildAmountButton(context, "₹ $amount", amount))
                        .toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            
    );
  }


   Widget buildAmountButton(BuildContext context, String label, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = value;

          _amountController.text = value; // Set the value in the TextField
        });

        fetchVerifiedAmount();
      },
      child: Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  decoration: BoxDecoration(
    color: selectedAmount == value ? AppColors.blue : Colors.transparent, // Background color
    border: Border.all(
      color: selectedAmount == value ? AppColors.blue : AppColors.blue,
    ),
    borderRadius: BorderRadius.circular(15),
  ),
  child: Text(
    label,
    style: TextStyle(
      fontSize: 13,
      color: selectedAmount == value ? Colors.white : Colors.black, // Text color
      fontWeight: selectedAmount == value ? FontWeight.bold : FontWeight.normal,
    ),
  ),
),

    );
  }


   Future<void> getPincodeDetails(String pincode) async {
    final url = 'https://api.postalpincode.in/pincode/$pincode';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data[0]['Status'] == 'Success') {
          setState(() {
            districtController.text = data[0]['PostOffice'][0]['District'].toString().toUpperCase();
            stateController.text = data[0]['PostOffice'][0]['State'].toString().toUpperCase();
            cityController.text = data[0]['PostOffice'][0]['City'] ?? data[0]['PostOffice'][0]['District'].toString().toUpperCase(); // Use District as city if City is not found
            countryController.text = "India".toString().toUpperCase(); // As it's India-based API, country is always India
          });
        } else {
          // Handle error if pincode is not valid
          setState(() {
            districtController.clear();
            stateController.clear();
            cityController.clear();
            countryController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid pincode entered.')),
          );
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle API call failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection. Please try again.')),
      );
    }
  }

 Future<void> fetchBankDetails(String ifsc) async {
  final bankDetails = await fetchBankDetailsFromIFSC(ifsc);

  if (bankDetails != null) {
    setState(() {
      bankNameController.text = bankDetails.bankName;
      branchLocationController.text = bankDetails.branch;
      ifscError = null;
    });
  } else {
    setState(() {
      ifscError = 'Invalid IFSC Code or no internet';
      bankNameController.clear();
      branchLocationController.clear();
    });
  }
}





 Widget buildDropdownField(
  String label,
  List<String> items,
  String? selectedValue,
  ValueChanged<String?> onChanged,
) {
  final localization = Provider.of<LocalizationProvider>(context);

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: DropdownButtonFormField<String>(
          value: items.contains(selectedValue) ? selectedValue : null, // ✅ fixed here
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            floatingLabelStyle: const TextStyle(color: AppColors.blue),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localization.translate("Please select nominee relation");
            }
            return null;
          },
        ),
      ),

      // Show TextFormField only when 'Other' is selected
      if (selectedValue == "Other")
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextFormField(
            controller: otherController,
            decoration: InputDecoration(
              labelText: localization.translate("Enter Nominee Relation"),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Color.fromARGB(255, 18, 5, 93), width: 2),
              ),
            ),
            validator: (value) {
              if (selectedValue == "Other" && (value == null || value.isEmpty)) {
              return localization.translate("Please enter nominee relation");
              }
              return null;
            },
          ),
        ),
    ],
  );
}





Widget _buildTextField({
  
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  bool readOnly = false,
  Widget? suffixIcon,
  Widget? prefixIcon,
   int? maxLength,
  String? Function(String?)? validator,
  void Function(String)? onChanged, // Add a validator parameter
}) {
  
  return Padding(
    padding: const EdgeInsets.only(bottom:  10.0),
    child: TextFormField(
      inputFormatters: [
 FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
      textInputAction: TextInputAction.next,
      controller: controller,
      textCapitalization: TextCapitalization.words,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLength: maxLength, 
      decoration: InputDecoration(
        counterText: '',
        labelText: label,labelStyle: GoogleFonts.lato(),
      
        border: const OutlineInputBorder(
          
        ),
         focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.blue, width: 2), // Focus border color
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                 floatingLabelStyle: const TextStyle(color: AppColors.blue),
 // Reduce padding

        suffixIcon: suffixIcon,
         prefixIcon: prefixIcon, 
         
         
      ),
      validator: validator, 
      onChanged: onChanged,// Attach validator function
    ),
  );
}


Widget _buildTextField4({
  required String? Function(String?)? validator, 
  required void Function(String)? onChanged,
}) {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);

  return TextFormField( // TextField బదులుగా TextFormField వాడాలి, ఎందుకంటే validation అవసరం
    textInputAction: TextInputAction.next,
    controller: ifscCodeController,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')), // Letters & Numbers Only
      LengthLimitingTextInputFormatter(11), // Max 11 Characters
       FilteringTextInputFormatter.deny(RegExp(r"[#&']"))

    ],
    textCapitalization: TextCapitalization.characters,
    maxLength: 11,
    decoration: InputDecoration(
      labelText: localization.translate("IFSC Code*"),
      labelStyle: GoogleFonts.lato(),
      hintText: 'AAAA0123456',
      
      hintStyle: GoogleFonts.lato(fontSize: 15),
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: AppColors.blue, width: 2), // Focus border color
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      floatingLabelStyle: const TextStyle(color: AppColors.blue),
      counterText: "",
    ),
    validator: validator, // Validator function added
    onChanged: onChanged, // OnChanged function added
  );
}

 

  Widget buildrow() {
     final localization = Provider.of<LocalizationProvider>(context);
    return Row(
      children: [
       
        Expanded(
          child: SizedBox(
            height: 50,
            child: 
               TextField(
                readOnly: true,
                textInputAction: TextInputAction.next,
                controller: _firstNameController,
                 textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  
                  labelText: localization.translate('First Name*'),labelStyle: GoogleFonts.lato(),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue,width: 2)
                  ), 
                   focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color:AppColors.blue, width: 2), // Focus border color
        ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              floatingLabelStyle: const TextStyle(color: AppColors.blue)
 // Reduce padding

                //  filled: true,
                 // fillColor: Colors.grey[200], // Fill color for TextField
                ),
                style: const TextStyle(fontSize: 15),
              ),
            
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: TextField(
                inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r'[",]')), // Blocks " and ,
  ],
                readOnly: true,
                textInputAction: TextInputAction.next,
                controller: _lastNameController,
                 textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                   labelText: localization.translate('Last Name*'),labelStyle: GoogleFonts.lato(),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue,width: 2)
                  ), // Remove border
                   focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.blue, width: 2), // Focus border color
        ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                         floatingLabelStyle: const TextStyle(color: AppColors.blue)
 

                 // filled: true,
                 // fillColor: Colors.grey[200], // Fill color for TextField
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }


Widget buildGenderDropdown() {
   final localization = Provider.of<LocalizationProvider>(context);
  return buildDropdownField(
    localization.translate("Gender*"), // label
    genderOptions,
    selectedGender,
    (value) async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
      selectedGender = value;
      });
      await prefs.setString('gender', selectedGender ?? '');
    }
    
  );
  
// ✅ specific message
}

Widget _buildTextField1({
  required TextEditingController controller,
  required String label,
  required File? selectedImage,
  required VoidCallback onPickImage,
  required bool isadhearRequired,
  int? maxLength,
}) {
  final localization = Provider.of<LocalizationProvider>(context);

  return Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 7,
              child: TextFormField(
                readOnly: isAdharReadOnly,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r"[#&']")),
                ],
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: maxLength,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.blue,width: 2),),
                  labelText: label,
                  counterText: "",
                  border: const OutlineInputBorder(),
                  floatingLabelStyle: TextStyle(color: AppColors.blue),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
                 validator: (value) {
              if (isnomineeadhearRequired) {
                  // Aadhaar number validation
                  if (value == null || value.isEmpty) {
                    return localization.translate("Please enter your adhar number");
                  } else if (value.length != 12) {
                    return localization.translate(" Adhar  must be 12 digits");
                  }
                  // Aadhaar image validation
                 
                  }
                  if (value == null || value.isEmpty) {
                    return localization.translate("Please enter your adhar number");
                  } else
                if (selectedImage == null && (adharImage == null || adharImage!.isEmpty)) {
                 return localization.translate("Please select Aadhaar card image");
                }
                  return null;
                },

              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Show dialog only if image exists
                if (selectedImage != null ||
                    (adharImage != null && adharImage!.isNotEmpty)) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        insetPadding: const EdgeInsets.all(10),
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: selectedImage != null
                                  ? Image.file(selectedImage)
                                  : Image.network(adharImage!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 20,
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            // Show edit only if image is NOT from API
                            if (selectedImage != null)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    onPickImage();
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 20,
                                    child:
                                        Icon(Icons.edit, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  // If no image at all, open picker
                  onPickImage();
                }
              },
              child: Stack(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 236, 236),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: selectedImage != null
                          ? Image.file(selectedImage, fit: BoxFit.cover)
                          : (adharImage != null && adharImage!.isNotEmpty)
                              ? Image.network(adharImage!, fit: BoxFit.cover)
                              : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTextField3({
  
  required TextEditingController controller,
  required String label,
  required File? selectedImage,
  required VoidCallback onPickImage,
   required bool isnomineeadhearRequired, // New param to control validation
 // required String? Function(String?)? validator,
  int? maxLength,
}) {
  final localization = Provider.of<LocalizationProvider>(context);
  return Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 7,
              child: TextFormField(
                inputFormatters: [
     FilteringTextInputFormatter.deny(RegExp(r"[#&']"))
 // Blocks " and ,
  ],
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: maxLength,
                decoration: InputDecoration(
                  labelText: label,
                  counterText: "",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.blue,width: 2),),
                  floatingLabelStyle: TextStyle(color: AppColors.blue),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
                validator: (value) {
              if (isnomineeadhearRequired) {
                  // Aadhaar number validation
                  if (value == null || value.isEmpty) {
                    return localization.translate("Please enter nominee adhar number");
                  } else if (value.length != 12) {
                    return localization.translate(" Nominee Adhar number must be 12 digits");
                  }
                  // Aadhaar image validation
                 
                  }
                  if (value == null || value.isEmpty) {
                    return localization.translate("Please enter nominee adhar number");
                  } else
                if (selectedImage == null && (nomineeimage == null || nomineeimage!.isEmpty)) {
                 return localization.translate("Please select nominee Aadhar card image");
                }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
  onTap: () {
    if (selectedImage != null || (nomineeimage != null && nomineeimage!.isNotEmpty)) {
      // Show image in full screen dialog with edit icon
      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            insetPadding: const EdgeInsets.all(10),
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: selectedImage != null
                      ? Image.file(selectedImage)
                      : Image.network(nomineeimage!, fit: BoxFit.cover),
                ),

                 Positioned(
      top: 10,
      left: 10,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Close the dialog
        },
        child: const CircleAvatar(
          backgroundColor: Colors.black54,
          radius: 20,
          child: Icon(Icons.close, color: Colors.white, size: 20),
        ),
      ),
    ),

          

                
  Positioned(
  top: 10,
  right: 10,
  child:
       InkWell(
          onTap: () {
            Navigator.pop(context); // Close the dialog
            onPickImage();          // Open picker options
          },
          child: const CircleAvatar(
            backgroundColor: Colors.black54,
            radius: 20,
            child: Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        )
      
),
              ],
            ),
          );
        },
      );
    } else {
      onPickImage(); // no image yet, directly open picker
    }
  },
  child: Stack(
    children: [
      Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 236, 236),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: selectedImage != null
              ? Image.file(selectedImage, fit: BoxFit.cover)
              : (nomineeimage != null && nomineeimage!.isNotEmpty)
                  ? Image.network(nomineeimage!, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.grey),
        ),
      ),
    ],
  ),
),

          ],
        ),
      ],
    ),
  );
}



Widget _buildTextField2({
  required TextEditingController controller,
  required String label,
  required File? selectedImage,
  required VoidCallback onPickImage,
  required bool isPanRequired,
  int? maxLength,
  String? hintText,
}) {
  final localization = Provider.of<LocalizationProvider>(context,listen: false);

  return Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 7,
              child: TextFormField(
                readOnly: isPanReadOnly,
                controller: controller,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                maxLength: maxLength,
                decoration: InputDecoration(
                   focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.blue,width: 2),),
                  floatingLabelStyle: TextStyle(color: AppColors.blue),
                  labelText: label,
                  hintText: hintText,hintStyle: TextStyle(fontSize: 10),
                  counterText: "",
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
                validator: (value) {
                  final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

                  if (isPanRequired) {
                    if (value == null || value.isEmpty) {
                      return localization.translate("Please enter PAN number");
                    } else if (!panRegex.hasMatch(value)) {
                      return localization.translate("Invalid PAN format (e.g., ABCDE1234F)");
                    } else if (selectedImage == null &&
                        (panImage == null || panImage!.isEmpty)) {
                      return localization.translate("Please select PAN card image");
                    }
                  } else {
                    if (value != null && value.isNotEmpty) {
                      if (!panRegex.hasMatch(value)) {
                        return localization.translate("Invalid PAN format (e.g., ABCDE1234F)");
                      }
                    }
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // If image already exists from API or file, open viewer
                if (selectedImage != null ||
                    (panImage != null && panImage!.isNotEmpty)) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        insetPadding: const EdgeInsets.all(10),
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: selectedImage != null
                                  ? Image.file(selectedImage)
                                  : Image.network(panImage!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 20,
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            // Show edit icon only if selectedImage is NOT from API
                            if (selectedImage != null)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    onPickImage();
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 20,
                                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  // If no image, open picker directly
                  onPickImage();
                }
              },
              child: Stack(
                children: [
                 Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 236, 236),
                      borderRadius: BorderRadius.circular(8),
                    ),
                     child: ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                      child: selectedImage != null
                          ? Image.file(selectedImage, fit: BoxFit.cover)
                          : (panImage != null && panImage!.isNotEmpty)
                              ? Image.network(panImage!, fit: BoxFit.cover)
                              : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}








}


  


