import 'dart:convert';
import 'dart:io';


import 'package:csc/dashboardscreens/home_screen.dart';

import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/faq_screen.dart';
import 'package:csc/dashboardscreens/active_scheme.dart';
import 'package:csc/editprofile/editmpin.dart';
import 'package:csc/editprofile/editprofile.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
      home: const ProfileScreen(schemeID: '',),
    ),
  );
}

class ProfileScreen extends StatefulWidget {

  final String schemeID; // Optional image path parameter

  const ProfileScreen({super.key, required this.schemeID});
  
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image; // Variable to hold the image file
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

   String firstName = "";
    String lastName = "";
    String phoneNumber = '';
    String savedImageUrl = ''; // Variable to hold the saved image URL

   Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? "";
      phoneNumber = prefs.getString('phoneNumber') ?? ""; // Default if not found
      lastName = prefs.getString('lastName') ?? "";
    });
  }



     Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen1()), // Replace with your main app entry point
      //(route) => false, // Remove all previous routes
    );
  }

   @override
  void initState() {
    super.initState();
    loadUserDetails(); 
    loadImagePath();// Fetch shared preferences values
     WidgetsBinding.instance.addPostFrameCallback((_) {
    // Replace with actual mobile number and image path
    updateProfileDetails(phoneNumber, _image); // Directly pass the File? object


     fetchAndSaveImage(); // Replace with actual API response data

  // Load saved image URL on app start
  loadImagePath();

  });
  }

  
 Future<void> saveImagePath(String imagePath) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('saved_image_url', imagePath); // Corrected key
}


Future<void> loadImagePath() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    savedImageUrl = prefs.getString('saved_image_url') ?? ''; // Corrected key
  });
}







  
  //File? _imageFile;

Future<void> _pickImage() async {
  final choice = await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Choose Option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Gallery"),
              onTap: () => Navigator.of(context).pop(1),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Camera"),
              onTap: () => Navigator.of(context).pop(2),
            ),
          ],
        ),
      );
    },
  );

  if (choice == null) return;

  final ImageSource source =
      (choice == 1) ? ImageSource.gallery : ImageSource.camera;

  // ✅ Permission Handling
  Permission permission;
  if (source == ImageSource.camera) {
    permission = Permission.camera;
  } else {
    if (Platform.isAndroid) {
      permission = Permission.photos; // Android 13+ support
    } else {
      permission = Permission.photos; // iOS
    }
  }

  final status = await permission.request();

  if (!status.isGranted) {
    Fluttertoast.showToast(
      msg: "${permission.toString()} permission denied",
      backgroundColor: Colors.red,
    );
    return;
  }

  try {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File newImage = File(pickedFile.path);

      // ✅ Show Loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(2, 6, 67, 1),
            ),
          ),
        ),
      );

      // Simulate upload/save
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _image = newImage;
        savedImageUrl = pickedFile.path;
      });

      await saveImagePath(pickedFile.path); // Save locally
      await updateProfileDetails(phoneNumber, newImage); // Upload to server

      Navigator.of(context).pop(); // Close loader

      Fluttertoast.showToast(
        msg: "Image updated successfully!",
        backgroundColor: Colors.green,
      );
    } else {
      Fluttertoast.showToast(
        msg: "No image selected.",
        backgroundColor: Colors.orange,
      );
    }
  } catch (e) {
    Navigator.of(context).pop(); // Close loader if error
    Fluttertoast.showToast(
      msg: "Failed to pick image.",
      backgroundColor: Colors.red,
    );
  }
}

Future<void> updateProfileDetails(String mobileNo, File? profileImage) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  String apiUrl = "$baseUrl/profile.php";

  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['mobile_no'] = mobileNumber!;
   //  request.fields['profile_image'] = ImagePicker().toString(); // Add mobile number to request

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        profileImage.path,
      ));
    }

    var response = await request.send();
    final responseString = await response.stream.bytesToString();

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: $responseString");

    

    if (response.statusCode == 200) {
      final responseData = jsonDecode(responseString);
      if (responseData['image'] != null && responseData['image'].isNotEmpty) {
        String newImageUrl = '$baseUrl/images/${responseData['image']}';
        
        await prefs.setString('saved_image_url', newImageUrl); // Save new image URL
        setState(() {
          savedImageUrl = newImageUrl;
        });

        print("Updated image URL: $newImageUrl");
      }
    } else {
      print("Failed to update profile. Status Code: ${response.statusCode}");
    }
  } catch (error) {
    print("Error making API call: $error");
  }
}




Future<void> fetchAndSaveImage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  String apiUrl = "$baseUrl/get_profile_image.php"; // Update API URL if needed

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'mobile_no': mobileNumber},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['image'] != null && responseData['image'].isNotEmpty) {
        final String imageUrl = '$baseUrl/images/${responseData['image']}';
        
        await prefs.setString('saved_image_url', imageUrl); // Save URL in SharedPreferences

        setState(() {
          savedImageUrl = imageUrl;
        });

        print("Fetched and saved image: $imageUrl");
      } else {
        print("No image found in API response.");
      }
    } else {
      print("Failed to fetch image. Status Code: ${response.statusCode}");
    }
  } catch (error) {
    print("Error fetching image: $error");
  }
}


  @override
  Widget build(BuildContext context) {

    


    final localization = Provider.of<LocalizationProvider>(context,listen: false);

    return WillPopScope(
       onWillPop: () async {
Navigator.pop(context);
      return false; // Prevent default back action
    },
      
        child: Scaffold(
          
         appBar: AppBar(elevation: 0,backgroundColor:  Color.fromRGBO(2, 5, 67, 1),iconTheme: IconThemeData(color: Colors.white),),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                   Container(
                    width: double.infinity,
                    color: Color.fromRGBO(2, 5, 67, 1),
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 10), // Top padding increased
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                  
                  
                    const SizedBox(height: 20), // Gap between back button and profile
                  
                    // Row with avatar and name/phone
                    Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with camera icon
             Stack(
                    children: [
                     Positioned(
            child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _viewImage(context),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: savedImageUrl.isNotEmpty
                            ? (savedImageUrl.startsWith('http')
                                ? NetworkImage(savedImageUrl)
                                : FileImage(File(savedImageUrl))) as ImageProvider
                            : null,
                        child: savedImageUrl.isEmpty
                            ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickImage(),
                        child: const CircleAvatar(
                        radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Color.fromRGBO(2, 5, 62, 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                    ),
                    
                    ],
                  ),
              const SizedBox(width: 16),
              // Name and number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [


                      Text(
                        '$firstName',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      

                      SizedBox(width: 8,),
                  
                        Text(
                        '$lastName',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '91+ $phoneNumber',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
                    ),
                  ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const SizedBox(height: 20),
                    
                  // Navigation Buttons
                 _buildButton(
            label: localization.translate("Change Profile"), // Pass localized string here
            icon: Icons.person,
            onPressed: () {
                    // Navigate to Edit Profile Screen
                    Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
            },
                    ),
                    _buildButton(
            label: localization.translate("Change Mpin"), // Pass localized string
            icon: Icons.lock,
            onPressed: () {
                    Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditMPINScreen()),
                    );
            },
                    ),
                    
                    
                  
                    
                    _buildButton(
            label: localization.translate("Help & Support"), // Pass localized string
            icon: Icons.help,
            onPressed: () {
                    Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FAQScreen()),
                    );
            },
                    ),
                    
                  const SizedBox(height: 40),
                  
                  
                  
                  
                    InkWell(
              onTap: () {
              logout();
                print("User logged out");
                // Example:
                // SharedPreferences prefs = await SharedPreferences.getInstance();
                // await prefs.clear();
                // Navigator.pushReplacement(...);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children:  [
                  Icon(Icons.power_settings_new, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text(localization.translate("Logout"), 
                  style: TextStyle(fontSize: 16, color: Colors.red)),
                ],
              ),
               Text(
                 localization.translate("Terms & Policies"),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: Colors.teal),
              ),
            ],
                ),
              ),
            ),
                    
                  
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Handle logout action
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentCard(),
                ) 
              ); // Redirect or logout functionality
            },
            label: Text(
              localization.translate("My Scheme"),
              style: const TextStyle(color: Colors.white),
            ),
           // icon: Icon(Icons.logout, color: Colors.white),
            backgroundColor: Colors.red,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: const Color.fromRGBO(2, 5, 62, 1),
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: () {
                   
                     Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(activescheme: Activescheme()),
                      )
                     );
                    },
                  ),
                  IconButton(
                    icon:Image.asset('assets/images/faq.png',width: 30,height: 30,color: Colors.white,),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FAQScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      
    );
  }

 Widget _buildButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  Provider.of<LocalizationProvider>(context, listen: false);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: const Color.fromRGBO(2, 5, 62, 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
      ),
      icon: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(icon, color: const Color.fromRGBO(2, 5, 62, 1), size: 20),
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    ),
  );
}






  void _viewImage(BuildContext context) {
    if (savedImageUrl.isEmpty) {
     _pickImage();
      return;
    }
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image(
                  image: savedImageUrl.startsWith('http')
                      ? NetworkImage(savedImageUrl)
                      : FileImage(File(savedImageUrl)) as ImageProvider,
                ),
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                 _pickImage();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: Colors.black),
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


/*

 const SizedBox(height: 50),
              Stack(
                children: [
                 Positioned(
        child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _viewImage(context),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: savedImageUrl.isNotEmpty
                        ? (savedImageUrl.startsWith('http')
                            ? NetworkImage(savedImageUrl)
                            : FileImage(File(savedImageUrl))) as ImageProvider
                        : null,
                    child: savedImageUrl.isEmpty
                        ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Color.fromRGBO(2, 5, 62, 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ),
      
                ],
              ),

              */