import 'dart:convert';
import 'dart:io';


import 'package:csc/dashboardscreens/active_scheme.dart';
import 'package:csc/dashboardscreens/faq_screen.dart';

import 'package:csc/editprofile/editmpin.dart';
import 'package:csc/editprofile/editprofile.dart';
import 'package:csc/localization/localizationpro.dart';

import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen2 extends StatefulWidget {
  const ProfileScreen2({super.key});

  @override
  State<ProfileScreen2> createState() => _ProfileScreen2State();
}

class _ProfileScreen2State extends State<ProfileScreen2> {


   File? _image; // Variable to hold the image file
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

   String firstName = "";
    String phoneNumber = '';
    String savedImageUrl = ''; // Variable to hold the saved image URL
    String lastName = "";

   Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? "";
      phoneNumber = prefs.getString('phoneNumber') ?? ""; // Default if not found
      lastName = prefs.getString('lastName') ?? "";
    });
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



   Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen1()), // Replace with your main app entry point
      (route) => false, // Remove all previous routes
    );
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




  // Function to pick image from Gallery or Camera
Future<void> _pickImage() async {
  final choice = await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Choose Option"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(1), child: const Text("Gallery")),
          TextButton(onPressed: () => Navigator.of(context).pop(2), child: const Text("Camera")),
        ],
      );
    },
  );

  if (choice == null) return;

  XFile? pickedFile;
  if (choice == 1) {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  } else if (choice == 2) {
    pickedFile = await _picker.pickImage(source: ImageSource.camera);
  }

  if (pickedFile != null) {
    // 👇 Show loader immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color.fromRGBO(2, 6, 67, 1),)),
    );

    try {
      // 👇 Upload image and handle path
      File newImage = File(pickedFile.path);
      setState(() {
        _image = newImage;
        savedImageUrl = pickedFile!.path;
      });

      // Save image path and upload to server
      await saveImagePath(pickedFile.path);
      await updateProfileDetails(phoneNumber, newImage);

      // 👇 Hide loader quickly after upload
      Navigator.of(context).pop();

      // 👇 Success message
      Fluttertoast.showToast(
        msg: "Image uploaded successfully!",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      // 👇 Hide loader quickly if error occurs
      Navigator.of(context).pop();

      // 👇 Error message
      Fluttertoast.showToast(
        msg: "Failed to upload image!",
        backgroundColor: Colors.red,
      );
    }
  } else {
    print("No image selected.");
  }
}

Future<void> updateProfileDetails(String mobileNo, File? profileImage) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  if (mobileNumber == null) {
    print("Mobile number not found.");
    return;
  }

  final String apiUrl = "$baseUrl/profile.php";

  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['mobile_no'] = mobileNumber;
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

  if (mobileNumber == null) {
    print("Mobile number not found.");
    return; // Exit if no mobile number
  }

  final String apiUrl = "$baseUrl/get_profile_image.php"; // Update API URL if needed

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
        final localization = Provider.of<LocalizationProvider>(context);

   

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            // Top section with background
        Container(
  width: double.infinity,
  color: const Color.fromRGBO(2, 5, 67, 1),
  padding: const EdgeInsets.fromLTRB(16, 40, 16, 24), // Top padding increased
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Back Button
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.arrow_back,
          size: 28,
          color: Colors.white,
        ),
      ),

      const SizedBox(height: 20), // Gap between back button and profile

      // Row with avatar and name/phone
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with camera icon
          Stack(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  "CM",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage, // Your image pick function
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.teal[700],
                    ),
                  ),
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
                    firstName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                    Text(
                    lastName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                phoneNumber,
                style: const TextStyle(
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

        
            const SizedBox(height: 28),
        
            // List Items
            _buildTile(Icons.person, 'Change Profile'),
        
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Divider(),
            ),
        
        
        
            
            _buildTile(Icons.history, 'Change Mpin'),
        
                      const Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Divider(),
            ),
        
            
           // _buildTile(Icons.account_balance_wallet, 'Wallet', badge: 'New✨'),
           // _buildTile(Icons.shield, 'Manage CheQ Safe', badge: 'No Email Linked', badgeColor: Colors.pink),
            
            _buildTile(Icons.help_outline, 'Help & Support'),
        
                      const Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Divider(),
            ),
        
             
        
           // const Spacer(),
        
           const SizedBox(height: 190,),
        
            // Bottom Logout and Terms
        InkWell(
          onTap: () {
          logout();
            print("User logged out");
            // Example:
            // SharedPreferences prefs = await SharedPreferences.getInstance();
            // await prefs.clear();
            // Navigator.pushReplacement(...);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.power_settings_new, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text("Logout", style: TextStyle(fontSize: 16, color: Colors.red)),
            ],
          ),
          Text(
            "Terms & Policies",
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
                  Navigator.pop(context);
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
    );
  }

  Widget _buildTile(IconData icon, String title) {
  return InkWell(
    onTap: () {
      if (title == 'Change Profile') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
      } else if (title == 'Change Mpin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditMPINScreen()),
        );
      } else if (title == 'Help & Support') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FAQScreen()),
        );
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between text & arrow
        children: [
          Row(
            children: [
              Icon(icon, color: const Color.fromRGBO(5, 6, 67, 1),),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Arrow icon
        ],
      ),
    ),
  );
}


}
