import 'dart:convert';
import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



Future<Map<String, dynamic>?> fetchOtpFromApiHelper() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  if (mobileNumber!.isEmpty) return null;

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/otp.php'),
      body: {'mobile_no': mobileNumber},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ API Error: ${response.body}");
      return null;
    }
  } catch (e) {
    print("❌ API Exception: $e");
    return null;
  }
}
