// Fetch Installment Details
import 'dart:convert';

import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>?> fetchInstallmentDetails(String mobileNumber, String schemeId) async {
  const url = '$baseUrl/pay_due_details.php';  //'https://vmrdemos.com/csc_scheme/pay_due_details.php'

  try {
    final response = await http.post(
    Uri.parse(url),
    body: {
        'mobile_no': mobileNumber,
        'scheme_id': schemeId,
      },
    );


     print('📬 Response Status Code: ${response.statusCode}');
    print('📬 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      print("Error fetching installments. Status: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception while fetching installments: $e");
  }

  return null; // Return null if any error occurs
}

// Fetch Balance and Due Days for a given installment
Future<Map<String, dynamic>?> fetchBalanceAndDays(String schemeId, String month, String year) async {
  const url = '$baseUrl/fetch_amount.php';  //'https://vmrdemos.com/csc_scheme/fetch_amount.php'

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'scheme_id': schemeId,
        'month': month,
        'year': year,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Installment details fetched: $data");
      return {
        'balance_amount': double.tryParse(data['balance_amount'].toString()),
        'due_days': int.tryParse(data['days'].toString()),
        'paid_amount': double.tryParse(data['paid_amount'].toString()),
      };
    } else {
      print('Error fetching balance and days: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }

  return null;
}
