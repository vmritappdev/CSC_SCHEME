// file: pincode_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PincodeDetails {
  final String district;
  final String state;
  final String city;
  final String country;

  PincodeDetails({
    required this.district,
    required this.state,
    required this.city,
    required this.country,
  });
}

Future<PincodeDetails?> fetchPincodeDetails(String pincode) async {
  final url = 'https://api.postalpincode.in/pincode/$pincode';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data[0]['Status'] == 'Success') {
        final postOffice = data[0]['PostOffice'][0];

        return PincodeDetails(
          district: postOffice['District'].toString().toUpperCase(),
          state: postOffice['State'].toString().toUpperCase(),
          city: (postOffice['City'] ?? postOffice['District']).toString().toUpperCase(),
          country: 'INDIA',
        );
      } else {
        return null; // Invalid pincode
      }
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    return null; // Network error
  }
}
