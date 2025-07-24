import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:flutter/material.dart';

class NetworkHandler {
  static final NetworkHandler _instance = NetworkHandler._internal();
  factory NetworkHandler() => _instance;
  NetworkHandler._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void startMonitoring(BuildContext context) {
    _subscription ??= Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result == ConnectivityResult.none) {
        // Go to Error Screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ErrorScreen()),
        );
      } else {
        // Pop ErrorScreen if internet is back
        if (Navigator.canPop(context)) {
          Navigator.popUntil(context, (route) => route.settings.name != '/error');
        }
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }
}
