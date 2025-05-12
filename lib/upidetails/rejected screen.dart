
import 'package:csc/chaingedscreens.dart/scner.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/model/activescheme.dart';
import 'package:flutter/material.dart';

class PaymentRejectedScreen extends StatefulWidget {
   final String rejectId;

   PaymentRejectedScreen({required this.rejectId});

  @override
  State<PaymentRejectedScreen> createState() => _PaymentRejectedScreenState();
}

class _PaymentRejectedScreenState extends State<PaymentRejectedScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Payment Rejected",
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.05),
        ),
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rejected Icon
            Icon(
              Icons.cancel_rounded,
              color: Colors.redAccent,
              size: screenWidth * 0.3,
            ),
            SizedBox(height: screenHeight * 0.03),
            // Main Message
            Text(
              "Payment Rejected!",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Subtext for explanation
            Text(
              "Unfortunately, your payment could not be processed. Please check your payment details and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black54),
            ),
            SizedBox(height: screenHeight * 0.05),
            // Retry Button
            ElevatedButton(
              onPressed: () {
               Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => Scanner(activescheme: Activescheme(
                    
                  ),rejectId: widget.rejectId,),
                )
              );
              //  Navigator.pop(context); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, screenHeight * 0.06),
              ),
              child: Text(
                "Retry Payment",
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Go Back to Home
            OutlinedButton(
              onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => HomeScreen(activescheme: Activescheme()),
                )
              );
              //  Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.redAccent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, screenHeight * 0.06),
              ),
              child: Text(
                "Go to Home",
                style: TextStyle(color: Colors.redAccent, fontSize: screenWidth * 0.045),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
