

import 'package:csc/loginfolder/loginscreen.dart';
import 'package:csc/dashboardscreens/custmer_care.dart';
import 'package:csc/dashboardscreens/brocher%20page.dart';
import 'package:csc/dashboardscreens/active_scheme.dart';
import 'package:csc/dashboardscreens/transations.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/dashboardscreens/saving%20account.dart';
import 'package:csc/utillity/constantcolor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
      return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const NavigationDrawerScreen(),
    ),
  );
}

class NavigationDrawerScreen extends StatefulWidget {
const NavigationDrawerScreen({super.key});

  @override
  State<NavigationDrawerScreen> createState() => _NavigationDrawerScreenState();
}

class _NavigationDrawerScreenState extends State<NavigationDrawerScreen> {
  String firstName = "User"; 
  String lastName = "Name"; 

  @override
  void initState() {
  super.initState();
  loadUserDetails(); 
  }

  Future<void> loadUserDetails() async {
  final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? "User"; 
      lastName = prefs.getString('lastName') ?? "Name";
    });
  }


 void openPrivacyPolicy() async {
  final Uri url = Uri.parse('https://cscjewellers.com/privacy_policy.php');
  if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Unable to open link")),
    );
  }
}



Future<void> logout() async {
 final prefs = await SharedPreferences.getInstance();

// Step 1: Save 'isFirstTime' value temporarily
final isFirstTime = prefs.getBool('isFirstTime') ?? false;

// Step 2: Clear all
await prefs.clear();

// Step 3: Restore 'isFirstTime'
await prefs.setBool('isFirstTime', isFirstTime);

  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LoginScreen1()), 
     // (route) => false, // Remove all previous routes
      );
  }

  

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(context, localization),
            buildMenuItems(context, localization),
          ],
        ),
      ),
    );
  }

 Widget buildHeader(BuildContext context, LocalizationProvider localization) {
  double topPadding = MediaQuery.of(context).padding.top;
  double screenHeight = MediaQuery.of(context).size.height;

  return SizedBox(
    width: double.infinity,
   // height: screenHeight * 0.20,
    child: Stack(
      children: [
        /// Blue Header Container
        Container(
          width: double.infinity,
          color:AppColors.blue,
          padding: EdgeInsets.only(
            top: 24 + topPadding,
            bottom: screenHeight * 0.03,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/csc2.png',
                color: Colors.white,
                height: screenHeight * 0.05,
                fit: BoxFit.contain,
              ),

              

              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                 

                          SizedBox(width: 8,),
                  Text(
                    "$firstName $lastName",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: screenHeight * 0.020,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// Blue Curve at Bottom
       
      ],
    ),
  );
}


  Widget buildMenuItems(BuildContext context, LocalizationProvider localization) {
  double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),  // 6% of screen width for padding
      child: Wrap(
        spacing: 16,
        children: [
          buildMenuTile("assets/images/schme.png", localization.translate("Join Scheme"), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SavingsAccountScreen()),
            );
          }),

          buildMenuTile("assets/images/myschme.png", localization.translate("My Scheme"), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentCard()),
            );
          }),


          buildMenuTile("assets/images/customre.png", localization.translate("Customer Care"), () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomerCare()),
            );
          }),


          buildMenuTile("assets/images/transation.png", localization.translate("Transactions"), () {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Transaction()),
            );
          }),


          buildMenuTile("assets/images/browser.png", localization.translate("Brochure"), () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BrochureScreen()),
            );
          }),


           ListTile(
  leading: Icon(Icons.privacy_tip, color: Colors.blue),
  title: Text(localization.translate("Privacy & Policy"), 
  style: GoogleFonts.lato(fontSize: 14)),
  onTap: openPrivacyPolicy,
),

           buildMenuTile("assets/images/logout.png", localization.translate("LogOut"), () {
         logout();
          }),



        

        ],
      ),
    );
  }

 ListTile buildMenuTile(String assetPath, String title, Function() onTap) {
  double screenWidth = MediaQuery.of(context).size.width;  // Get screen width

  return ListTile(
    leading: Image.asset(
      assetPath,
      width: screenWidth * 0.08,  
      height: screenWidth * 0.08, 
      fit: BoxFit.contain,
    ),
    title: Text(title, style: GoogleFonts.lato(fontSize: 14)),
    onTap: onTap,
  );
}

}
