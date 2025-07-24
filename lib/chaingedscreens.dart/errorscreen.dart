import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatefulWidget {
  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
 @override
void initState() {
  super.initState();

  _subscription = Connectivity().onConnectivityChanged.listen((results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

    if (result != ConnectivityResult.none) {
      // Just go back to previous screen
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // This will return to the previous screen
      }
    }
  });
}


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final localization = Provider.of<LocalizationProvider>(context);
    return WillPopScope(
      onWillPop: () async {
       SystemNavigator.pop(); // 👉 యాప్ close చేస్తుంది
      return false;
      },
      
      child: Scaffold(
       //  backgroundColor: const Color.fromARGB(255, 239, 236, 236),
         
        body: Center(
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Image.asset(
                            'assets/images/net.jpg',
                            width: 200,
                            height: 200,
                          ),
                ),
                      //  const SizedBox(height: 24),
                        Text(
                          localization.translate('No Internet Connection'),
                          style: GoogleFonts.poppins( fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(2, 5, 67, 1),)
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localization.translate('Please check your internet connection.'),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),


                          const SizedBox(height: 18),


                        SizedBox(
                          height: 33,
                          width: 260,
                          child: ElevatedButton(
                            onPressed: (){}, 
                          child: Text('Try Again',style: GoogleFonts.nunito(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)),
                        )
              
            ],
          ),
        ),
      ),
    );
  }
}