import 'dart:io';

import 'package:csc/chaingedscreens.dart/errorscreen.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:csc/utillity/check%20internet.dart';
import 'package:csc/utillity/constant.dart';
import 'package:csc/utillity/constantcolor.dart';
import 'package:csc/utillity/netmix.dart';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class BrochureScreen extends StatefulWidget {
  const BrochureScreen({super.key});

  static const brochureUrl = '$baseUrl/CSC_SCHEME_BROUCHER.pdf';

  @override
  State<BrochureScreen> createState() => _BrochureScreenState();
}

class _BrochureScreenState extends State<BrochureScreen> with NetworkMixin {
  bool isDownloading = false;

 Future<void> _downloadBrochure(BuildContext context) async {
    bool hasInternet = await checkInternet();
  if (!hasInternet) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ErrorScreen()),
      );
    }
    return;
  }

  setState(() {
    isDownloading = true;
  });

  try {
    final Directory dir;

    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = '${dir.path}/CSC_SCHEME_BROUCHER.pdf';
    final dio = Dio();
    final response = await dio.download(BrochureScreen.brochureUrl, filePath);

    if (response.statusCode == 200) {
      await OpenFile.open(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download failed')),
      );
    }
  } catch (e) {
    print('Download error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download failed: $e')),
    );
  } finally {
    setState(() {
      isDownloading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
       final localization = Provider.of<LocalizationProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title:  Text(localization.translate('Brochure'),
        style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.blue,
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

            SizedBox(height: 50,),
            Center(



              child: ElevatedButton.icon(
                icon: isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                        ),
                      )
                    : const Icon(Icons.download, color: Colors.white),
                label:  Text(
                 localization.translate('Download Brochure'),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: isDownloading ? null : () => _downloadBrochure(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  
}
