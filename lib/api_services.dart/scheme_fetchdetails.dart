// registration_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csc/utillity/constant.dart'; // import your baseUrl from constants if needed

class RegistrationService {
  Future<Map<String, dynamic>?> fetchRegistrationDetails() async {
    final url = Uri.parse("$baseUrl/reg_details.php");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');

    if (mobileNumber == null) {
      print("📵 Mobile number not found in SharedPreferences.");
      return null;
    }

    try {
      final response = await http.post(
        url,
        body: {'mobile_no': mobileNumber},
      );

       print("📥 Response Code: ${response.statusCode}");
    print("🧾 Raw Response Body: ${response.body}");


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 && data['reg_details'] != null && data['reg_details'].isNotEmpty) {
          return data['reg_details'][0];
        } else {
          print("⚠️ No registration details found.");
          return null;
        }
      } else {
        print("❌ Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❗ Exception during fetch: $e");
      return null;
    }
  }
}
