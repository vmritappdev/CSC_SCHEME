class SchemeResponseNew {
  final List<SchemeDetailsNew> schemeDetails;
  final List<SchemeDetailsNew> activeSchemes;
  final List<SchemeDetailsNew> closedSchemes;
  final List<SchemeDetailsNew> suspendedSchemes;

  SchemeResponseNew({
    required this.schemeDetails,
    required this.activeSchemes,
    required this.closedSchemes,
    required this.suspendedSchemes,
  });

  // Factory constructor to parse from JSON
  factory SchemeResponseNew.fromJson(Map<String, dynamic> json) {
    return SchemeResponseNew(
      schemeDetails: (json['schemeDetails'] as List<dynamic>?)?.map((item) {
        return SchemeDetailsNew.fromJson(item as Map<String, dynamic>);
      }).toList() ?? [], // Default to an empty list if 'schemeDetails' is null

      activeSchemes: (json['activeSchemes'] as List<dynamic>?)?.map((item) {
        return SchemeDetailsNew.fromJson(item as Map<String, dynamic>);
      }).toList() ?? [], // Default to an empty list if 'activeSchemes' is null

      closedSchemes: (json['closedSchemes'] as List<dynamic>?)?.map((item) {
        return SchemeDetailsNew.fromJson(item as Map<String, dynamic>);
      }).toList() ?? [], // Default to an empty list if 'closedSchemes' is null

      suspendedSchemes: (json['suspendedSchemes'] as List<dynamic>?)?.map((item) {
        return SchemeDetailsNew.fromJson(item as Map<String, dynamic>);
      }).toList() ?? [], // Default to an empty list if 'suspendedSchemes' is null
    );
  }
}

class SchemeDetailsNew {
  final String amount;
  final String dueDate;
  final int days;
  final String month;
  final String year;
  final String schemeId;
  final String msNo;
  final String payStatus;
  final String name;
  final String schemeStatus;
  final String overdue;
  final String paid_amount;

  SchemeDetailsNew({
    required this.amount,
    required this.dueDate,
    required this.days,
    required this.month,
    required this.year,
    required this.schemeId,
    required this.msNo,
    required this.payStatus,
    required this.name,
    required this.schemeStatus,
    required this.overdue,
    required this.paid_amount,
  });

  // Factory constructor to parse from JSON
  factory SchemeDetailsNew.fromJson(Map<String, dynamic> json) {
    return SchemeDetailsNew(
      amount: json['amount']?.toString() ?? '0', // Ensure amount is always a String
      dueDate: json['due_date']?.toString() ?? '', // Handle nulls gracefully
      days: json['days'] is int
          ? json['days'] as int
          : int.tryParse(json['days']?.toString() ?? '0') ?? 0, // Fallback to 0
      month: json['month']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      schemeId: json['scheme_id']?.toString() ?? '',
      msNo: json['ms_no']?.toString() ?? '',
      payStatus: json['pay_status']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      schemeStatus: json['scheme_status']?.toString() ?? '0',
      overdue: json['over_due_status']?.toString() ?? '0',
      paid_amount: json['paid_amount']?.toString() ?? '0',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'due_date': dueDate,
      'days': days,
      'month': month,
      'year': year,
      'scheme_id': schemeId,
      'ms_no': msNo,
      'pay_status': payStatus,
      'name': name,
      'scheme_status': schemeStatus,
      'over_due_status': overdue,
    };
  }

}
