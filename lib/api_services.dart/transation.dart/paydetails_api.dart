import 'dart:convert';

import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchPayDetailsFromApi(String id) async {
  final url = Uri.parse('$baseUrl/get_pay_details.php');

  try {
    print('Request URL for Pay Details: $url');
    print('Request Body: { "id": $id }');

    final response = await http.post(
      url,
      body: {
        'id': id,
      },
    );

    print('Response Body (Pay Details): ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        return {
          'amount': data['amount'] ?? "Unknown",
          'payment_type': data['payment_type'] ?? "Unknown",
          'date': data['date'] ?? "Unknown",
          'scheme': data['scheme'] ?? "Unknown",
        };
      } else {
        print('Error in Pay Details: ${data['message']}');
        return null;
      }
    } else {
      throw Exception('Failed to load payment details');
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
