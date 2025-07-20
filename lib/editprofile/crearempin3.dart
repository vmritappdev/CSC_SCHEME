
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';


 void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home:const CreateMpin2Screen(),
    ),
  );
}


class CreateMpin2Screen extends StatefulWidget {
  const CreateMpin2Screen({super.key});

  @override
  State<CreateMpin2Screen> createState() => _CreateMpin2ScreenState();
}

class _CreateMpin2ScreenState extends State<CreateMpin2Screen> {


 



  static const defaultPinTheme = PinTheme(
    width: 80,
    height: 70,
    textStyle: TextStyle(
      color: Colors.black,
      fontSize: 22,
    ),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey)),
    ),
  );

  String mpin = '';
  String confirmMpin = '';
  String errorMessage = '';
  bool showImageOverlay = false;

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context); 
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: screenHeight,
                  maxWidth: screenWidth,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(2, 5, 62, 1),
                      Color.fromRGBO(2, 5, 62, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.13),
                    Image.asset('assets/images/csc2.png', height: 90, fit: BoxFit.fill, color: Colors.white),
                    Text(
                     // localization.translate('app_name'),
                     'JEWELLERS',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.15),
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight,
                          maxWidth: screenWidth,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
      
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Create_Mpin',
                                 // localization.translate('create_mpin'),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width * 0.04,
      ),
                                ),
                              ),
                              buildPinput(
                                onChanged: (value) {
                                  setState(() {
                                    mpin = value;
                                    errorMessage = '';
                                  });
                                },
                              ),
      
                           SizedBox(height: MediaQuery.of(context).size.height * 0.04),
      
      
      
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Confirm_Mpin',
                                 // localization.translate('confirm_mpin'),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              buildPinput(
                                onChanged: (value) {
                                  setState(() {
                                    confirmMpin = value;
                                    errorMessage = '';
                                  });
                                },
                              ),
                              if (errorMessage.isNotEmpty)
                                Padding(
                                 padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.012),
      
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              SizedBox(height: screenHeight * 0.09),
                              buildSubmitButton(localization),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPinput({required ValueChanged<String> onChanged}) {
    return Padding(
    padding: EdgeInsets.symmetric(
  vertical: MediaQuery.of(context).size.height * 0.018,
),

      child: Pinput(
        length: 4,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: const Border(bottom: BorderSide(color: Color.fromRGBO(2, 5, 62, 1), width: 2)),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildSubmitButton(LocalizationProvider localization) {
    return SizedBox(
     height: MediaQuery.of(context).size.height * 0.055,

      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          if (mpin.isEmpty || confirmMpin.isEmpty) {
            setState(() {
               errorMessage = ('Empty Mpin');
             // errorMessage = localization.translate('error_empty_mpin');
            });
          } else if (mpin != confirmMpin) {
            setState(() {
               errorMessage = ('Mpin Mismatch');
             // errorMessage = localization.translate('error_mpin_mismatch');
            });
          } else {
            setState(() {
              _showCustomBottomSheet(context);
            });
          }
        },
        child: Text(
          'Submit',
          //localization.translate('submit'),
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04,
 fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _showCustomBottomSheet(BuildContext context) {
    Provider.of<LocalizationProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(activescheme: Activescheme(),),
            ),
          );
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
             padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),

              decoration: const BoxDecoration(
                color: Color.fromRGBO(2, 5, 62, 1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Mpin  Successfully',
                        style:  TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                         fontSize: MediaQuery.of(context).size.width * 0.035,

                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04, // 4% of screen height
  width: MediaQuery.of(context).size.width * 0.08,  // 8% of screen width
                    child: Lottie.asset(
                      'assets/images/suc.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
