 import 'dart:async';
import 'dart:convert';




import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/insatllment.dart';
import 'package:csc/chaingedscreens.dart/scner.dart';
import 'package:csc/chaingedscreens.dart/installmentviewdetails.dart';

import 'package:csc/dashboardscreens/notification.dart';


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
import 'package:pull_to_refresh/pull_to_refresh.dart';
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


final RefreshController _refreshController = RefreshController();

void _onRefresh() async {
  try {
    loadUserDetails(); 
    _loadButtonState();
    fetchRates();
    _fetchNotificationCount();
    _fetchVerificationResponse();
   
  } catch (e) {
    print("Error during refresh: $e");
  } finally {
    _refreshController.refreshCompleted();
  }
}

  int _notificationCount = 0;  // initially 100 messages

int _previousNotificationCount = 0; // store last known count
  


 

   
 VerificationResponse? verificationResponse;

  int _selectedIndex = 0;


  
  void _navigateTo(int index) {
  // Select the tab icon
  setState(() => _selectedIndex = index);

  
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




Future<void> _fetchNotificationCount() async {
  final url = Uri.parse("$baseUrl/notifications.php");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  if (mobileNumber == null || mobileNumber.length != 10) {
    print("❌ Invalid or missing mobile number in SharedPreferences");
    return;
  }

  try {
    final response = await http
        .post(
          url,
          body: {
            "mobile_no": mobileNumber,
          },
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("✅ Notification response: $jsonData");

      if (jsonData['response']?.toString() == 'success') {
        final count = int.tryParse(jsonData['count']?.toString() ?? '0') ?? 0;

        // ✅ Play sound if count increased
        if (count > _previousNotificationCount) {
          final player = AudioPlayer();
          await player.play(AssetSource('sounds/notifications.wav'));
        }

        setState(() {
          _notificationCount = count;
          _previousNotificationCount = count;
        });
      } else {
        print("⚠️ Server response not success: ${jsonData['response']}");
      }
    } else {
      print("❌ Server returned error: ${response.statusCode}");
    }
  } on TimeoutException catch (_) {
    print("⏱️ Request timed out after 10 seconds");
  } catch (e, stackTrace) {
    print("❌ Error fetching notification count: $e");
    print("📛 Stack trace:\n$stackTrace");
  }
}





   int selectedIndex = 0;
    bool isButtonClicked = false;
  bool isProcessComplete = false;

    final List<String> images = [
   'assets/images/e7.png',   
    'assets/images/e4.png',
    'assets/images/e9.png',
    'assets/images/Banner.png',
    'assets/images/e2.png',
    'assets/images/ssss.png',
  ];

   int activeIndex = 0;
   String errorMessage = '';
   


     String firstName = '';  // Default value for first name
     String lastName = ''; 
     String mobileNumber = '';

  Future<void> _loadButtonState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
  isButtonClicked = prefs.getBool('isButtonClicked') ?? false;
    });
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

@override
void dispose() {
  _isPolling = false; // Stop polling when the widget is disposed
  super.dispose();
// ఫ్లాగ్ రీసెట్ చేయండి
}



Future<void> _fetchVerificationResponse() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');
 // String schemeId = widget.activescheme.schemeID;
 String? schemeId = widget.activescheme.schemeID;
if (schemeId == null || schemeId.isEmpty) {
  print("❌ schemeId is null or empty");
  return;
}




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
  if (_popupShown || !mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentCard()));
                  },
                  child: Text("View Details", style: TextStyle(fontSize: 12,color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await Future.delayed(Duration(milliseconds: 100));
                    _popupShown = false;
                    closePopupAPI();
                  },
                  child: Text("OK", style: TextStyle(fontSize: 14,color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  ).then((_) {
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
    _fetchNotificationCount();
    
  _startPolling();
  
    
    //closePopupAPI();
    
      
    
  }


   String goldRate = "Loading...";
  String silverRate = "Loading...";
  bool isLoading = true;

  

  Future<void> fetchRates() async { 
    var url = "$baseUrl/get_rate.php";    

     

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

    
 final localization = Provider.of<LocalizationProvider>(context,listen: false);

 
    
    final double screenHeight = MediaQuery.of(context).size.height;

    


   return WillPopScope(
  onWillPop: () async {
    bool shouldExit = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.translate('CSC App'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                localization.translate('Are you sure do you want to exit?'),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      localization.translate('CANCEL'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      localization.translate('EXIT'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return shouldExit; 
    // true అంటే app close అవుతుంది 
    // false అంటే popup మాత్రమే close అవుతుంది, app run అవుతుంది
  },

      
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
    decoration: BoxDecoration(
      border: Border.all(
        color: const Color.fromARGB(255, 148, 147, 147),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.language,
          color: Colors.white,
          size: MediaQuery.of(context).size.width * 0.05,
        ),
        SizedBox(width: 3),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Consumer<LocalizationProvider>(
            builder: (context, localization, _) {
              // languageCode తీసుకుని uppercase లో చూపించు
              String displayCode = localization.languageCode.toUpperCase();
              return Text(
                displayCode,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
),

        SizedBox(width: MediaQuery.of(context).size.width * 0.05), // Dynamic spacing
        
 GestureDetector(
  onTap: () async {
    final updatedUnreadCount = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );

    setState(() {
      _notificationCount = updatedUnreadCount ?? 0;
    });
  },
  child: Stack(
  clipBehavior: Clip.none, // 👈 overflow badge ni chupinchadaniki
  children: [
    Icon(
      Icons.notifications,
      color: Colors.white,
      size: MediaQuery.of(context).size.width * 0.07,
    ),
    if (_notificationCount > 0)
      Positioned(
        top: -9, // 👈 bell icon pai adjust cheyyadam
        right: -4, // 👈 slight outside ki shift cheyyadam
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          constraints: const BoxConstraints(
            minWidth: 15,
            minHeight: 15,
          ),
          child: Center(
            child: Text(
              _notificationCount > 99 ? '99+' : '$_notificationCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
  ],
)

),


          SizedBox(width: MediaQuery.of(context).size.width * 0.03), // Dynamic spacing
        ],
        
           
          ),
          body: 
          
         SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
      
            header: WaterDropHeader(
            complete: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text("Refresh Completed", style: TextStyle(color: Colors.green)),
              ],
            ),
            waterDropColor: const Color.fromARGB(255, 4, 2, 29),
          ),
           child: SafeArea(
             child: Column(
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
                    MaterialPageRoute(builder: (context) => ProfileScreen(schemeID: '')),
                  );
                },
                child: Image.asset(
                  'assets/images/person1.png',
                  color: const Color.fromARGB(255, 3, 4, 19),
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
                color: const Color.fromARGB(255, 4, 60, 226),fontWeight: FontWeight.bold
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
                    ()  async{
             
                       bool hasInternet = await checkInternet();
                 if (!hasInternet) {
                   if (context.mounted) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const ErrorScreen()),
                     );
                   }
                   return;
                 }
             
             
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
                    () async {
             
                       bool hasInternet = await checkInternet();
                 if (!hasInternet) {
                   if (context.mounted) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const ErrorScreen()),
                     );
                   }
                   return;
                 }
             
             
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
                    () async {
             
                       bool hasInternet = await checkInternet();
                 if (!hasInternet) {
                   if (context.mounted) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const ErrorScreen()),
                     );
                   }
                   return;
                 }
                      showGoldBottomSheet(context);
                    },
                context  ),
                  _buildGridButton(
                    'assets/images/customre.png',
                    localization.translate("Contact Us"),
                    ()  async{
             
                       bool hasInternet = await checkInternet();
                 if (!hasInternet) {
                   if (context.mounted) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const ErrorScreen()),
                     );
                   }
                   return;
                 }
             
             
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
                    () async {
             
                       bool hasInternet = await checkInternet();
                 if (!hasInternet) {
                   if (context.mounted) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const ErrorScreen()),
                     );
                   }
                   return;
                 }
             
             
             
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
                    ()  async {
             
                       bool hasInternet = await checkInternet();
                 if (!hasInternet) {
                   if (context.mounted) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const ErrorScreen()),
                     );
                   }
                   return;
                 }
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
             
             
             
             
                     
                     
                ],
              ),
           ),
         ),
        
         bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: SafeArea(
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
              imagePath = 'assets/images/info.png';
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
  if (context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ErrorScreen()),
    );
  }
  return null;
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
                                  'assets/images/go.png',
                                  height: 50,
                                  width: 50,
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
  gifPath: 'assets/images/go.png',
  title: "${localization.translate("Scheme")} ${index + 1}",
  amount: "₹${scheme['paid_amount']}",
  percentage: scheme['ms_no'],
  balanceDues: "${localization.translate("Balance Dues")}: ${scheme['balance_due']}",

  // Progress value based on fixed 11 total dues
  value: (() {
    const int totalDues = 11;
    int balance = int.tryParse(scheme['balance_due'].toString()) ?? 0;
    int paid = totalDues - balance;
    return (paid / totalDues).clamp(0.0, 1.0);
  })(),

  // Always green color
  color: Colors.green,
)
,
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
        child: Stack(
          children: [
            Padding(
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
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(), // Popup close action
                child: const Icon(Icons.clear, size: 24, color: Colors.black),
              ),
            ),
          ],
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



