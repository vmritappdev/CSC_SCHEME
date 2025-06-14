import 'package:csc/localization/localizationpro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    return Scaffold(
    backgroundColor: Colors.white, 
    appBar: AppBar(
    backgroundColor: Colors.white, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/net.jpg', // ✅ Asset image
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24),
               Text(
               localization.translate('Something went wrong!'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
               Text(
              localization.translate('Please try again later.'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 120,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(2, 6, 67, 1), // ✅ Button background RGB(6,67,1)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Retry logic

                    Navigator.pop(context); // ✅ Go back to the previous screen
                  },
                  child:  Text(
                   localization.translate('Retry'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white, // ✅ Text color white
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
