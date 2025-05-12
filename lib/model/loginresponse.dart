class VerificationResponse {
  final String response;
  final int status;
  final String message;
  final String process;
  final String process_status; 
  final String regId;
  final int schemeId;
  final String month;
  final String year;
  final String amount;

  VerificationResponse({
    required this.response,
    required this.status,
    required this.message,
    required this.process,
    required this.regId,
    required this.schemeId,
     required this.process_status,
    required this.month,
    required this.year,
    required this.amount,
  });

  // Factory constructor to create an instance from JSON
  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      response: json['response'] ?? '',
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message'] ?? '',
      process: json['process'] ?? '',
      regId: json['reg_id'] ?? '',
      schemeId: int.tryParse(json['schemeId']?.toString() ?? '0') ?? 0,
      month: json['month'] ?? '',
      year: json['year'] ?? '',
      amount: json['amount'] ?? '',
       process_status: json['process_status'] ?? '',  // Store process_status as string
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'status': status,
      'message': message,
      'process': process,
      'reg_id': regId,
      'schemeId': schemeId,
      'month': month,
      'year': year,
      'amount': amount,
    };
  }
}
