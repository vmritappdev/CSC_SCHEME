import 'dart:io';
import 'dart:convert';
import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class ReceiptPDFGenerator {
  final String payId;
  static const PdfColor textColor = PdfColor.fromInt(0xCC000000); // 0xCC = 80% opacity


  ReceiptPDFGenerator({required this.payId});

  Future<Map<String, String>> fetchReceiptDetails() async {
    final url = Uri.parse('$baseUrl/get_receipt.php');  //'https://vmrdemos.com/csc_scheme/get_receipt.php'

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': payId, 'pay_id': payId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          return {
            'amount': data['amount'] ?? "Unknown",
            'payment_type': data['payment_type'] ?? "Unknown",
            'date': data['date'] ?? "Unknown",
            'scheme': data['scheme'] ?? "Unknown",
            'time': data['time'] ?? "Unknown",
            'transaction_no': data['transaction_no'] ?? "Unknown",
            'installment_no': data['installment_no'] ?? "Unknown",
            'receipt_no': data['receipt_no'] ?? "Unknown",
            'name': data['name'] ?? "Unknown",
            'address': data['address'] ?? "Unknown",
            'mobile_no': data['mobile_no'] ?? "Unknown",
            'c_name': data['c_name'] ?? "Unknown",
            'c_city': data['c_city'] ?? "Unknown",
            'c_pin': data['c_pin'] ?? "Unknown",
            'c_state': data['c_state'] ?? "Unknown",
            'c_phone': data['c_phone'] ?? "Unknown",
          };
        } else {
          throw Exception('Failed to load data: ${data['message']}');
        }
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching receipt details: $e');
    }
  }

  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/cs.png')).buffer.asUint8List(),
    );

    final data = await fetchReceiptDetails();

    // Premium color scheme
    const primaryColor = PdfColor.fromInt(0xFF2C3E50); // Dark blue
    const accentColor = PdfColor.fromInt(0xFFE74C3C); // Red
    const secondaryColor = PdfColor.fromInt(0xFFF5F7FA); // Light grey
    const textColor = PdfColor.fromInt(0xFF34495E); // Dark grey-blue
    const highlightColor = PdfColor.fromInt(0xFF3498DB); // Blue

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: pw.BorderRadius.circular(12),
              gradient: const pw.LinearGradient(
                colors: [PdfColors.white, secondaryColor],
                begin: pw.Alignment.topCenter,
                end: pw.Alignment.bottomCenter,
              ),
            ),
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                /// Premium Header with Watermark Effect
                pw.Stack(
                  children: [
                    pw.Positioned(
                      right: 0,
                      child: pw.Opacity(
                        opacity: 0.1,
                        child: pw.Text("PAID",
                            style: pw.TextStyle(
                              fontSize: 72,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                            )),
                      ),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Image(logo, width: 70, height: 70),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("CSC JEWELLERY",
                                style: pw.TextStyle(
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                )),
                            pw.Text("Advanced Gold Purchased Plan",
                                style: const pw.TextStyle(
                                  fontSize: 12,
                                  color: accentColor,
                                  letterSpacing: 1.2,
                                )),
                          ],
                        )
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                /// Company Info with Elegant Styling
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                    boxShadow: const [
                      pw.BoxShadow(
                        color: PdfColors.grey300,
                        blurRadius: 2,
                       // offset: pw.Offset(0, 1),
                      )
                    ],
                    border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(data['c_name'] ?? "",
                          style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor)),
                      pw.Text(
                          "${data['c_city']}, ${data['c_state']} - ${data['c_pin']}",
                          style: const pw.TextStyle(fontSize: 10, color: textColor)),
                      pw.Text("Phone: ${data['c_phone']}", 
                          style: const pw.TextStyle(fontSize: 10, color: textColor)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),

                /// Receipt Title with Decorative Elements
                pw.Stack(
                  children: [
                    pw.Positioned.fill(
                      child: pw.Divider(
                        thickness: 1,
                        color: PdfColors.grey300,
                      ),
                    ),
                    pw.Center(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                        decoration: pw.BoxDecoration(
                          color: secondaryColor,
                          borderRadius: pw.BorderRadius.circular(20),
                          border: pw.Border.all(color: accentColor, width: 0.5),
                        ),
                        child: pw.Text("PAYMENT RECEIPT",
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                              letterSpacing: 1.5,
                            )),
                      ),
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 24),

                /// Receipt Details in Elegant Layout
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                    boxShadow: const [
                      pw.BoxShadow(
                        color: PdfColors.grey200,
                        blurRadius: 3,
                       // offset: pw.Offset(0, 2),
                      )
                    ],
                  ),
                  child: pw.Column(
                    children: [
                      _premiumEntryRow("Date", "${data['date']} ${data['time']}", true),
                      _premiumDivider(),
                      _premiumEntryRow("Customer Name", data['name']!),
                      _premiumDivider(),
                      _premiumEntryRow("Scheme NO", data['scheme']!),
                      _premiumDivider(),
                      _premiumEntryRow("Location", data['address']!),
                      _premiumDivider(),
                      _premiumEntryRow("Installment No", data['installment_no']!),
                      _premiumDivider(),
                      _premiumEntryRow("Receipt No.", data['receipt_no']!),
                      _premiumDivider(),
                     // _premiumEntryRow("Amount", "₹${data['amount']}!", true, ),
                      _premiumEntryRow("Amount", data['amount']!),
                      
                      _premiumDivider(),
                      _premiumEntryRow("Payment Mode", data['payment_type']!),
                    ],
                  ),
                ),

                pw.SizedBox(height: 32),

                /// Signature Area with Thank You Note
                pw.Container(
  width: double.infinity,
  padding: const pw.EdgeInsets.symmetric(vertical: 10),
  child: pw.Column(
    children: [
      // Background color only for "Thank you" text
      pw.Container(
         color: primaryColor,// Background color for "Thank you"
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        child: pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Thank you for your payment',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white,),
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      // "Authorized Signature" without background color, right aligned
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Authorized Signature',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ),
    ],
  ),
),

              ],
            ),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/premium_receipt.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

 pw.Widget _premiumEntryRow(String label, String value,
    [bool highlight = false, PdfColor? customColor]) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Label with fixed width
        pw.Container(
          width: 130, // same for all labels
          child: pw.Text(
            label,
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF7F8C8D),
            ),
          ),
        ),

        // Value with fixed width, also left-aligned
        pw.Container(
          width: 130, // same width as labels, but on right side
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.left, // 👈 this is key
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight:
                  highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: customColor ?? textColor,
            ),
          ),
        ),
      ],
    ),
  );
}


  pw.Widget _premiumDivider() {
    return pw.Divider(
      thickness: 0.5,
      color: PdfColors.grey200,
      height: 12,
    );
  }
}





/*

 import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class ReceiptPDFGenerator {
  final String payId;

  ReceiptPDFGenerator({required this.payId});


  

  Future<Map<String, String>> fetchReceiptDetails() async {
    final url = Uri.parse('https://vmrdemos.com/csc_scheme/get_receipt.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': payId, 'pay_id': payId},
      );

      print("✅ API Response Body: ${response.body}"); // ← ఇది చాలు!

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200) {
          return {
            'amount': data['amount'] ?? "Unknown",
            'payment_type': data['payment_type'] ?? "Unknown",
            'date': data['date'] ?? "Unknown",
            'scheme': data['scheme'] ?? "Unknown",
            'time': data['time'] ?? "Unknown",
            'transaction_no': data['transaction_no'] ?? "Unknown",
            'installment_no': data['installment_no'] ?? "Unknown",
            'receipt_no': data['receipt_no'] ?? "Unknown",
            'name': data['name'] ?? "Unknown",
            'address': data['address'] ?? "Unknown",
            'mobile_no': data['mobile_no'] ?? "Unknown",
            'c_name': data['c_name'] ?? "Unknown",
            'c_city': data['c_city'] ?? "Unknown",
            'c_pin': data['c_pin'] ?? "Unknown",
            'c_state': data['c_state'] ?? "Unknown",
            'c_phone': data['c_phone'] ?? "Unknown",
          };
        } else {
          throw Exception('Failed to load data: ${data['message']}');
        }
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching receipt details: $e');
    }
  }



  

  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/cs.png')).buffer.asUint8List(),
    );

    final data = await fetchReceiptDetails();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                /// Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logo, width: 60, height: 60),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("CSCJEWELLERYS",
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            )),
                        pw.Text("Jewellery Purchase Plan",
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            )),
                      ],
                    )
                  ],
                ),

                pw.SizedBox(height: 8),

                /// Company Info
                pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(data['c_name'] ?? "",
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black)),
                      pw.Text(
                          "${data['c_city']}, ${data['c_state']} - ${data['c_pin']}",
                          style: pw.TextStyle(fontSize: 9)),
                      pw.Text("Phone: ${data['c_phone']}", style: pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                /// Receipt Title
                pw.Center(
                  child: pw.Text("RECEIPT",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber800,
                      )),
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 12),

                /// Receipt Details
                _entryRow("Date", "${data['date']} ${data['time']}", true),
                _entryRow("Scheme NO", data['scheme']!),
                _entryRow("Name", data['name']!),
                _entryRow("Location", data['address']!),
                _entryRow("Installment No", data['installment_no']!),
                _entryRow("Receipt No.", data['receipt_no']!),
                _entryRow("Amount", data['amount']!),
                _entryRow("Mode of Payment", data['payment_type']!),

                pw.SizedBox(height: 24),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 8),

                /// Footer
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text("Thank you for your payment!",
                      style: pw.TextStyle(
                        fontSize: 15,
                        color: PdfColors.blue900,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
              ],
            ),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  pw.Widget _entryRow(String label, String value, [bool highlight = false]) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.black,
              )),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize: 10,
                color: highlight ? PdfColors.blue900 : PdfColors.black,
              )),
        ],
      ),
    );
  }
}

*/