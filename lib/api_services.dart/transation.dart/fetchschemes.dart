import 'dart:convert';

import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>?> fetchSchemesFromApi(String mobileNumber) async {
  final url = Uri.parse('$baseUrl/get_schemes.php');

  try {
    final response = await http.post(
      url,
      body: {
        'mobile_no': mobileNumber,
      },
    );

    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        return List<Map<String, dynamic>>.from(data['scheme_details']);
      } else {
        print('Error from server: ${data['message']}');
        return null;
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exception in API: $e');
    return null;
  }
}
