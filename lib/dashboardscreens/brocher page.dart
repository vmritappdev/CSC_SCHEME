import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BrochureScreen extends StatefulWidget {
  const BrochureScreen({super.key});

  // → తెరవాల్సిన URL
  static const brochureUrl = '$baseUrl/CSC_SCHEME_BROUCHER.pdf';

  @override
  State<BrochureScreen> createState() => _BrochureScreenState();
}

class _BrochureScreenState extends State<BrochureScreen> {
  // URL launch helper
  Future<void> _openBrochureUrl(BuildContext context) async {
    print('🔗 Button clicked → launching ${BrochureScreen.brochureUrl}');
    final uri = Uri.parse(BrochureScreen.brochureUrl);

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) {
        print('[✔] URL launched successfully');
      } else {
        print('[x] Could not launch');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (e) {
      print('[x] launchUrl error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     final localization = Provider.of<LocalizationProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title:  Text(localization.translate('Brochure Details')
          ,style: TextStyle(color: Colors.white,),),
        backgroundColor: const Color(0xFF0C021D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/haram.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
             Text(
             localization.translate('Gold Saving Scheme'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C021D),
              ),
            ),
            const SizedBox(height: 10),
             Text(
              localization.translate('Save gold every month and get exclusive benefits!'),
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
           // const Spacer(),

           SizedBox(height: 50,),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new,color: Colors.white,),
                label:  Text(localization.translate('Open Brochure'),style: TextStyle(color: Colors.white,),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C021D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _openBrochureUrl(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
