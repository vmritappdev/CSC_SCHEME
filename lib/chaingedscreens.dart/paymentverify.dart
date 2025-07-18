import 'dart:convert';

import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentVerifyScreen extends StatefulWidget {
  const PaymentVerifyScreen({super.key});

  @override
  State<PaymentVerifyScreen> createState() => _PaymentVerifyScreenState();
}

class _PaymentVerifyScreenState extends State<PaymentVerifyScreen> {
  @override
  void initState() {
    super.initState();
    verifyPaymentProcess(); // ✅ Call on screen load
  }

Future<void> verifyPaymentProcess() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  final url = Uri.parse('$baseUrl/payment_process_verification.php');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'mobile_no': mobileNumber},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("🔍 API Response: $data");

      if (data['response'] == 'success') {
        List<dynamic> items = data['data'];

        for (var item in items) {
          String status = item['result_status'];

          if (status == 'accept') {
            showPopup(context, "✅ Accepted", "Your scheme ${item['reg_id']} was accepted.");
          } else if (status == 'reject') {
            showPopup(context, "❌ Rejected", "Your scheme ${item['reg_id']} was rejected.");
          }
        }
      } else {
        print("⚠️ API error: ${data['message']}");
      }
    } else {
      print("❌ Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Exception: $e");
  }
}


   void showPopup(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifying Payment')),
      body: const Center(child: Text('Checking...')),
    );
  }
}
