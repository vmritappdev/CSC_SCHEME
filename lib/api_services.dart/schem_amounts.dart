// file: api_service.dart
import 'dart:convert';
import 'package:csc/utillity/constant.dart';
import 'package:http/http.dart' as http;


class ApiService {
  Future<List<String>> fetchAmounts() async {
    final String url = "$baseUrl/get_amount.php";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          return (data['amount_details'] as List)
              .map((item) => item['amount'].toString())
              .toList();
        } else {
          throw Exception('Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }
}
