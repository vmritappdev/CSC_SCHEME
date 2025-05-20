import 'dart:convert'; // Add this import for json.decode
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BillSummaryScreen extends StatefulWidget {
  final String saleId;
  const BillSummaryScreen({super.key, required this.saleId});

  @override
  State<BillSummaryScreen> createState() => _BillSummaryScreenState();
}

class _BillSummaryScreenState extends State<BillSummaryScreen> {
  String productName = '';
  String netWeight = '';
  String grossWeight = '';
  double billAmount = 0.0;
  double schemeAmount = 0.0;
  double cashAmount = 0.0;
  double bankAmount = 0.0;
  String? responseMessage = '';
  String stone = '';

   String? sqlQuery = '';

   

   bool isLoading = false;

 
  @override
  void initState() {
    super.initState();
    fetchSaleDetails(); // Call the API on initialization
  }

  Future<void> fetchSaleDetails() async {
  final url = Uri.parse('$baseUrl/sale_print_api.php');  //'https://vmrdemos.com/csc_scheme/sale_print_api.php'
  try {
    print("Request URL: $url"); // Print the request URL

    final response = await http.post(
      url,
      body: {
        'sale_id': widget.saleId, // Pass saleId to the API
      },
    );

    print("Response Body: ${response.body}");
     

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.isNotEmpty && data[0]['response'] == 'success') {
        setState(() {
          productName = data[0]['product_name'] ?? '';
          netWeight = data[0]['net_wt'] ?? '';
          grossWeight = data[0]['gross'] ?? '';
           stone = data[0]["stone_wt"] ?? '';

          // Safely parse amounts with double.tryParse
          billAmount = _parseAmount(data[0]['bill_amount']);
          schemeAmount = _parseAmount(data[0]['scheme_amount']);
          cashAmount = _parseAmount(data[0]['cash_amount']);
          bankAmount = _parseAmount(data[0]['bank_amount']);
          
        });
      }
    } else {
      throw Exception('Failed to load sale details');
    }
  } catch (e) {
    print("Error fetching sale details: $e");
  }
}


  // Helper function to safely parse amounts
  double _parseAmount(dynamic amount) {
    if (amount == null || amount.toString().isEmpty) {
      return 0.0; // Default to 0.0 if amount is null or empty
    }
    final parsedAmount = double.tryParse(amount.toString());
    if (parsedAmount == null) {
      print('Invalid amount: $amount');
      return 0.0; // Return 0.0 if parsing fails
    }
    return parsedAmount;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 350;
     final localization = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Premium light background
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0A0E21), // Darker premium color
        centerTitle: true,
        elevation: 0,
        title: Text(
          localization.translate('CSC Jewellery'),
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0xFFF9F9FF),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon
                  Row(
                    children: [
                      Icon(Icons.receipt_long,
                          color: const Color(0xFF0A0E21),
                          size: isSmallScreen ? 24 : 28),
                      const SizedBox(width: 10),
                      Text(
                       localization.translate('Bill Summary'),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isSmallScreen ? 24 : 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A0E21),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 20),

                  // Product Details Section
                  _buildSectionTitle(localization.translate('Product Details'), isSmallScreen),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildDetailRow(localization.translate('Product Name'), productName, isSmallScreen),
                  _buildDivider(),
                     _buildDetailRow(localization.translate('Gross Weight'), grossWeight, isSmallScreen),
                       _buildDivider(),
                     _buildDetailRow(localization.translate('Stone'), stone, isSmallScreen), 
                       _buildDivider(),   
                  _buildDetailRow(localization.translate('Net Weight'), netWeight, isSmallScreen),
                  _buildDivider(),
                 // _buildDetailRow('Gross Weight', grossWeight, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),
                  _buildSectionDivider(),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Billing Details Section
                  _buildSectionTitle(localization.translate('Billing Details'), isSmallScreen),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildDetailRow(localization.translate('Bill Amount'),'₹${billAmount.toStringAsFixed(2)}', isSmallScreen, isAmount: true),
                  _buildDivider(),
                  _buildDetailRow(localization.translate('Scheme Amount'), '₹${schemeAmount.toStringAsFixed(2)}', isSmallScreen, isAmount: true),
                  _buildDivider(),
                  _buildDetailRow(localization.translate('Cash Amount'), '₹${cashAmount.toStringAsFixed(2)}', isSmallScreen, isAmount: true),
                  _buildDivider(),
                  _buildDetailRow(localization.translate('Bank Amount'), '₹${bankAmount.toStringAsFixed(2)}', isSmallScreen, isAmount: true),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Total Amount
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E21).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                         localization.translate('Total Amount'),
                          style: GoogleFonts.lato(
                            fontSize: isSmallScreen ? 13 : 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A0E21),
                          ),
                        ),
                        Text(
                          '₹${(billAmount).toStringAsFixed(2)}',
                          style: GoogleFonts.lato(
                            fontSize: isSmallScreen ? 14 : 14,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0A0E21),
                          ),
                        ),


                        
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 20),



Center(
  child: ElevatedButton.icon(
    onPressed: () async {
      final Uri url = Uri.parse('$baseUrl/sale_print.php?id=${widget.saleId}');
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.inAppWebView, // 👈 try this mode
      );
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch download link')),
        );
      }
    },
    icon: const Icon(Icons.download),
    label:  Text(localization.translate('Download Sale Invoice')),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0A0E21),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isSmallScreen) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: isSmallScreen ? 15 : 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0A0E21),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isSmallScreen, {bool isAmount = false}) {
      final localization = Provider.of<LocalizationProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: isSmallScreen ? 12 : 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: isSmallScreen ? (isAmount ? 13 : 11) : (isAmount ? 13 : 13),
              fontWeight: isAmount ? FontWeight.w800 : FontWeight.w600,
              color: isAmount ? const Color(0xFF0A0E21) : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 8,
      thickness: 0.5,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildSectionDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade400,
      indent: 20,
      endIndent: 20,
    );
  }
}
