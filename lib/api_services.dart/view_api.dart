// file: api_service.dart
import 'dart:convert';
import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



Future<Map<String, dynamic>?> fetchInstallmentHistory(String schemeId) async {
  final prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  if (mobileNumber!.isEmpty) {
    print("Mobile number not found.");
    return null;
  }

  final url = Uri.parse('$baseUrl/installment_history.php');

  try {
    final response = await http.post(
      url,
      body: {
        'mobile_no': mobileNumber,
        'schemeId': schemeId,
      },
    );


        print("Response Status Code: ${response.statusCode}");
    print("Full API Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      print("HTTP Error ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("API Error: $e");
    return null;
  }
}
