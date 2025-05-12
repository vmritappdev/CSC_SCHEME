
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';


class BrochureScreen extends StatelessWidget {
  final String brochureUrl = "https://www.africau.edu/images/default/sample.pdf";

  final String brochureFileName = "gold_brochure.pdf";

 Future<void> checkAndRequestPermissions(BuildContext context) async {
  // ✅ Android 11+ కోసం MANAGE_EXTERNAL_STORAGE Permission చెక్ చేయాలి
  if (await Permission.storage.request().isGranted ||
      await Permission.manageExternalStorage.request().isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Permission Granted ✅")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Permission Denied ❌. Please allow from settings.")),
    );
    openAppSettings(); // ✅ If permanently denied, open settings
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Brochure Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 12, 2, 29),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Asset Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/gold.jpg",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),

            // ✅ Title
            Text(
              "Gold Saving Scheme",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 12, 2, 29)),
            ),
            SizedBox(height: 10),

            // ✅ Description
            Text(
              "Save gold every month and get exclusive benefits!",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),

            // ✅ Terms & Conditions
            Text(
              "Terms & Conditions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 5),
            Text(
              "1. Minimum deposit ₹500 per month.\n2. No withdrawal before 11 months.\n3. 100% Safe & Secure Investment.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),

            // ✅ Download Button
           Center(
  child: ElevatedButton(
    onPressed: () => checkAndRequestPermissions(context),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 12, 2, 29),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Text("Download Brochure", style: TextStyle(fontSize: 16, color: Colors.white)),
  ),
),

          ],
        ),
      ),
    );
  }
}
