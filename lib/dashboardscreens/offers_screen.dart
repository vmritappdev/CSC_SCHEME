import 'package:csc/dashboardscreens/faq_screen.dart';
import 'package:csc/dashboardscreens/home_screen.dart';
import 'package:csc/dashboardscreens/active_scheme.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/model/activescheme.dart';
import 'package:csc/model/offer_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const GoldShopOffersScreen(),
    ),
  );
}

class GoldShopOffersScreen extends StatelessWidget {
  const GoldShopOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double gridItemWidth = screenWidth * 0.45; // Adjust grid item width
    double gridItemHeight = screenHeight * 0.35; // Adjust grid item height
    double imageHeight = screenHeight * 0.22;
    double fontSize = screenWidth * 0.035; // Dynamic font size

    final List<Offer> offers = [
      Offer(
        imagePath: 'assets/images/jewe2.jpg',
        title: localization.translate("Gold Necklace"),
        originalPrice: "",
        discountedPrice: "",
      ),
      Offer(
        imagePath: 'assets/images/nack.jpg',
        title: localization.translate("Gold Ring"),
        originalPrice: "",
        discountedPrice: "",
      ),
      Offer(
        imagePath: 'assets/images/gold1.jpg',
        title: localization.translate("Gold Earrings"),
        originalPrice: "",
        discountedPrice: "",
      ),
      Offer(
        imagePath: 'assets/images/nack1.jpg',
        title: localization.translate("Gold Bracelet"),
        originalPrice: "",
        discountedPrice: "",
      ),
      Offer(
        imagePath: 'assets/images/jewe.jpg',
        title: localization.translate("Gold Pendant"),
        originalPrice: "",
        discountedPrice: "",
      ),
      Offer(
        imagePath: 'assets/images/jewe2.jpg',
        title: localization.translate("Gold Chain"),
        originalPrice: "",
        discountedPrice: "",
      ),
      Offer(
        imagePath: 'assets/images/gold3.jpg',
        title: localization.translate("Gold Set"),
        originalPrice: "",
        discountedPrice: "",
      ),
      Offer(
        imagePath: 'assets/images/gold2.jpg',
        title: localization.translate("Gold Cufflinks"),
        originalPrice: "",
        discountedPrice: "",
      ),
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const BackButton(color: Colors.white),
          title: Text(
            localization.translate("Gold Shop Offers"),
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          backgroundColor: const Color.fromRGBO(2, 5, 62, 1),
        ),
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth < 400 ? 2 : 3, // Small screens 2, large 3
              crossAxisSpacing: screenWidth * 0.02,
              mainAxisSpacing: screenHeight * 0.02,
              childAspectRatio: gridItemWidth / gridItemHeight, 
            ),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.asset(
                        offer.imagePath,
                        fit: BoxFit.cover,
                        height: imageHeight,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        offer.title,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 0.9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            offer.originalPrice,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: fontSize * 0.8,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            offer.discountedPrice,
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize * 0.9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentCard(),
              ),
            );
          },
          label: Text(
            localization.translate("Active Scheme"),
            style: TextStyle(color: Colors.white, fontSize: fontSize * 0.9),
          ),
          backgroundColor: Colors.red,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(2, 5, 62, 1),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: Colors.white, size: fontSize * 2),
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
                    width: fontSize * 2,
                    height: fontSize * 2,
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
}
