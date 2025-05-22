import 'dart:convert';
import 'dart:io';
import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  //final String baseUrl = 'https://vmrdemos.com/csc_scheme';

  Future<bool> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<Map<String, dynamic>> submitForm(String name, String mobileNo, String description) async {
    final url = "$baseUrl/enquiry.php";
    final data = {
      'name': name,
      'mobile_no': mobileNo,
      'description': description,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      

      if (response.statusCode == 200) {
         print('📦 API Response Body: ${response.body}');
        return json.decode(response.body);
      } else {
        return {'response': 'error', 'message': 'Failed to load data. Status code: ${response.statusCode}'};
      }
    } catch (e) {
      return {'response': 'error', 'message': 'An error occurred: $e'};
    }
  }
}
