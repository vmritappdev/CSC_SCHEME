class Installment {
  final String installment;
  final double amount;
  final String monthYear;
  final String paymentStatus;
  final int month;
  final int year;
  final int schemeId;

  Installment({
    required this.installment,
    required this.amount,
    required this.monthYear,
    required this.paymentStatus,
    required this.month,
    required this.year,
    required this.schemeId,
  });

  // A method to create an Installment object from JSON data
  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      installment: json['installment'],
      amount: double.parse(json['amount'].toString()),
      monthYear: json['month_year'],
      paymentStatus: json['payment_status'],
      month: int.parse(json['month'].toString()),
      year: int.parse(json['year'].toString()),
      schemeId: int.parse(json['scheme_id'].toString()),
    );
  }
}
