// active_scheme_service.dart

import 'dart:convert';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/model/SchemeResponseNew.dart';
import 'package:csc/utillity/check%20internet.dart';

import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;


class ActiveSchemeService {


 
 
  Future<SchemeResponseNew?> fetchActiveSchemes(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
    if (context.mounted) {
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ErrorScreen()),
        );
      }
      return null;
    }

    final url = Uri.parse('$baseUrl/active_scheme.php'); // update with your real URL

    

    try {
      final response = await http.post(url, body: {'mobile_no': mobileNumber});
      if (response.statusCode == 200) {

        final data = json.decode(response.body);

 print("✅ Full Active Scheme Response: $data");
 


        if (data['response'] == 'success') {
          print("✅ Full Active Scheme Response: ${data['active_schemes']}");
  print("🔴 Full Closed Scheme Response: ${data['closed_schemes']}");
  print("🟡 Full Suspended Scheme Response: ${data['suspended_schemes']}");
          final activeSchemes = (data['active_schemes'] as List)
          .map((e) => SchemeDetailsNew.fromJson(e))
          .toList();

          final closedSchemes = (data['closed_schemes'] as List)
              .map((e) => SchemeDetailsNew.fromJson(e)) 
              .toList();

          final suspendedSchemes = (data['suspended_schemes'] as List)
          .map((e) => SchemeDetailsNew.fromJson(e))
            .toList();

          return SchemeResponseNew(
            activeSchemes: activeSchemes,
            closedSchemes: closedSchemes,
            suspendedSchemes: suspendedSchemes,
            schemeDetails: [],
          );

          
        }
        print("✅ Full Active Scheme Response: $data");
      }

      
    } catch (e) {
      print("Error fetching schemes: $e");
    }

    return null;
  }



  
}
