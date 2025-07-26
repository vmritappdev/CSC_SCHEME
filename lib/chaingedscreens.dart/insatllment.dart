import 'dart:convert';



import 'package:csc/api_services.dart/installment_api.dart';
import 'package:csc/chaingedscreens.dart/scner.dart';
import 'package:csc/utillity/bouncing.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/utillity/constantcolor.dart';
import 'package:csc/utillity/netmix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const InstallmentScreen(schemeId: ''),
    ),
  );
}

class InstallmentScreen extends StatefulWidget {
  final String schemeId;

  const InstallmentScreen({super.key, required this.schemeId});

  @override
  _InstallmentScreenState createState() => _InstallmentScreenState();
}

class _InstallmentScreenState extends State<InstallmentScreen>   with NetworkMixin{
  int selectedInstallment = -1; // First unpaid installment index
  List<Map<String, dynamic>> installments = [];
  bool isLoading = true; // Loader flag
  final _formKey = GlobalKey<FormState>();


  

double? balanceAmount;
int? dueDays;
double? paidAmount;
String? _amountError;


 //final RefreshController _refreshController = RefreshController();




String selectedOption = 'emi';

// String selectedOption = 'any';
TextEditingController _amountController = TextEditingController(text: '');



 String formatAmount(String value) {
  try {
    final formatter = NumberFormat('#,##0', 'en_IN');

    // Only remove commas and spaces, keep decimal point
    final cleaned = value.replaceAll(',', '').trim();

    final number = double.tryParse(cleaned);
    if (number == null) return '0';

    return formatter.format(number);
  } catch (e) {
    return value;
  }
}







  @override
  void initState() {
    super.initState();
    _fetchInstallmentDetails();
     _amountController = TextEditingController();
    
    
  }



  


Future<void> _fetchInstallmentDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');
  String schemeId = widget.schemeId;

  if (schemeId.isEmpty) {
    print("Error: Mobile number or Scheme ID is missing.");
    return;
  }

  setState(() {
    isLoading = true;
  });

  final installmentDetails = await fetchInstallmentDetails(mobileNumber!, schemeId);
  if (installmentDetails != null && installmentDetails.isNotEmpty) {
    setState(() {
      installments = installmentDetails;
    });
    _selectFirstUnpaidInstallment();
  }

  setState(() {
    isLoading = false;
  });
}


void _selectFirstUnpaidInstallment() {
  for (int i = 0; i < installments.length; i++) {
    if (installments[i]["payment_status"] != "Paid") {
      setState(() {
        selectedInstallment = i;
      });

      fetchBalanceAndDays(
        widget.schemeId,
        installments[i]["month"].toString(),
        installments[i]["year"].toString(),
      ).then((extraData) {
        // handle if needed
      });
      return; // Stop after finding first unpaid
    }
  }

  // If all are paid
  setState(() {
    selectedInstallment = -1;
  });
}




  // Refresh screen after payment
  void _refreshScreen() {
    setState(() {
      isLoading = true;
    });
    _fetchInstallmentDetails(); // Reload data from API
  }

   String getLocalizedInstallment(String installment, LocalizationProvider localization) {
    RegExp regExp = RegExp(r'(\d+)(st|nd|rd|th) INSTALLMENT', caseSensitive: false);
    Match? match = regExp.firstMatch(installment);
    if (match != null) {
      String number = match.group(1) ?? "";
      return "$number ${localization.translate("Installment")}";
    }
    return installment;
  }



  Future<void> fetchBalanceAndDays(String schemeId, String month, String year) async {
  var url = '$baseUrl/fetch_amount.php';  

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
       print('API Response: $data');
      if (data['status'] == 200) {
        setState(() {
          balanceAmount = double.tryParse(data['balance_amount'].toString());

          dueDays = int.tryParse(data['days'].toString());
          paidAmount = double.tryParse(data['paid_amount'].toString());
        });
      }
    } else {
      print('Error fetching balance and days: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

Color getStatusColor(String? status) {
  if (status == "Paid") return Colors.green;
  if (status == "Process") return Colors.orange;
  return Colors.black; // Default for unpaid
}




  @override
  Widget build(BuildContext context) {
   final localization = Provider.of<LocalizationProvider>(context,listen: false);
    return  Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.blue,
          title: Text(localization.translate('Installment Schedule'),
          style: GoogleFonts.lato(color: Colors.white),),
          leading: const BackButton(color: Colors.white,),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
          
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localization.translate("Payment Schedule"), 
                  style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: isLoading || selectedInstallment == -1
                        ? Center(
            child: BouncingDotsLoader(
    color: Color(0xFF002970), // Paytm blue or gold
    size: 12.0,
  ),
          ) // Loader
                        : ListView.builder(
                      itemCount: installments.length,
                      itemBuilder: (context, index) {
                    final installment = installments[index];
                    bool isPaid = installment["payment_status"] == "Paid";
                    
                    
                    if (!isPaid && index != selectedInstallment) {
                      return const SizedBox.shrink(); // ❌ Skip this one
                    }
                    
                    return  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Card(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: index == selectedInstallment && !isPaid
                ? AppColors.blue
                : Colors.transparent,
                      width: 2,
                    ),
                      ),
                      child: IgnorePointer(
                    ignoring: isPaid,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              RadioListTile<int>(
                value: index,
                groupValue: selectedInstallment,
                onChanged: isPaid
                    ? null
                    : (int? value) {
                        setState(() {
                          selectedInstallment = value!;
                        });
                      },
                title: Text(
                  getLocalizedInstallment(
                    installment["installment"],
                    localization,
                  ),
                  style: GoogleFonts.lato(fontSize: 14),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaid
                      ? "${localization.translate("Paid on")} ${installment["month_year1"]}"
                      : installment["payment_status"] == "Process"
                ? "${localization.translate("Process")} ${installment["month_year"]}"
                : "${localization.translate("Pay before")} ${installment["month_year"]}",
                      style: TextStyle(
                    color: getStatusColor(installment["payment_status"]),
                      ),
                    ),
                    
                    if (!isPaid && paidAmount != null && balanceAmount != null)
                      Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
              Expanded(
                child: Text(
                  "${localization.translate('Paid')}: ₹${formatAmount(paidAmount!.toString())}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                "${localization.translate('Balance')}: ₹${formatAmount(balanceAmount!.toString())}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ),
                      ],
                    ),
                      ),
                    
                  ],
                ),
                secondary: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   Text(
                      "₹${installment["amount"]}",
                      style: TextStyle(
                    color: installment["payment_status"] == "Paid"
              ? Colors.green
              : installment["payment_status"] == "Process"
                  ? Colors.orange
                  : Colors.black, // Default color
                    fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (installment["payment_status"] == "Paid")
                      const Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      "Paid",
                      style: TextStyle(color: Colors.green),
                    ),
                      ),
                    if (installment["payment_status"] == "Process")
                      const Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      "Process",
                      style: TextStyle(color: Colors.orange),
                    ),
                      ),
                    
                  ],
                ),
              ),
                      ],
                    ),
                      ),
                    ),
                    
                    
                    
                    
                    const SizedBox(height: 20,),
                    
                  
                      if (!isPaid && index == selectedInstallment)
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      
                       Padding(
              padding: EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Text(
               localization.translate('Choose payment option'),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
                      ),
                      const SizedBox(height: 20),
                    
                      // Pay Installment
                      Row(
              children: [
                Radio(
                  value: localization.translate('emi'),
                  groupValue: selectedOption,
                  onChanged: (val) {
                    setState(() {
                      selectedOption = val!;
                    });
                  },
                  activeColor: AppColors.blue,
                ),
                 Text(
                localization.translate('Pay Installment'),
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 10),
                
               Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                    color: () {
                       print('📆 dueDays: $dueDays'); // Debug print here
                      if (dueDays == null) return Colors.grey;
                      if (dueDays! >= 0) {
              // Normal due - green color
              return Colors.green;
                      } else {
              // Overdue - orange color
              return Colors.orange;
                      }
                    }(),
                    borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                    () {
                      if (dueDays == null) return '';
                      if (dueDays == 0) return localization.translate('DUE TODAY');
                      if (dueDays == 1) return localization.translate('DUE TOMORROW');
                      if (dueDays! > 1) return 'DUE IN $dueDays DAYS';
                      
                     // return 'OVERDUE BY ${dueDays?.abs()} DAYS';
                     return '${localization.translate("OVERDUE BY")} ${dueDays?.abs()} ${localization.translate("DAYS")}';
                     }(),
                    style: const TextStyle(
                    color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                      ),
                    )
                    
              ],
                      ),
                    
                      
                      Row(
              children: [
                Radio(
                  value: 'any',
                  groupValue: selectedOption,
                  onChanged: (val) {
                    setState(() {
                      selectedOption = val!;
                    });
                  },
                  activeColor: const Color(0xFF2B004B),
                ),
                 Text(
                localization.translate( 'Pay any amount'),
                  style: TextStyle(fontSize: 14),
                ),
              ],
                      ),
                    
                      const SizedBox(height: 10),
                    
                      if (selectedOption == 'any') ...[
                       Form(
                        key: _formKey,
                         child: TextFormField(
                                             controller: _amountController,
                                             keyboardType: TextInputType.number,
                                            onChanged: (value) {
                           final digits = value.replaceAll(RegExp('[^0-9]'), '');
                           final formatted = formatAmount(digits); // ₹1,000 type format
                         
                           
                           if (formatted != _amountController.text) {
                             final oldSelection = _amountController.selection;
                             final newLengthDiff = formatted.length - _amountController.text.length;
                         
                             
                            _amountController.text = formatted;
                         
          
                             int newOffset = oldSelection.baseOffset + newLengthDiff;
                             if (newOffset > formatted.length) newOffset = formatted.length;
                             _amountController.selection = TextSelection.collapsed(offset: newOffset);
                           }
                         
                           // Validation
                           final raw = formatted.replaceAll(RegExp('[^0-9]'), '');
                           final enteredAmount = raw.isNotEmpty ? int.parse(raw) : 0;
                           final balAmount = balanceAmount?.toInt() ?? 0;
                         
                         
                         
                           setState(() {
                             _amountError = enteredAmount > balAmount + 1
                                 ? "${localization.translate('Amount exceeds balance by more than')}: ₹${formatAmount(balanceAmount!.toString())}"
                                 : null;
                           });
                         
                           
                         },
                         
                                            decoration: InputDecoration(
                                           prefixText: '₹',
                                           labelText: localization.translate('Enter Amount'),
                                           border: const OutlineInputBorder(),
                                           focusedBorder: const OutlineInputBorder(
                                             borderSide: BorderSide(color: AppColors.blue, width: 2),
                                           ),
                                           errorText: _amountError, // 👈 Shows error here
                                             ),
                                           ),
                       ),
                    
              const SizedBox(height: 6),
                    
             
                       
                      ],
                    
                      const SizedBox(height: 30),
                    ],
                      ),
                    
                    
                    
                      ],
                    );
                    
                      },
                    )
                    
                  ),
              
              
              
                  
              
              
                  
                    
              Column(
                children: [
                  // First Condition: dueDays < -60
                  if (dueDays != null && dueDays! < -60)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
                      ),
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, color: Color(0xFFEF6C00), size: 14),
                    SizedBox(width: 8),
                    Text(
                      localization.translate('Payment Access Disabled'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF6C00),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  localization.translate(
                      'You have not paid your installment for over 60 days. As a result, the direct payment option has been disabled. Please contact CSC Jewellers admin or visit our branch in Nellore.'),
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5D4037),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: Color(0xFFEF6C00)),
                    SizedBox(width: 6),
                    Text(
                      localization.translate('Admin Contact: 94906 57008'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBF360C),
                      ),
                    ),
                  ],
                ),
              ],
                      ),
                    ),
              
                  // Second Condition: count > 0
                 if (selectedInstallment >= 0 &&
                  selectedInstallment < installments.length &&
                  int.tryParse(installments[selectedInstallment]['count'].toString()) != null &&
                  int.parse(installments[selectedInstallment]['count'].toString()) > 0)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Expanded(
              child: Text(
                localization.translate(
                  'Admin will accept or reject your previous payment. You can proceed with the next payment only after that.',
                ),
                style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
              ),
                      ),
                    ],
                  ),
                ),
              
                ],
              ),
              
              
                        
                 if (installments.isNotEmpty &&
                  selectedInstallment != -1 &&
                   installments.length > selectedInstallment &&
                  installments[selectedInstallment]["payment_status"] != "Paid")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                    
                    
                       SizedBox(
                      width: double.infinity,
                      child:ElevatedButton(
                      style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
              
                      
              onPressed: (installments[selectedInstallment]["status"] == "1" && dueDays != null && dueDays! >= -60)
              
                     
                    ? () async {
                       print("Due Days: $dueDays");
              // Step 1: Get amounts
              String rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
              int enteredAmount = rawAmount.isNotEmpty ? double.parse(rawAmount).toInt() : 0;
              int installmentAmount = double.parse(installments[selectedInstallment]["amount"].toString()).toInt();
              int balAmount = balanceAmount?.toInt() ?? 0;
                    
              // Step 2: Validate entered amount for custom payment
              if (selectedOption == 'any') {
                if (enteredAmount == 0) {
                  // ⚠️ Empty amount
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title:  Text(localization.translate("Empty Amount")),
                      content:  Text(localization.translate("Please enter an amount to proceed.")),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child:  Text(localization.translate("OK")),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                    
                if (enteredAmount > installmentAmount) {
                  // ❌ More than installment amount
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title:  Text(localization.translate("Invalid Amount")),
                      content:  Text(localization.translate("You cannot pay more than the installment amount.")),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child:  Text(localization.translate("OK")),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                    
                if (enteredAmount > balAmount) {
                  // ❌ More than balance amount
                _showInvalidOTPDialog1();
                  return;
                }
              }
                    
                      
                       String finalAmount;
                    
                    
              // Step 3: Proceed with valid final amount
                       if (rawAmount.isNotEmpty) {
                      finalAmount = enteredAmount.toString();
                    } else if (installments[selectedInstallment]["payment_status"] != "Paid") {
                      finalAmount = balanceAmount?.toInt().toString() ?? "0";
                    } else {
                      finalAmount = installmentAmount.toString();
                    }
                    
                    
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scanner(
                    activescheme: Activescheme.customparams(
                      schemeID: widget.schemeId,
                      amountRs: finalAmount,
                      month: installments[selectedInstallment]["month"],
                      year: installments[selectedInstallment]["year"],
                      payId: '',
                      rejectId: '',
                       balanceAmount: balanceAmount?.toString() ?? "", // ✅
                       installmentAmount: installmentAmount.toString(),  // ✅
                    ),
                    rejectId: '',
                    
                  ),
                ),
              );
                    
              // Step 4: Refresh
              _refreshScreen();
                      }
                    : null,
                    
                    
                      // Step 6: Show button text
                      child:  Builder(
                      builder: (context) {
                    String rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                    int installmentAmount = double.parse(installments[selectedInstallment]["amount"].toString()).toInt();
                    int balAmount = balanceAmount?.toInt() ?? 0;
                    String paymentStatus = installments[selectedInstallment]["payment_status"].toString();
                  // String countStr = installments[selectedInstallment]['count'].toString();
                   // int count = int.tryParse(countStr) ?? 0;
                    
                    String finalAmount;
              
              
                    
                    
                    // Custom entered amount (Pay Any Amount)
                    if (selectedOption == 'any' && rawAmount.isNotEmpty) {
                      finalAmount = double.parse(rawAmount).toInt().toString();
                    }
                    // If it's unpaid, show balance amount
                    else if (paymentStatus != "Paid") {
                      finalAmount = balAmount.toString();
                    }
                    // If paid, show installment amount
                    else {
                      finalAmount = installmentAmount.toString();
                    }
                    
                    return Text(
                      "${localization.translate("Pay")}: ₹${formatAmount(finalAmount)}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    );
                      },
                    ),
                    
                    ),
                    
                    
                    ),
                    
                    
                    
                      ],
                    ),
                ],
              ),
            
          ),
        ),
      
    );
  }



  void showInvalidOTPDialog() {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;
  final localization = Provider.of<LocalizationProvider>(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.02), // Dynamic Border Radius
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: screenHeight * 0.02), // Dynamic Spacing
            Icon(Icons.error, color: Colors.red, size: screenWidth * 0.1), // Dynamic Icon Size
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Dynamic Padding
              child: Text(
               localization.translate('Oops! You’re only allowed to pay up to your installment amount.'),
                style: GoogleFonts.lato(fontSize: screenWidth * 0.04), // Dynamic Font Size
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.blue,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                 localization.translate("OK"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045, // Dynamic Button Font Size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showInvalidOTPDialog1() {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;
  final localization = Provider.of<LocalizationProvider>(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.02), // Dynamic Border Radius
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: screenHeight * 0.02), // Dynamic Spacing
            Icon(Icons.error, color: Colors.red, size: screenWidth * 0.1), // Dynamic Icon Size
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Dynamic Padding
              child: Text(
               localization.translate('You cannot pay more than the remaining balance.'),
                style: GoogleFonts.lato(fontSize: screenWidth * 0.04), // Dynamic Font Size
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.blue,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                 localization.translate("OK"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045, // Dynamic Button Font Size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}




}




