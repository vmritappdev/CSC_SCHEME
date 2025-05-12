import 'dart:convert';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AccountService {
  

  AccountService();

  Future<Map<String, dynamic>> submitForm({
    required GlobalKey<FormState> formKey,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required BuildContext context,
    required String previousPhoneNumber,
  }) async {
    if (!formKey.currentState!.validate()) {
      return {'response': 'error', 'message': 'Invalid form'};
    }

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ErrorScreen()),
      );
      return {'response': 'error', 'message': 'No Internet'};
    }

    if (phoneNumber == previousPhoneNumber) {
      return {'response': 'error', 'message': 'Phone number already used.'};
    }

    const url = "$baseUrl/save_account.php";
    final data = {
      'f_name': firstName,
      'l_name': lastName,
      'mobile_no': phoneNumber,
      'email_id': email,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['response'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstName', firstName);
          await prefs.setString('lastName', lastName);
          await prefs.setString('phoneNumber', phoneNumber);
          await prefs.setString('email', email);
        }
        return responseData;
      } else {
        return {
          'response': 'error',
          'message': 'Failed: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'response': 'error', 'message': 'Exception: $e'};
    }
  }

  Future<bool> checkInternet() async {
    // Add your internet check logic here
    return true;
  }
}
