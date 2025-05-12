// file: bank_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BankDetails {
  final String bankName;
  final String branch;

  BankDetails({required this.bankName, required this.branch});
}

Future<BankDetails?> fetchBankDetailsFromIFSC(String ifsc) async {
  final url = 'https://ifsc.razorpay.com/$ifsc';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return BankDetails(
        bankName: (data['BANK'] ?? '').toString().toUpperCase(),
        branch: data['BRANCH'] ?? '',
      );
    } else {
      return null; // Invalid IFSC
    }
  } catch (e) {
    return null; // Network error
  }
}
