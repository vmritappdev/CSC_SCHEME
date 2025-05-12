import 'dart:convert';

import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>?> fetchTransactionsFromApi(String mobileNumber, String? schemeId) async {
  final url = Uri.parse('$baseUrl/transactions.php');

  try {
    print('Request URL: $url');
    print('Request Body: { "mobile_no": $mobileNumber, "scheme_id": $schemeId }');

    final response = await http.post(
      url,
      body: {
        'mobile_no': mobileNumber,
        'scheme_id': schemeId ?? '',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        return data['account_details'] as List;
      } else {
        print('Error: ${data['message']}');
        return null;
      }
    } else {
      throw Exception('Failed to load transactions');
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
