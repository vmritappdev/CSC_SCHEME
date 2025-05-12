// file: api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> submitRegistrationForm({
  required Map<String, String> data,
  File? adharImage,
  File? panImage,
  File? nomineeAdharImage,
  required String baseUrl,
}) async {
  try {
    var uri = Uri.parse('$baseUrl/save_registration.php');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');
    data['mobile_no'] = mobileNumber!;
  
    var request = http.MultipartRequest('POST', uri);

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (adharImage != null) {
      request.files.add(await http.MultipartFile.fromPath('adhar_image', adharImage.path));
    }
    if (panImage != null) {
      request.files.add(await http.MultipartFile.fromPath('pan_image', panImage.path));
    }
    if (nomineeAdharImage != null) {
      request.files.add(await http.MultipartFile.fromPath('nominee_adhar_image', nomineeAdharImage.path));
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print("Response Body: $responseBody");

    return json.decode(responseBody);
  } catch (e) {
    print("Error submitting form: $e");
    return null;
  }
}
