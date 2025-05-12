
import 'package:csc/localization/localizationpro.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const FAQScreen(),
    ),
  );
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int expandedIndex = -1; // Tracks the currently expanded FAQ index
  String searchQuery = ''; // Holds the search query

  void _openWhatsApp() async {
    const String phoneNumber = "9490657008"; // ✅ Default number
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');

    if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri);
    } else {
    print("Could not open WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

   

    final localization = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      appBar:  AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          localization.translate("FAQ"),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: const Color.fromRGBO(2, 5, 67, 1),
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // ✅ Dynamic Padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.translate("Frequently asked questions"),
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.05, // ✅ Dynamic Font Size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // ✅ Dynamic Spacing

              SizedBox(
                height: screenHeight * 0.06, // ✅ Dynamic Height
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase(); // Update search query
                    });
                  },
                  decoration: InputDecoration(
                    hintText: localization.translate("Ask me anything"),
                    hintStyle: GoogleFonts.lato(
                      fontSize: screenWidth * 0.04, // ✅ Dynamic Font Size
                      color: const Color.fromARGB(255, 176, 175, 175),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: screenWidth * 0.06, // ✅ Dynamic Icon Size
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                      color: Color.fromARGB(255, 242, 240, 240),
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02), 
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02), // ✅ Dynamic Spacing

              ..._buildFAQList(localization),

              SizedBox(height: screenHeight * 0.02), // ✅ Dynamic Spacing

              Center(
                child: SizedBox(
                  height: screenHeight * 0.06, // ✅ Dynamic Button Height
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openWhatsApp,
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02), // ✅ Dynamic Border Radius
                      ),
                    ),
                    child: Text(
                      localization.translate("Chat with us"),
                      style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.045, // ✅ Dynamic Font Size
                      color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFAQList(LocalizationProvider localization) {
    final faqs = [
      {
        "question": localization.translate("Will the cash be refunded?"),
        "answer": localization.translate("No, the cash will not be refunded under any circumstances, as per government regulations."),
      },
      {
        "question": localization.translate("How do I pay the monthly advance payment?"),
        "answer": localization.translate("You must make the monthly advance payment by the 10th of every month. Payments can be made via Cash, UPI, or Demand Draft in favor of “CSC Jewellers.” You may also use the CSC Jewellers Mobile App for online payments."),
      },
      {
        "question": localization.translate("What if I discontinue?"),
        "answer": localization.translate("Within 6 months: No discount on wastage (VA) will be provided.\n 7th or 8th month: 30% discount on wastage (VA), applicable only if VA is up to 18% and limitedto the accumulated value.\n9th month: 40% discount on VA (up to 18%), limited to the accumulated value.\n10th month: 50% discount on VA (up to 18%), limited to the accumulated gold value. "),
      },
      {
        "question": localization.translate("What if I do not pay continuously?"),
        "answer": localization.translate("To qualify for zero wastage (VA), all monthly payments must be made continuously. Any missed payment will result in discontinuation of the plan."),
      },
      {
        "question": localization.translate("What if I purchase jewelry exceeding the accumulated amount?"),
        "answer": localization.translate("If your purchase exceeds the accumulated amount, the applicable wastage (VA) and other charges on the excess portion must be paid at the time of purchase."),
      },
      {
        "question": localization.translate("Can I purchase gold coins?"),
        "answer": localization.translate("Yes, you can purchase gold coins without wastage (VA) or making charges."),
      },
      {
        "question": localization.translate("What will happen after the completion of the plan period?"),
        "answer": localization.translate("Upon completing 11 months from your enrollment date, you can purchase gold jewelry of your choice with zero wastage (VA) up to 18%, limited to your accumulated value."),
      },
      {
        "question": localization.translate("Can this plan be combined with other offers?"),
        "answer": localization.translate("No, this plan is unique and cannot be combined with any other existing schemes or offers."),
      },
      {
        "question": localization.translate("Will wastage (VA) be charged on special items?"),
        "answer": localization.translate("Yes, wastage (VA) will be charged on special items like ethnic jewelry, vintage jewelry, pooja items, silver articles, silver jewelry, and other special items not included in this estimate. Charges for precious stones, semi-precious stones, zircon, birthstones, and other stones will also apply. If a member wishes to purchase any of these items, they may contact the showroom for details."),
      },
      {
        "question": localization.translate("How do I know the amount accumulated?"),
        "answer": localization.translate("The accumulated amount will be updated in your customer receipt book or mobile app on a monthly basis at the time of making the advance payment."),
      },
      {
        "question": localization.translate("Can I make all the monthly payments in advance?"),
        "answer": localization.translate("No, monthly payments cannot be carried over or paid in advance."),
      },
      {
        "question": localization.translate("Can I make the advance monthly payments in CSC showrooms?"),
        "answer": localization.translate("Yes, as of now, we have only one branch located in Nellore. You can make the monthly advance payments at the CSC showroom in Nellore or through the CSC Jewellers mobile app, available on the Play Store and the Apple Store."),
      },
      {
        "question": localization.translate("Can I purchase special items like ethnic and vintage jewelry and pooja items?"),
        "answer": localization.translate("Yes, you can purchase special items with applicable wastage (VA) and making charges."),
      },
      {
        "question": localization.translate("Can I purchase watches in this plan?"),
        "answer": localization.translate("No, this plan does not include eligibility for purchasing watches."),
      },
      {
        "question": localization.translate("Is the monthly advance amount fixed or variable?"),
        "answer": localization.translate("The monthly advance payment amount is fixed."),
      },
    ];

    // Filter the FAQ list based on the search query
    final filteredFaqs = faqs.where((faq) {
      return faq["question"]!.toLowerCase().contains(searchQuery) ||
             faq["answer"]!.toLowerCase().contains(searchQuery);
    }).toList();

    // Generate FAQ items
    return List.generate(filteredFaqs.length, (index) {
      return Column(
        children: [
          _buildFAQItem(
            filteredFaqs[index]["question"]!,
            filteredFaqs[index]["answer"]!,
            index == expandedIndex,
            () {
              setState(() {
                expandedIndex = index == expandedIndex ? -1 : index;
              });
            },
            context
          ),
          const Divider(),
          const SizedBox(height: 20),
        ],
      );
    });
  }

  Widget _buildFAQItem(String question, String answer, bool isExpanded, VoidCallback onTap, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.04, // ✅ Dynamic Font Size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.black,
                size: screenWidth * 0.06, // ✅ Dynamic Icon Size
              ),
            ],
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01), // ✅ Dynamic Padding
              child: Text(
                answer,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035, // ✅ Dynamic Font Size
                  color: Colors.grey[800],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
