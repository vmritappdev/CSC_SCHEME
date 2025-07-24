import 'dart:convert';
import 'dart:io';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/model/installment.dart';
import 'package:csc/model/loginresponse.dart';
import 'package:csc/upidetails/payment%20verify.dart';
import 'package:csc/utillity/sample.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';


void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: PaymentDetailsScreen(activescheme: Activescheme(),payid: '',rejectId: '',),
    ),
  );
}



class PaymentDetailsScreen extends StatefulWidget {
  final Activescheme activescheme;
    final String payid;
     final String rejectId;


  const PaymentDetailsScreen({super.key, required this.activescheme,required this.payid,required this.rejectId});

  @override
  _PaymentDetailsScreenState createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {

 





  String? _paymentType;
   String? id;
  File? _selectedImage;

  final TextEditingController _transactionNumberController = TextEditingController();
  bool _isLoading = false;
  VerificationResponse? verificationResponse;
  Installment? installment;
  bool _showImageError = false;

  



  @override
  void initState() {
    super.initState();
    _fetchVerificationResponse();
    _fetchInstallmentResponse();
    _submitDetails();
     print("Received pay_id: ${widget.payid}");
     print("📤 Final amount sending to API: ${widget.activescheme.amountRs}");

   
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

  

  // Fetch Verification Response
  Future<void> _fetchVerificationResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseUrl/process_verification.php');

    try {
      final response = await http.post(url, body: {'mobile_no': mobileNumber});

      

       

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
            print(data);
          verificationResponse = VerificationResponse.fromJson(data);
        } else {
          print("Response body is empty.");
            
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<void> _fetchInstallmentResponse() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  setState(() {
    _isLoading = true;
  });

  final url = Uri.parse('https://vmrdemos.com/csc_scheme/pay_due_details.php');

  try {
    final response = await http.post(url, body: {'mobile_no': mobileNumber});

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        print(data); // Log the raw data to inspect it

        // If the response is a list, you need to handle it as a list
        if (data is List) {
          // Map the list of items to a list of Installment objects
          List<Installment> installments = data.map((item) => Installment.fromJson(item)).toList();

          // You can then update your state or handle the installments as needed
          setState(() {
            installments = installments; // Assuming you have a list variable _installments
          });
        } else {
          print("Expected a list but received: $data");
        }
      } else {
        print("Response body is empty.");
      }
    } else {
      print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching data: $e");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  

  // Pick Image Function with AlertDialog
  Future<void> _pickImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context); // Close the dialog
                  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context); // Close the dialog
                  final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    setState(() {
                    _selectedImage = File(pickedImage.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete Image
  void _deleteImage() {
    setState(() {
      _selectedImage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image deleted successfully.")),
    );
  }

  // Share Image
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

  // Submit Payment Details
 // Submit Payment Details
Future<void> _submitDetails() async {
  Provider.of<LocalizationProvider>(context, listen: false);

/*
  if (_transactionNumberController.text.isEmpty) {
    setState(() {
      _statusMessage = localization.translate("Please fill the Transaction Number.");
    });
    return;
  }
  */

  if (_selectedImage == null) {
  setState(() {
  });
  return;
}


  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');


   bool hasInternet = await checkInternet();
    if (!hasInternet) {
     // _showInvalidOTPDialog("❌ Network connection not available. Please check your internet.");

     Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>  ErrorScreen()), // ✅
  );
      return;
    }

  setState(() {
    _isLoading = true;
  });

  try {
    var uri = Uri.parse("$baseUrl/save_pay_request.php");

    var request = http.MultipartRequest("POST", uri);
    
    request.fields['payment_type'] = _paymentType ?? "";
    request.fields['id'] = widget.activescheme.schemeID.toString();
    request.fields['transaction_no'] = _transactionNumberController.text;
    //request.fields['pay_id'] = widget.activescheme.payId.toString();
 request.fields['pay_id'] = (widget.rejectId.isNotEmpty) ? widget.rejectId : widget.payid;



    request.fields['status'] = "pending";
    request.fields['mobile_number'] = mobileNumber!;
    request.fields['scheme_id'] = widget.activescheme.schemeID;
    request.fields['month'] = widget.activescheme.month;
    request.fields['year'] = widget.activescheme.year;
    request.fields['amount'] = widget.activescheme.amountRs;
   


    if (_selectedImage != null && _selectedImage!.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'screen_short',
        _selectedImage!.path,
      ));
    } else {
      print("No Image selected.");
      print("Pay ID being sent: ${request.fields['pay_id']}");

    }

    print("Reject ID: ${widget.rejectId}");
print("Pay ID: ${widget.payid}");


    print("======================================");
    print("🚀 Sending API Request...");
    print("👉 API URL: $uri");
    print("👉 Request Fields: ${request.fields}");
    print("👉 Image Attached: ${_selectedImage != null ? 'Yes' : 'No'}");
    print("======================================");
    print("🚀 Sending Amount to API: ${widget.activescheme.amountRs}");


    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print("Response Status: ${response.statusCode}");
    print("Response Body: $responseBody");
    

    if (responseBody.isEmpty) {
      print("Error: Response body is null or empty.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Response is empty or invalid.")),
      );
      return;
    }

    late Map<String, dynamic> jsonResponse;
    try {
      jsonResponse = json.decode(responseBody);
    } catch (e) {
      print("Error parsing JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error parsing server response.")),
      );
      return;
    }

    if (jsonResponse['status'].toString() == "200") {
      String? id = jsonResponse['id']?.toString();

      if (id != null && id.isNotEmpty) {
        _showSuccessPopup(context, id);
      } else {
        print("Error: ID is null or empty in response.");
        print("Month: ${jsonResponse['month'] ?? 'Default'}");
print("Pay ID: ${jsonResponse['pay_id'] ?? 'Not Available'}");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['message'] ?? "Submission failed.")),
      );
    }
  } catch (e) {
    print("Error submitting payment: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    
double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final localization = Provider.of<LocalizationProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
       // iconTheme: IconThemeData(color: Colors.white),
       leading: BackButton(
        color: Colors.white,
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => HomeScreen(activescheme: Activescheme(),),
            )
          );
        },
       ),
        backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
        title: Text(
          localization.translate("Payment Details"),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(2, 5, 62, 1),))
          : SingleChildScrollView(
              child: Padding(
               padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // 5% of screen width
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   // Text(localization.translate("Payment Type"), style: const TextStyle(fontWeight: FontWeight.bold)),
                    //const SizedBox(height: 10),
                    //DropdownButtonFormField<String>(
                     // value: _paymentType,
                    //  items: const [
                       // DropdownMenuItem(child: Text("UPI"), value: "UPI"),
                      //  DropdownMenuItem(child: Text("Bank Transfer"), value: "Bank"),
                     // ],
                     // onChanged: (value) => setState(() => _paymentType = value),
                     // decoration: const InputDecoration(border: OutlineInputBorder()),
                   // ),
                    const SizedBox(height: 20),


                       Padding(
  padding: const EdgeInsets.only(top: 8, bottom: 16),
  child: Text(
   localization.translate("Kindly upload the payment slip or a screenshot below for verification of your payment."),
    style: TextStyle(
      fontSize: screenWidth * 0.035,
      fontWeight: FontWeight.bold,
      color:  const Color.fromRGBO(2, 5, 62, 1),
     // fontStyle: FontStyle.italic
    ),
  ),
),

               SizedBox(height: screenHeight * 0.02),



               Text(
                      localization.translate("Upload Screenshot (Required)"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                      // SizedBox(height: screenHeight * 0.03),
                   GestureDetector(
  onTap: () => _pickImage(context),
  child: Stack(
    children: [
      Container(
        height: screenHeight * 0.15,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: _selectedImage != null
            ? Image.file(
                _selectedImage!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            : Center(child: Text(localization.translate("Tap to Upload Screenshot"))),
      ),
      if (_selectedImage != null)
        Positioned(
          top: 8,
          right: 8,
          child: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Delete':
                  _deleteImage();
                  break;
                case 'Share':
                  _shareImage();
                  break;
                case 'Download':
                  _downloadImage();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Delete', child: Text('Delete')),
              const PopupMenuItem(value: 'Share', child: Text('Share')),
              const PopupMenuItem(value: 'Download', child: Text('Download')),
            ],
            icon: const Icon(Icons.more_vert, color: Color.fromRGBO(2, 5, 62, 1)),
          ),
        ),
    ],
  ),
),
if (_showImageError)
   Padding(
    padding: EdgeInsets.only(top: 5),
    child: Text(
    localization.translate("Please fill the image") ,
      style: TextStyle(color: Colors.red, fontSize: 13),
    ),
  ),




                    SizedBox(height: screenHeight * 0.02),


                   TextField(
                    keyboardType: TextInputType.name,
  controller: _transactionNumberController,
  decoration:  InputDecoration(
    
   // labelText: localization.translate("Transaction Number"),
   labelText:localization.translate('Transaction Number'),
    labelStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: screenWidth * 0.035), // Label text
    border: const OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015, horizontal: screenWidth * 0.03),
     // Adjust padding
  ),

   
  
),

                 SizedBox(height: screenHeight * 0.03),
                    
                     SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                       width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                             setState(() {
    _showImageError = _selectedImage == null;
  });

  if (_selectedImage != null) {
    _submitDetails();
  }
                            
                          // _submitDetails();
            //SharedPreferences.getInstance().then((prefs) {
            //  prefs.setBool('isTransactionComplete', true);
              //Navigator.pop(context, true);

              
           // });
          },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(),
                          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
                        ),

      

                        
                        child: Text(localization.translate("Confirm"), style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  

                  


                  




                  ],
                ),
              ),
            ),
    );
  }


 void _showSuccessPopup(BuildContext context, String id) async {  
  final localization = Provider.of<LocalizationProvider>(context, listen: false);
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    barrierDismissible: false, // User popup వదిలి వెళ్ళలేడు
    builder: (context) => WillPopScope(
      onWillPop: () async => false, // Back press block చేస్తుంది
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Container(
          width: double.infinity,
          color: Colors.green,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.25,
                width: screenWidth * 0.6,
                child: Lottie.asset(
                  'assets/images/suc2.json',
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                localization.translate('Congratulations!'),
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localization.translate("Your scheme registration is complete, but payment verification is still pending. Please wait while we complete the verification process."),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to PaymentVerificationScreen & remove previous screens
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => PaymentVerificationScreen(id: id)),
                    (Route<dynamic> route) => false, // Clear all previous screens
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(localization.translate('okay')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
