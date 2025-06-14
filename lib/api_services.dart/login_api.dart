// services/user_service.dart
import 'dart:convert';
import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<bool> fetchAndSaveUserDetails() async {
    String apiUrl = "$baseUrl/get_reg_account_details.php";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      String? mobileNumber = prefs.getString('userPhoneNumber');

      if (mobileNumber?.length != 10) {
        print("❌ Mobile Number not found in SharedPreferences");
        return false;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'mobile_no': mobileNumber},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 200) {
          var userDetails = jsonResponse['account_details'][0];
          await prefs.setString('firstName', userDetails['f_name']?.trim() ?? "");
          await prefs.setString('lastName', userDetails['l_name']?.trim() ?? "");
          await prefs.setString('phoneNumber', userDetails['mobile_no']?.trim() ?? "");
          await prefs.setString('email', userDetails['email_id']?.trim() ?? "");
          return true;
        }
      }
      return false;
    } catch (e) {
      print("❌ Error fetching user details: $e");
      return false;
    }
  }
}
