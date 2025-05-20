 import 'dart:convert';



import 'package:carousel_slider/carousel_slider.dart';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/insatllment.dart';
import 'package:csc/chaingedscreens.dart/scner.dart';
import 'package:csc/chaingedscreens.dart/installmentviewdetails.dart';
import 'package:csc/dashboardscreens/notification.dart';
import 'package:csc/editprofile/crearempin3.dart';
import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/dashboardscreens/aboutscreen.dart';
import 'package:csc/dashboardscreens/custmer_care.dart';
import 'package:csc/dashboardscreens/brocher%20page.dart';
import 'package:csc/dashboardscreens/faq_screen.dart';
import 'package:csc/dashboardscreens/offers_screen.dart';
import 'package:csc/dashboardscreens/active_scheme.dart';
import 'package:csc/dashboardscreens/join_scheme.dart';
import 'package:csc/dashboardscreens/transations.dart';
import 'package:csc/dashboardscreens/user_profile.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/dashboardscreens/saving%20account.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/model/loginresponse.dart';
import 'package:csc/navigation_drwer.dart';
import 'package:csc/upidetails/loding%20screen.dart';



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
      home:HomeScreen(activescheme: Activescheme()),
    ),
  );
}



class HomeScreen extends StatefulWidget {
   final Activescheme activescheme;

   const HomeScreen({super.key, required this.activescheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); 
}

class _HomeScreenState extends State<HomeScreen> {

  bool _backButtonPressedOnce = false;

   
 VerificationResponse? verificationResponse;

  int _selectedIndex = 0;

  void _navigateTo(int index) {
  // Select the tab icon
  setState(() => _selectedIndex = index);

  // Don't navigate if it's Home (index 0)
  if (index == 0) return;

  Widget screen;

  switch (index) {
    case 1:
      screen = const AboutUsScreen();
      break;
    case 2:
      screen = const GoldShopOffersScreen();
      break;
    case 3:
      screen = const FAQScreen();
      break;
    default:
      return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => screen),
  ).then((_) {
    // After coming back from any screen, set Home tab as selected
    setState(() => _selectedIndex = 0);
  });
}




   int selectedIndex = 0;
    bool isButtonClicked = false;
  bool isProcessComplete = false;
   final bool _isPopupShown = false; 

    final List<String> images = [
    'assets/images/jewe.jpg',
    'assets/images/jewe2.jpg',
    'assets/images/gold1.jpg',
    'assets/images/jewe2.jpg',
  ];

   int activeIndex = 0;
   String errorMessage = '';
   
    final String _selectedLanguage = 'తె';


     String firstName = '';  // Default value for first name
     String lastName = ''; 
     String mobileNumber = '';

  Future<void> _loadButtonState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
  isButtonClicked = prefs.getBool('isButtonClicked') ?? false;
    });
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
 




 

// Method to store mobile number
Future<void> saveMobileNumber(String mobileNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('mobile_number', mobileNumber);
  print("Mobile number saved: $mobileNumber");
}

// Method to fetch mobile number
Future<String?> getMobileNumber() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('mobile_number');
}



bool _popupShown = false; // To track if popup is already shown


void _startPolling() {
  if (!_isPolling) return; // ✅ Stop if polling is off

  Future.delayed(const Duration(seconds: 1), () async {
    if (_isPolling) {
      await _fetchVerificationResponse();
    
      _startPolling(); // Continue polling
    }
  });
}



bool _isPolling = true; // Flag to control polling
bool _isPollingStarted = false;

@override
void dispose() {
  _isPolling = false; // Stop polling when the widget is disposed
  super.dispose();
   _isPollingStarted = false; // ఫ్లాగ్ రీసెట్ చేయండి
}



Future<void> _fetchVerificationResponse() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');
  String schemeId = widget.activescheme.schemeID;

  final url = Uri.parse('$baseUrl/process_verification.php');  //'https://vmrdemos.com/csc_scheme/process_verification.php'

  try {
    final response = await http.post(
      url,
      body: {
        'mobile_no': mobileNumber,
        'scheme_id': schemeId, 
      },
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          VerificationResponse verificationResponse = VerificationResponse.fromJson(data);

          // Updating the UI
          setState(() {
            this.verificationResponse = verificationResponse;
          });

          // Extract `schemeId` from the response if needed
          String responseSchemeId = data['schemeId']?.toString() ?? '';
          if (responseSchemeId.isEmpty) {
            print("Error: schemeId is empty in response.");
          //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Scheme ID is missing.")));
            return;
          }

          // Here you should ensure that `schemeId` is sent correctly in future API calls
          // However, you're dealing with a POST request so you may want to validate or use this response later.

          // ✅ Create Activescheme Object with new schemeId if you need to use it
          Activescheme activescheme = Activescheme.customparams(
            schemeID: responseSchemeId,
            amountRs: data['amount'],
            month: data['month'],
            year: data['year'], payId: '',rejectId: '',
            balanceAmount: '',
            installmentAmount: ''
           
          );

          // Debugging the process and message
          print("Process: ${verificationResponse.process}");
          print("Message: ${verificationResponse.message}");
          print("Process Status: ${verificationResponse.process_status}");

          // Only show popup if process_status == "2"
          if (verificationResponse.process_status == "2") {
           _isPolling = false; // ✅ polling stop
            print("Process Status is 2: Showing popup immediately");
            print("Process Status is 2: Showing popup for status 2");

           if (!_popupShown && mounted) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showCompletePopup(verificationResponse);
    _popupShown = true;
  });
}

          } else {
            print("Process Status is not 2, no popup shown.");
          }

        } catch (e) {
          print("Error parsing JSON: $e");
        }
      } else {
        print("Empty response body.");
      }
    } else {
      print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
}
    
 




void showCompletePopup(VerificationResponse response) {
  if (_popupShown) return; // Ensure only one popup at a time

  _popupShown = true; // Set flag immediately to avoid duplicates

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (BuildContext context) {
      return WillPopScope( // Prevent back button dismissal
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), 
          title: Row(
            children: [
              Image.asset('assets/images/csc2.png', height: 40, width: 40),
              const SizedBox(width: 10),

              Text(
                Provider.of<LocalizationProvider>(context, listen: false)
                    .translate("Payment Status"),
                style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          content: Text(
            "${Provider.of<LocalizationProvider>(context, listen: false).translate("Congratulations!\n\nYour payment verification has been successfully completed. Your scheme registration is now confirmed.\n\n\nThank you!")} ${Provider.of<LocalizationProvider>(context, listen: false).translate("Scheme No")}: ${response.regId}",
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black87),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // View Details Button
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentCard()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    child: Text(
                      Provider.of<LocalizationProvider>(context, listen: false).translate("View Details"),
                      style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                // OK Button
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop(); // Close the popup
                    await closePopupAPI(); // Call API if needed
                    Future.delayed(const Duration(milliseconds: 200), () {
                      _popupShown = false; // Ensure popup flag resets after close
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    Provider.of<LocalizationProvider>(context, listen: false).translate("OK"),
                    style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  ).then((_) {
    // Ensure popup flag resets if closed unexpectedly
    _popupShown = false;
  });
}

Future<void> closePopupAPI() async {
  final url = Uri.parse("$baseUrl/close_pop.php"); //"https://vmrdemos.com/csc_scheme/close_pop.php"
    SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');
  try {
  //  final response = await http.get(url);
   final response = await http.post(
      url,
      body: {'mobile_no': mobileNumber},  // Send the mobile number in the body
    );
    
    if (response.statusCode == 200) {
      print("Popup closed successfully");
    } else {
      print("Failed to close popup: ${response.statusCode}");
    }
  } catch (e) {
    print("Error closing popup: $e");
  }
}


  

  @override
  void initState() {
    super.initState();
    loadUserDetails(); 
    _loadButtonState();
    fetchRates();
    _fetchVerificationResponse();
    
  _startPolling();
  
  
    
    //closePopupAPI();
    
      
    
  }


   String goldRate = "Loading...";
  String silverRate = "Loading...";
  bool isLoading = true;

  

  Future<void> fetchRates() async { 
    var url = "$baseUrl/get_rate.php";    //"https://vmrdemos.com/csc_scheme/get_rate.php"

     

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          goldRate = "₹ ${data['gold_rate']}";
          silverRate = "₹ ${data['silver_rate']}";
          isLoading = false;
        });
      } else {
        setState(() {
          goldRate = "Loading";
          silverRate = "Loading";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        goldRate = "Loading";
        silverRate = "Loading";
        isLoading = false;
      });
    }
  }

  


 Future<void> navigateToJoinScheme(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFormCompleted = prefs.getBool('isFormCompleted') ?? false;

    if (isFormCompleted) {
      // Navigate to UpdateDetailsScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scanner(activescheme: Activescheme(),rejectId: '',),
        ),
      );
    } else {
      // Navigate to Jionscheme2 screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Jionscheme2(),
        ),
      );
    }
  }


  

  
  Future<void> loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      firstName = prefs.getString('firstName') ?? 'Guest'; 
      lastName = prefs.getString('lastName') ?? ''; 
      
      
    });
  }



  

    
  @override
  Widget build(BuildContext context) {

    
 final localization = Provider.of<LocalizationProvider>(context);

 
    
      final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    const double padding = 2.0;


    return WillPopScope(
       onWillPop: () async {
        if (_backButtonPressedOnce) {
          // రెండవ click, app close చేయి
          SystemNavigator.pop();
          return true;
        } else {
          // మొదటి click, message చూపించు
          _backButtonPressedOnce = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Press back again to exit')),
          );

          // Flag 2 సెకన్ల తర్వాత reset చేయి
          Future.delayed(Duration(seconds: 2), () {
            _backButtonPressedOnce = false;
          });

          return false; // app close కాకుండా వుండు
        }
      },
      child: SafeArea(
        child: Scaffold(
          drawer: const NavigationDrawerScreen(),
          backgroundColor: const Color(0xFFFFF7E6),
          appBar: AppBar(
        
            iconTheme: const IconThemeData(color: Colors.white),
        
            toolbarHeight: 90,
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
            
            title: 
              
                Column(
                  children: [
                    
        
                     Image.asset('assets/images/csc2.png',height: 45,color: Colors.white,),
                   Text(
          localization.translate("JEWELLERS"),
          style: GoogleFonts.lato(
        fontSize: MediaQuery.of(context).size.width * 0.035, // Dynamic font size
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        color: Colors.white,
          ),
        ),
        
                
                  
                
                   
                  ],
                ),
              
            
           actions: [
         GestureDetector(
          onTap: () {
            final localization = Provider.of<LocalizationProvider>(context, listen: false);
            _showLanguagePopup(context, localization);
          },
          child: Container(
            height: MediaQuery.of(context).size.width * 0.08,  // Dynamic height based on screen width
            width: MediaQuery.of(context).size.width * 0.08,   // Dynamic width based on screen width
            decoration: BoxDecoration(
        color: Colors.black, 
        borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
        child: Text(
          Provider.of<LocalizationProvider>(context).languageCode,  // Show selected language code
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.05,  // Dynamic font size based on screen width
          ),
        ),
            ),
          ),
        ),
        
        
          SizedBox(width: MediaQuery.of(context).size.width * 0.05), // Dynamic spacing
        
         IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
        
          SizedBox(width: MediaQuery.of(context).size.width * 0.03), // Dynamic spacing
        ],
        
           
          ),
          body: 
          
         Column(
            children: [
              
                 Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.01),
            child: SizedBox(
            
              width: double.infinity,
              
              child: CarouselSlider.builder(
                itemCount: images.length,
                options: CarouselOptions(
                  height: screenHeight * 0.16,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: false,
                  autoPlayAnimationDuration: const Duration(milliseconds: 700),
                  onPageChanged: (index, reason) {
                    setState(() => activeIndex = index);
                  },
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                itemBuilder: (context, index, realIndex) {
                  final image = images[index];
                  return Container(
                    
                    width: double.infinity,
                    decoration: const BoxDecoration(
                   
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                         // borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            image, 
                            fit: BoxFit.cover,
                       width: double.infinity,
                       height: screenHeight * 0.6, 
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 90),
                        
                          child: Center(
                          child: buildIndicator()
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
                 
                
              
        
        
             // SizedBox(height: 20,),
        
              
        
              Text(
                //"Today's Gold Rate",
               localization.translate("Today's Gold Rate"),
                style:GoogleFonts.lato(
                  color: const Color.fromRGBO(2, 5, 62, 1),fontWeight: FontWeight.bold,fontSize: 14
                  
                )
                // TextStyle(color: Color.fromRGBO(43, 49, 101, 1),fontWeight: FontWeight.bold,fontSize: 17),
                 ),
        
            //  SizedBox(height: 10,),
        
             
        
              
           Container(
          padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
        vertical: MediaQuery.of(context).size.height * 0.005, // Dynamic padding
          ),
          decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Gold Rate Card
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.06,  // 6% of screen width
                    vertical: MediaQuery.of(context).size.height * 0.008,  // Dynamic padding
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(2, 5, 62, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
          "${localization.translate("Gold")} $goldRate",
          style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: MediaQuery.of(context).size.width * 0.04, // Dynamic font size
        fontWeight: FontWeight.bold,
          ),
        ),
        
                ),
                Positioned(
                  left: -MediaQuery.of(context).size.width * 0.03, // Dynamic positioning
                  top: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.08, // Dynamic width
                    height: MediaQuery.of(context).size.width * 0.08, // Dynamic height
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/go.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.04), // Dynamic spacing
            // Silver Rate Card
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.07, // 7% of screen width
                    vertical: MediaQuery.of(context).size.height * 0.008, // Dynamic padding
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(2, 5, 62, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                     "${localization.translate("Silver")} $silverRate",
                   // "Silver $silverRate",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04, // Dynamic font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  left: -MediaQuery.of(context).size.width * 0.03, // Dynamic positioning
                  top: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.08, // Dynamic width
                    height: MediaQuery.of(context).size.width * 0.08, // Dynamic height
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/silver.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
          ),
        ),
        
        
         // SizedBox(height: 10),
        
          
        
       Center(
  child: (verificationResponse?.process == "pending" ||
          verificationResponse?.process == "incomplete")
      ? Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          decoration: BoxDecoration(
            color: verificationResponse?.process == "pending"
                ? Colors.orange.shade50
                : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: verificationResponse?.process == "pending"
                  ? Colors.orange
                  : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text Message
              Expanded(
                child: Text(
                  verificationResponse?.process == "pending"
                      ? "Transaction is pending. Please complete it to proceed."
                      : localization.translate(
                          "Your join scheme registration is still pending. Kindly complete your registration process."),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.030,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              //const SizedBox(width: 10),

              // Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8), // Small button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Scanner(activescheme: Activescheme(), rejectId: ''),
                    ),
                  );
                },
                child: Text(
                  localization.translate('continue'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                  ),
                ),
              ),
            ],
          ),
        )
      : const SizedBox.shrink(),
),

    
        

       /* 
       Center(
          child: verificationResponse == null || verificationResponse?.process == "complete"
          ? const SizedBox.shrink() // No message displayed
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Message (Marquee Text)
                Expanded(
                  flex: 1,
                  child: verificationResponse?.process == "pending"
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06, // Dynamic height
                          child: Marquee(
                            text: "Transaction Pending",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.045, // Dynamic font
                              fontWeight: FontWeight.bold,
                            ),
                            scrollAxis: Axis.horizontal,
                            blankSpace: 200,
                            velocity: 50,
                            pauseAfterRound: const Duration(seconds: 2),
                            startPadding: 10,
                          ),
                        )
                      : verificationResponse?.process == "incomplete"
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.06, // Dynamic height
                              child: Marquee(
                                text: localization.translate("Your join scheme registration is still pending. Kindly complete your registration process."),
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.035, // Dynamic font
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                scrollAxis: Axis.horizontal,
                                blankSpace: 200,
                                velocity: 50,
                                pauseAfterRound: const Duration(seconds: 2),
                                startPadding: 10,
                              ),
                            )
                          : const SizedBox.shrink(), // Fallback for other conditions
                ),
        
        
        
                
                
                // Button (Dynamic Display)
                if (verificationResponse?.process == "pending" ||
                    verificationResponse?.process == "incomplete")
        
        
                    
                  Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.05, // Dynamic padding
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04, // Dynamic height
                      width: MediaQuery.of(context).size.width * 0.3, // Dynamic width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => Scanner(activescheme: Activescheme(),rejectId: '',),
                            ),
                          );
                        },
                        child: Text(
                         localization.translate('continue'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.03, // Dynamic font size
                          ),
                        ),
                      ),
                    ),
                  ),
        
                  
              ],
            ),
        ),

     */
        
            Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.07, // Dynamic horizontal padding
              ),
              child: Text(
                localization.translate("Welcome Back"),
                style: GoogleFonts.lato(
                  color: const Color.fromRGBO(43, 49, 101, 1),
                  fontSize: MediaQuery.of(context).size.width * 0.045, // Dynamic font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        Padding(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.03, // Dynamic padding
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProfileScreen(schemeID: '',)),
              );
            },
            child: Image.asset(
              'assets/images/person1.png',
              color: const Color.fromRGBO(2, 5, 62, 1),
              height: MediaQuery.of(context).size.height * 0.06, // Dynamic height
            ),
          ),
        ),
          ],
        ),
        
        
               Container(
          padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.07, // Dynamic left padding
          ),
          alignment: Alignment.bottomLeft, 
          child: Text(
        '$firstName $lastName',
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.04, // Dynamic font size
          color: Colors.blue,fontWeight: FontWeight.bold
        ),
        textAlign: TextAlign.start, // Left align for natural reading flow
          ),
        ),
        
        
        
             // SizedBox(height: 20,),
              
          Expanded(
          child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = getCrossAxisCount(constraints.maxWidth);
          double spacing = getSpacing(constraints.maxWidth);
        
          return GridView.count(
            padding: const EdgeInsets.all(13),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            children: [
              _buildGridButton(
                'assets/images/schme.png',
                localization.translate("Join Scheme"),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavingsAccountScreen(),
                    ),
                  );
                },
           context),
              _buildGridButton(
                'assets/images/myschme.png',
                localization.translate("My Scheme"),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoadingScreen(),
                    ),
                  );
        
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentCard(),
                      ),
                    );
                  });
                },
             context ),
              _buildGridButton(
                'assets/images/pay.png',
                localization.translate("Quick Pay"),
                () {
                  showGoldBottomSheet(context);
                },
            context  ),
              _buildGridButton(
                'assets/images/customre.png',
                localization.translate("Contact Us"),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoadingScreen(),
                    ),
                  );
        
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerCare(),
                      ),
                    );
                  });
                },
             context ),
              _buildGridButton(
                'assets/images/transation.png',
                localization.translate("Transactions"),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoadingScreen(),
                    ),
                  );
        
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Transaction(),
                      ),
                    );
                  });
                },
             context ),
              _buildGridButton(
                'assets/images/browser.png',
                localization.translate('Brochure'),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoadingScreen(),
                    ),
                  );
        
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrochureScreen(),
                      ),
                    );
                  });
                },
             context ),
            ],
          );
        },
          ),
        ),



       /* 
        
      Center(
  child: (verificationResponse?.process == "pending" ||
          verificationResponse?.process == "incomplete")
      ? Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Message
              Expanded(
                child: Text(
                  verificationResponse?.process == "pending"
                      ? "Transaction Pending"
                      : localization.translate(
                          "Your join scheme registration is still pending. Kindly complete your registration process."),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.030,
                    fontWeight: FontWeight.bold,
                    color: verificationResponse?.process == "pending"
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Button
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
                width: MediaQuery.of(context).size.width * 0.3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scanner(
                          activescheme: Activescheme(),
                          rejectId: '',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    localization.translate('continue'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          MediaQuery.of(context).size.width * 0.03,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      : const SizedBox.shrink(), // If not pending or incomplete, show nothing (no box)
),

*/
       
             // const SizedBox(height: 10),
        
        
            ],
          ),
        
         bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
        final isSelected = _selectedIndex == index;
        
        String imagePath;
        String label;
        
        switch (index) {
          case 0:
            imagePath = 'assets/images/home.png';
            label = localization.translate('Home');
            break;
          case 1:
            imagePath = 'assets/images/inof.png';
            label = localization.translate('About');
            break;
          case 2:
            imagePath = 'assets/images/shopping.png';
            label = localization.translate('Collections');
            break;
          case 3:
            imagePath = 'assets/images/faq.png';
            label = localization.translate('More');
            break;
          default:
            imagePath = 'assets/images/faq.png';
            label = localization.translate('Other');
        }
        
        return Expanded(
          child: InkWell(
            onTap: () => _navigateTo(index), // Or your onTap logic
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top curved indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromARGB(255, 3, 1, 22)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
        
                // 🔴 Removed badge here
                Image.asset(
                  imagePath,
                  height: 24,
                  color: isSelected
                      ? const Color.fromARGB(255, 3, 1, 22)
                      : Colors.black,
                ),
        
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? const Color.fromARGB(255, 3, 1, 22)
                        : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
            }),
          ),
        ),
        
            
        
        ),
      ),
    );
  }

  int getCrossAxisCount(double width) {
  if (width < 200) {
    return 2; // Extremely small screens
  } else if (width < 400) {
    return 3; // Small mobiles also get 3 columns
  } else if (width < 900) {
    return 3; // Medium screens
  } else {
    return 4; // Large screens
  }
}


double getSpacing(double width) {
  if (width < 600) {
    return 10; // Small Screens - Less spacing
  } else if (width < 900) {
    return 20; // Medium Screens - Moderate spacing
  } else {
    return 30; // Large Screens - More spacing
  }
}


Widget _buildGridButton(String assetPath, String label, VoidCallback onTap, BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Dynamic sizes based on screen width
  double containerSize = screenWidth * 0.25; // Adjust width based on screen
  double imageSize = screenWidth * 0.1; // Image size proportional
  double fontSize = screenWidth * 0.03; // Font size scales

  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: containerSize, // Dynamic height
      width: containerSize, // Dynamic width
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 224, 222),
        borderRadius: BorderRadius.circular(screenWidth * 0.03), // Dynamic border radius
      ),
      padding: EdgeInsets.all(screenWidth * 0.03), // Dynamic padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            width: imageSize,
            height: imageSize,
          ),
          SizedBox(height: screenHeight * 0.01), // Dynamic spacing
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(33, 36, 86, 1),
            ),
          ),
        ],
      ),
    ),
  );
}


   Widget buildImage(String image, int index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      );


       Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: images.length,
         axisDirection: Axis.horizontal,
        effect: const SlideEffect(
          
          dotWidth: 10,
          dotHeight: 10,
          activeDotColor: Colors.blue,
          dotColor: Colors.black,
        ),
      );


   Widget _buildBottomNavItem(String assetPath, String labelKey, int index, Widget screen) {
  final isSelected = selectedIndex == index;
  final color = isSelected ? const Color.fromRGBO(4, 18, 142, 1) : Colors.grey;
  final localization = Provider.of<LocalizationProvider>(context);

  return InkWell(
    onTap: () {
      setState(() {
        selectedIndex = index;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ).then((_) {
        // Back చేసినపుడు Home (index 0) select అవ్వాలి
        setState(() {
          selectedIndex = 0;
        });
      });
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          color: color,
          width: 30,
          height: 30,
        ),
        const SizedBox(height: 4),
        Text(
          localization.translate(labelKey),
          style: GoogleFonts.montserrat(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}






bool isBottomSheetOpen = false; // Global variable to track bottom sheet state

void showGoldBottomSheet(BuildContext context) async {
  if (isBottomSheetOpen) return;
  isBottomSheetOpen = true;

  final localization = Provider.of<LocalizationProvider>(context, listen: false);
  final currentContext = context;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    const ErrorScreen();
    isBottomSheetOpen = false;
    return;
  }

  var url = '$baseUrl/pay_due.php';  //'https://vmrdemos.com/csc_scheme/pay_due.php'
  final response = await http.post(
    Uri.parse(url),
    body: {'mobile_no': mobileNumber},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final schemeDetails = (data['scheme_details'] ?? []) as List; // Avoiding null error

    print("Response Status Code: ${response.statusCode}");
    print("Full API Response: ${response.body}");

    if (schemeDetails.isEmpty) {
      // Show popup if no data is available
    //  _showErrorDialog(context, localization.translate('You currently have no outstanding dues.'));
    showWarningPopup(context);
      isBottomSheetOpen = false;
    } else {
      // Show bottom sheet if data is available
      showModalBottomSheet(
        context: currentContext,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              isBottomSheetOpen = false;
              return true;
            },
            child: SafeArea(
              child: FractionallySizedBox(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gold Info Card
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(43, 49, 101, 1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/gif.gif',
                                  height: 60,
                                  width: 60,
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildInfoRow(Icons.water_drop, localization.translate("24K Pure Gold")),
                                    buildInfoRow(Icons.security, localization.translate("100% Safe Investment")),
                                    buildInfoRow(Icons.sell, localization.translate("100% Wastage Free")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Scheme Details
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: schemeDetails.asMap().entries.map<Widget>((entry) {
                              int index = entry.key;
                              var scheme = entry.value;
                              return Column(
                                children: [
                                  AssetTile(
                                    gifPath: 'assets/images/gif.gif',
                                    title: "${localization.translate("Scheme")} ${index + 1}",
                                    amount: "₹${scheme['paid_amount']}",
                                    percentage: scheme['ms_no'],
                                    balanceDues: "${localization.translate("Balance Dues")}: ${scheme['balance_due']}",
                                    color: Colors.green,
                                    value: 0.05,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => InstallmentScreen(schemeId: scheme['scheme_id']),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "${localization.translate("Pay")} ₹${scheme['amount']}",
                                          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ).whenComplete(() {
        isBottomSheetOpen = false;
      });
    }
  } else {
    _showErrorDialog(context, localization.translate("Failed to fetch scheme details. Please try again later."));
    isBottomSheetOpen = false;
  }
}

// Error Dialog
void _showErrorDialog(BuildContext context, String message) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
    
  final localization = Provider.of<LocalizationProvider>(context, listen: false);  

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => Dialog(
      shape: const RoundedRectangleBorder(
      //  borderRadius: BorderRadius.circular(16), // Rounded corners for dialog
      ),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dialog content
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.03, // Dynamic vertical padding
              horizontal: screenWidth * 0.05, // Dynamic horizontal padding
            ),
            child: Column(
              children: [
                // Info Icon with Blue Background
                CircleAvatar(
                  radius: screenWidth * 0.06, // Dynamic icon size
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.info,
                    color: Colors.blue,
                    size: screenWidth * 0.10, // Dynamic icon size
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Title Text
                
             //   SizedBox(height: screenHeight * 0.01),

                // Message Text
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Dynamic text size
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),

          // Full-Width Button at the Bottom
          Container(
            width: double.infinity, // Full width button
            decoration: const BoxDecoration(
              color: Color.fromRGBO(2, 5, 62, 1), // Button background color
              borderRadius: BorderRadius.only(
               // bottomLeft: Radius.circular(16),
              //  bottomRight: Radius.circular(16),
              ), // Rounded corners at the bottom
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close popup
              },
              child: Text(
           localization.translate("OK"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045, // Dynamic font size
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


// ✅ Helper function for displaying Gold Info Row
Widget buildInfoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: Colors.yellow, size: 15),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(color: Colors.white)),
    ],
  );
}




void showWarningPopup(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
   final localization = Provider.of<LocalizationProvider>(context,listen: false);
  showDialog(
    context: context,
    barrierDismissible: false, // Popup బయట tap చేసినా close అవకూడదు
    builder: (BuildContext context) {
      return Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, 
        ),
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Popup Content
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.02, 
              ),
              child: Column(
                children: [
                  // ✅ Info Icon with Blue Background
                  CircleAvatar(
                    radius: screenWidth * 0.08,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.info, color: Colors.blue, size: screenWidth * 0.12),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // ✅ Message Text
                  Text(
                   localization.translate("No active scheme found. Please register today."),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),

            // ✅ Full Width Button at Bottom
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(2, 5, 62, 1),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Popup Close
                  isBottomSheetOpen = false; // ✅ Reset Bottom Sheet Flag
                },
                child: Text(
                 localization.translate("OK"),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    },
  ).then((_) {
    isBottomSheetOpen = false; // ✅ Popup dismiss అయినా reset అవుతుంది
  });
}





void showCustomDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: Text(message), // The message you want to display
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}



 void _showLanguagePopup(BuildContext context, LocalizationProvider localization) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _languageOption(context, localization, 'English', 'en', true),
              _languageOption(context, localization, 'తెలుగు', 'te', true),
              _languageOption(context, localization, 'हिंदी', 'hi', false),
              _languageOption(context, localization, 'தமிழ்', 'ta', false),
            ],
          ),
        ),
      );
    },
  );
}

Widget _languageOption(BuildContext context, LocalizationProvider localization, String language, String languageCode, bool isAvailable) {
  return InkWell(
    onTap: isAvailable
        ? () {
            localization.changeLanguage(languageCode);
            Navigator.of(context).pop();
          }
        : null,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFF5F5F5) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? Colors.green : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language,
            style: TextStyle(
              fontSize: 16,
              color: isAvailable ? Colors.black : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            isAvailable ? 'Available' : 'Not Available',
            style: TextStyle(
              fontSize: 14,
              color: isAvailable ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}








  
}



