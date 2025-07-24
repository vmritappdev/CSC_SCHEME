import 'package:csc/utillity/bouncing.dart';

import 'package:flutter/material.dart';


class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 50), () {
      print("50 Seconds Timer Completed!"); // 50 sec తర్వాత action
    });
  }

  void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home:const LoadingScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
  child: BouncingDotsLoader(
    color: Color(0xFF002970), // Paytm blue or gold
    size: 12.0,
  ),
)

    );
  }
}



/*
Center(
  child: SpinKitFadingFour(
    color: Color.fromRGBO(4, 15, 228, 1),
    size: 40.0,
  ),
),
*/