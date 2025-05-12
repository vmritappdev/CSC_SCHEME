class Activescheme {
  final String schemeID;
  final String amountRs;
  final String month;
  final String year;
  final String payId;
  final String rejectId; // Added rejectId parameter
 // final String originalInstallmentAmount; // ✅ New field adde
 final String balanceAmount;
 final String installmentAmount;

  // Default Constructor
  Activescheme({
    this.schemeID = "", // Initialize with default empty values
    this.amountRs = "",
    this.month = "",
    this.year = "",
    this.payId = "",
    this.rejectId = "", // Default empty value
    this.balanceAmount = '',
    this.installmentAmount = '',
    // this.originalInstallmentAmount = "", // ✅ Default value
  });

  // Parameterized Constructor
  Activescheme.customparams({
    required this.schemeID,
    required this.amountRs,
    required this.month,
    required this.year,
    required this.payId,
    required this.rejectId,
    required this.balanceAmount,
    required this.installmentAmount,
     // Add rejectId to parameterized constructor
   // required this.originalInstallmentAmount, // ✅ Required here too
  });
}
