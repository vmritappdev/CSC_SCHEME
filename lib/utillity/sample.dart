import 'dart:async';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';




class SampleScreen extends StatefulWidget {
  @override
  _SampleScreenState createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result == ConnectivityResult.none) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ErrorScreen()),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample Screen'),
      ),
      body: Center(
        child: Text(
          'This is the main screen.\nTurn off internet to test.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

