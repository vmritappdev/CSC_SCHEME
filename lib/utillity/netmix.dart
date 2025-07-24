import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../chaingedscreens.dart/errorscreen.dart'; // Adjust path if needed

mixin NetworkMixin<T extends StatefulWidget> on State<T> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isErrorScreenShown = false;

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result == ConnectivityResult.none) {
        if (!_isErrorScreenShown) {
          _isErrorScreenShown = true;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  ErrorScreen()),
          );
        }
      } else {
        if (_isErrorScreenShown) {
          Navigator.pop(context);
          _isErrorScreenShown = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
