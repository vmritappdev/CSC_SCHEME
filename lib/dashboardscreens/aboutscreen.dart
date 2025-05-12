import 'package:csc/dashboardscreens/faq_screen.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/dashboardscreens/saving%20account.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
      final localization = Provider.of<LocalizationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        elevation: 0.5,
        backgroundColor: Color.fromRGBO(2, 5, 67, 1),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
         localization.translate("About Us"),
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
           localization.translate("CHINNI SRINIVASULU CHETTY JEWELLERS"),
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: Colors.teal[700],
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            localization.translate("Est. 1971"),
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          Divider(thickness: 1, height: 32),
          
          //sectionTitle("Our Legacy"),
         

         

           SizedBox(height: 12),

           
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/cscimage.jpg"),
                ),
                SizedBox(height: 10),
                Text(
                   localization.translate("Pavan Srinivas Chinni"),
                  style: GoogleFonts.lato(
                      fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Text(
                  localization.translate("Managing Director"),
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),


SizedBox(height: 15,),

                 sectionText(
             localization.translate("Founded in 1971, Chinni Srinivasulu Chetty Jewellers has built a lasting reputation for trust, tradition, and unmatched quality in the world of fine jewellery. Over the decades, we’ve grown from a humble beginning into a respected name among customers who value not only our exquisite designs but also the genuine relationships we’ve nurtured with them.")),
              ],
            ),
          ),
         SizedBox(height: 12),
          sectionText(
             localization.translate("Under the visionary leadership of Pavan Srinivas Chinni, the business has evolved to meet modern demands while staying true to its heritage. We have expanded our offerings with a perfect blend of tradition and innovation — serving both retail and wholesale jewellery needs.")),

           SizedBox(height: 12),

           sectionText(localization.translate("Our wholesale operations, based in Chennai, Tamil Nadu, supply a wide range of BIS-hallmarked gold ornaments to jewellers across South India. Every piece is crafted with meticulous attention to detail, reflecting timeless craftsmanship and evolving style.")),

           SizedBox(height: 12),

          sectionText(localization.translate("In Nellore, Andhra Pradesh, our flagship retail showroom brings this legacy directly to our valued customers. The store offers an exclusive collection of gold jewellery — from elegant daily wear to breathtaking bridal sets — curated to match every occasion and personality, all at transparent and competitive prices.")),
             
          sectionTitle(localization.translate("Why Choose Us?")),

          bulletPoint(localization.translate("✅ 100% Certified Purity & Premium Quality")),
          bulletPoint(localization.translate("✅ Fair Pricing & Flexible Purchase Schemes")),
          bulletPoint(localization.translate("✅ Lifetime Support & Customer-Centric Service")),

          Divider(thickness: 1, height: 40),
          sectionText(
         localization.translate( "With a team of warm, knowledgeable, and experienced professionals, we are committed to making every visit a personalized, delightful, and memorable jewellery shopping experience.")),
          SizedBox(height: 24),
        ],
      ),


floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => SavingsAccountScreen(),
            )
          );
        },
        label: Text(
          
          localization.translate("Join Scheme"),
          style: GoogleFonts.lato(color: Colors.white,fontSize: 18),
        ),
       // icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(2, 5, 62, 1),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
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
                    MaterialPageRoute(builder: (context) => FAQScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),



    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
        ),
      ),
    );
  }

  Widget sectionText(String content) {
    return Text(
      content,
      style: GoogleFonts.lato(fontSize: 14.5, height: 1.6, color: Colors.black87),
      textAlign: TextAlign.justify,
    );
  }

  Widget iconTextTile(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.lato(fontSize: 15.5, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(subtitle,
                  style: GoogleFonts.lato(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("•", style: TextStyle(fontSize: 18, color: Colors.teal)),
         // Text("✅", style: TextStyle(fontSize: 18, color: Colors.teal)),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
