import 'dart:convert';

import 'package:csc/api_services.dart/transation.dart/fetchdetails_api.dart';
import 'package:csc/api_services.dart/transation.dart/fetchschemes.dart';
import 'package:csc/api_services.dart/transation.dart/paydetails_api.dart';
import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/chaingedscreens.dart/pd%20frecipit.dart';
import 'package:csc/utillity/check%20internet.dart';

import 'package:csc/utillity/constant.dart';
import 'package:csc/customshapes/snake_painter.dart';
import 'package:csc/dashboardscreens/faq_screen.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/dashboardscreens/active_scheme.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/upidetails/payment%20verify.dart';


import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
      home: const Transaction(),
    ),
  );
}



class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final double budget = 10000; // Example total budget
  final double spent = 4500; // Example spent amount

   bool isRejectedExpanded = false; // Add this at the top (inside State)


   String mobileNumber = ''; // To store mobile number
  List<Map<String, dynamic>> transactions = []; // List to hold transaction data
   TextEditingController searchController = TextEditingController();
   List<Map<String, dynamic>> schemes = [];
  List<Map<String, dynamic>> filteredSchemes = []; // List to hold filtered schemes
  bool isLoading = false;
    String? selectedSchemeId; // Store selected scheme ID
  List<String> schemeIds = [];
   String? transactionId; 

   final RefreshController _refreshController = RefreshController();

void _onRefresh() async {
  try {
    await fetchSchemes();
    await _fetchTransactionData(selectedScheme);
  } catch (e) {
    print("Error during refresh: $e");
  } finally {
    _refreshController.refreshCompleted();
  }
}

  

String? selectedScheme; // For dropdown selection
//List<Map<String, String>> filteredSchemes = [];

  
Future<void> saveMobileNumber(String mobileNumber) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('mobile_number', mobileNumber);
}

  // Fetch mobile number from SharedPreferences
  Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mobile_number');
  }



  
  
 



  // Fetch transaction data
 Future<void> _fetchTransactionData(String? schemeId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    const ErrorScreen(); // This should be a Navigator.push or similar
    return;
  }

  print("Mobile number retrieved: $mobileNumber");

  // Backend call
  final transactionsData = await fetchTransactionsFromApi(mobileNumber!, schemeId);

  if (transactionsData != null && transactionsData.isNotEmpty) {
    setState(() {
      transactions = transactionsData.map((transaction) {
        return {
          'id': transaction['id'],
          'date': transaction['date'],
          'amount': double.parse(transaction['amount']),
          'status': transaction['status_label'],
          'remark': transaction['remark'],
          'reg_id': transaction['reg_id'],
          'time': transaction['time'],
        };
      }).toList();
    });

    // Call second API
    String transactionId = transactionsData[0]['id'];
    _fetchPayDetails(transactionId);
  } else {
    print("No transactions found or error occurred.");
  }
}


Future<void> _fetchPayDetails(String id) async {
  bool hasInternet = await checkInternet();
  if (!hasInternet) {
    const ErrorScreen(); // Navigator.push(context, MaterialPageRoute(...)) ideally
    return;
  }

  final payDetails = await fetchPayDetailsFromApi(id);

  if (payDetails != null) {
    print("Payment Details:");
    print("Amount: ${payDetails['amount']}");
    print("Payment Type: ${payDetails['payment_type']}");
    print("Date: ${payDetails['date']}");
    print("Scheme: ${payDetails['scheme']}");

    // If needed, you can use setState here to update UI
    // setState(() {
    //   paymentInfo = payDetails;
    // });
  } else {
    print("No payment details found or an error occurred.");
  }
}

  // Fetch amount options from the server
 
  // Fetch schemes based on mobile number and apply search filter
 Future<void> fetchSchemes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mobileNumber = prefs.getString('phoneNumber');

  print("Mobile number retrieved: $mobileNumber");

  setState(() {
    isLoading = true;
  });

  final response = await fetchSchemesFromApi(mobileNumber!);

  if (response != null) {
    setState(() {
      schemes = response;
      filteredSchemes = response;
      isLoading = false;
    });

    // Optional: Debug print
    for (var scheme in schemes) {
      String fName = scheme['f_name'] ?? 'N/A';
      String schemeAmount = scheme['scheme_amount'] ?? 'N/A';
      print("Name: $fName, Scheme Amount: $schemeAmount");
    }
  } else {
    print('Failed to load schemes or error occurred.');
    setState(() {
      isLoading = false;
    });
  }
}


  // Filter schemes based on the search query
  void filterSchemes(String query) {
    final filtered = schemes.where((scheme) {
      final regId = scheme['reg_id'].toString().toLowerCase();
      return regId.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredSchemes = filtered;
    });
  }





   
 
  @override
  void initState() {
    super.initState();
    _fetchTransactionData('');
  
     fetchSchemes(); // Fetch schemes based on mobile number
    searchController.addListener(() {
      filterSchemes(searchController.text); // Filter schemes as user types in the search bar
    });
  
    
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

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);

    

    final double left = budget - spent; // Remaining amount
    final double progress = spent / budget; // Progress calculation
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.2,
                  width: screenWidth, // Full width of the screen
                  color: const Color.fromRGBO(2, 5, 62, 1), // Blue color
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
      
                      Row(
                        children: [
                          const BackButton(color: Colors.white),
      
                          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
      
      
                          Text(
                            localization.translate("Scheme Investment"), // Localized text
                            style:  TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.06,
      
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
      
                      
      
      
                    ],
                  ),
                ),
               
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: SnakePainter(),
                    child:Container(height: MediaQuery.of(context).size.height * 0.025),
      
                  ),
                ),
              ],
            ),
            
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
          onRefresh: _onRefresh,
      
            header: WaterDropHeader(
            complete: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text("Refresh Completed", style: TextStyle(color: Colors.green)),
              ],
            ),
            waterDropColor: const Color.fromARGB(255, 4, 2, 29),
          ),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                   SizedBox(height: MediaQuery.of(context).size.height * 0.0125),
                
                      // Row with icon and title aligned
                      Padding(
                       padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                
                        child: Row(
                          children: [
                            const Icon(
                              Icons.payment, // Transaction icon
                              size: 24,
                              color: Color.fromRGBO(2, 5, 62, 1),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              localization.translate("Recent Transactions"), // Localized text
                              style:  TextStyle(
                               fontSize: MediaQuery.of(context).size.width * 0.045,
                
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(2, 5, 62, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                
                
                       SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                
                
                
                     
                  
                
                        
                   Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: DropdownButtonFormField<String>(
                    value: selectedSchemeId,
                    isExpanded: true,
                    items: [
                      // 'All' option
                      const DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('All'),
                      ),
                      // Scheme options
                      ...schemes.map((scheme) {
                        return DropdownMenuItem<String>(
                          value: scheme['reg_id'].toString(), // ✅ Only reg_id as value
                          child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: '${scheme['reg_id']}  ', // ✅ reg_id
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${scheme['f_name']} ${scheme['l_name']}  ', // ✅ f_name and l_name
                      style: const TextStyle(color: Colors.blue),
                    ),
                    TextSpan(
                      text: '₹${scheme['scheme_amount']}', // ✅ scheme_amount
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                          ),
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      labelText: localization.translate("Select Scheme ID"),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.006,
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                      ),
                      border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 3)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(2, 5, 62, 1), width: 2),
                      ),
                      floatingLabelStyle: const TextStyle(color: Color.fromRGBO(2, 5, 62, 1)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedSchemeId = value;
                        searchController.text = value ?? ''; // ✅ Only reg_id will be shown in search bar
                      });
                
                      // ✅ API ki only reg_id pass avuthundi
                      if (selectedSchemeId == 'all') {
                        _fetchTransactionData(null);
                      } else {
                        _fetchTransactionData(selectedSchemeId);
                      }
                    },
                  ),
                ),
                
                
                
                    
                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: transactions.length, // Dynamic list length based on fetched data
                          itemBuilder: (context, index) {
                final transaction = transactions[index];
                final amount = transaction['amount'];
                final status = transaction['status'];
                 final remark = transaction['remark'];
                 final time = transaction['time'];
                  final regId = transaction['reg_id'];
                 
                          final statusColor = status == 'Completed'
                    ? Colors.green
                    : status == 'Rejected' || status == 'Unknown'
                        ? Colors.red
                        : status == 'Process'
                ? Colors.orange
                : Colors.grey; // Default color (if needed)
                 
                
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    getStatusIcon(status),
                    color: getStatusIconColor(status),
                    size: 24,
                  ),
                ),
                
                    title:Text(
                      transaction['reg_id'] ?? 'No Remark Available',  // Safely fetch and display 'remark'
                      style:  TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.030,
                    
                        color: const Color.fromRGBO(2, 5, 62, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    
                    
                    
                     subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                    
                    
                    
                    
                           Text(
                  '${getOrdinalSuffix(int.tryParse(transaction['remark']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0)} installment',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    color: const Color.fromRGBO(2, 5, 62, 1),
                  //  fontWeight: FontWeight.bold,
                  ),
                ),
                   
                
                
                
                       Text(
                            "${transaction['date']} - ${transaction['time']}",
                            style:  TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.030,
                       
                              color: Colors.grey,
                            ),
                          ),
                    
                        
                  
                
                              
                    
                          
                     
                               
                
                    
                    
                     
                              ],
                            ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                    
                    
                          
                       
                         Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // aligns amount and status to the right
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₹${NumberFormat('#,##0.00', 'en_IN').format(amount.abs())}",
                          style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2), // spacing between amount and status
                        Text(
                          status,
                          style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.03,
                fontWeight: FontWeight.bold,
                color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8), // space between column and arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
                
                             
                         
                          
                        ],
                      ),
                    
                    
                           onTap: () {
                  final transactionId = transaction['id']; // Installment ID
                  final status = transaction['status'];
                
                  if (status == 'Completed') {
                    _showCustomBottomSheet(context, transactionId);
                  } else if (status == 'Process') {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentVerificationScreen(id: transactionId),
                      ),
                    );
                  } else if (status == 'Rejected') {
                    // Show bottom sheet with rejection reason
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reason for Rejection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromRGBO(2, 6, 67, 1),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'The payment details you provided could not be verified as credited to our account. Please double-check your transaction status and ensure that the correct details are submitted. For further information or clarification, please contact the CSC Jewellers Admin. Contact: 94906 57008',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                          color: const Color.fromRGBO(2, 6, 67, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                          ),
                        );
                      },
                    );
                  }
                },
                
                    
                
                    ),
                
                
                
                          
                
                          
                  ],
                );
                          },
                        ),
                      ),
                
                
                    ],
                  ),
                ),
              ),
            ),
      
      
      const SizedBox(height: 40,),
            
          ],
        ),
         
      
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
              builder: (context) => const PaymentCard(),
              )
            );
          },
          label: Text(
            
            localization.translate("My Scheme"),
            style:  TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width * 0.045,
      ),
          ),
         // icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor:  Colors.red,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(2, 5, 62, 1),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Padding(
           padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen(activescheme: Activescheme(),)),
                    );
                  },
                ),
                 IconButton(
                icon: Image.asset(
        'assets/images/faq.png',
        width: MediaQuery.of(context).size.width * 0.08,
        height: MediaQuery.of(context).size.width * 0.08,
        color: Colors.white,
      ),
      
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FAQScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


   getInstallmentTitle(int installmentNumber) {
  if (installmentNumber == 1) {
    return '1st INSTALLMENT';
  } else if (installmentNumber == 2) {
    return '2nd INSTALLMENT';
  } else if (installmentNumber == 3) {
    return '3rd INSTALLMENT';
  } else {
    return '${installmentNumber}th INSTALLMENT'; // For 4th, 5th, etc.
  }
}

  // Add helper methods if needed...
  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
     SizedBox(height: MediaQuery.of(context).size.height * 0.005),

        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showCustomBottomSheet(BuildContext context, String id) {
  final localization = Provider.of<LocalizationProvider>(context, listen: false);
  
  // Initial Empty Data
  Map<String, String> paymentDetails = {
    'amount': "Loading...",
    'payment_type': "Loading...",
    'date': "Loading...",
    'scheme': "Loading...",
  };

  // BottomSheet వెంటనే ఓపెన్ అవుతుంది
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
     // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // **API Fetch Function**
          Future<void> fetchPayDetails() async {
            final url = Uri.parse('$baseUrl/get_pay_details.php');

            try {
              final response = await http.post(
                url,
                body: {'id': id},
              );

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                  print("Response Data: $data"); // Print the entire response to check
                if (data['status'] == 200) {
                  setState(() {
                    paymentDetails = {
                      'amount': data['amount'] ?? "N/A",
                      'payment_type': data['payment_type'] ?? "N/A",
                      'date': data['date'] ?? "N/A",
                      'scheme': data['scheme'] ?? "N/A",
                    };
                  });
                }
              } else {
                throw Exception('Failed to load payment details');
              }
            } catch (e) {
              print('Error: $e');
            }
          }

          // **API Fetching Start (కోడ్ ఓపెన్ కాగానే ఇది ఓపెన్ అవుతుంది)**
          WidgetsBinding.instance.addPostFrameCallback((_) => fetchPayDetails());

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),

                decoration: const BoxDecoration(
                  color: Colors.green,
                //  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.translate("Payment Successful"),
                          style:  TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,

                          ),
                        ),
                       SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                      ],
                    ),
                     Icon(
                      Icons.check_circle,
                      color: Colors.white,
                     size: MediaQuery.of(context).size.width * 0.1,

                    ),
                  ],
                ),
              ),
              Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),

                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(localization.translate("Installment Amount"), "₹${paymentDetails['amount']}"),
                        _buildDetailItem(localization.translate("Scheme No"), "${paymentDetails['scheme']}"),
                      ],
                    ),
                   SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(localization.translate("Payment Method"), paymentDetails['payment_type'] ?? ""),
                        _buildDetailItem(localization.translate("Transacted on"), paymentDetails['date'] ?? ""),
                      ],
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(43, 49, 101, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      onPressed: () async {
                         print("Second Button Clicked, ID: $id");
                          ReceiptPDFGenerator pdfGenerator = ReceiptPDFGenerator(payId:id);
          await pdfGenerator.generatePDF(context);
                      
                       
                      },
                      icon: const Icon(Icons.download),
                      label: Text(localization.translate("Download Invoice")),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}



String getOrdinalSuffix(int number) {
  if (number % 10 == 1 && number != 11) {
    return '${number}st';
  } else if (number % 10 == 2 && number != 12) {
    return '${number}nd';
  } else if (number % 10 == 3 && number != 13) {
    return '${number}rd';
  } else {
    return '${number}th';
  }
}



IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'processing':
      return Icons.hourglass_top;
    case 'rejected':
      return Icons.cancel;
    case 'completed':
      return Icons.check_circle;
    default:
      return Icons.hourglass_empty;
  }
}

Color getStatusIconColor(String status) {
  final localization = Provider.of<LocalizationProvider>(context);
  switch (status.toLowerCase()) {
    case 'processing':
      return Colors.orange;
    case 'rejected':
      return Colors.red;
    case 'completed':
      return Colors.green;
    default:
        return Colors.orange;
  }
}



}
