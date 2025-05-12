
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';


class BrochureScreen extends StatelessWidget {
  final String brochureUrl = "https://www.africau.edu/images/default/sample.pdf";

  final String brochureFileName = "gold_brochure.pdf";

  const BrochureScreen({super.key});

 Future<void> checkAndRequestPermissions(BuildContext context) async {
  // ✅ Android 11+ కోసం MANAGE_EXTERNAL_STORAGE Permission చెక్ చేయాలి
  if (await Permission.storage.request().isGranted ||
      await Permission.manageExternalStorage.request().isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permission Granted ✅")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permission Denied ❌. Please allow from settings.")),
    );
    openAppSettings(); // ✅ If permanently denied, open settings
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Brochure Details", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 12, 2, 29),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 20),

            // ✅ Title
            const Text(
              "Gold Saving Scheme",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 12, 2, 29)),
            ),
            const SizedBox(height: 10),

            // ✅ Description
            const Text(
              "Save gold every month and get exclusive benefits!",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // ✅ Terms & Conditions
            const Text(
              "Terms & Conditions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 5),
            const Text(
              "1. Minimum deposit ₹500 per month.\n2. No withdrawal before 11 months.\n3. 100% Safe & Secure Investment.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // ✅ Download Button
           Center(
  child: ElevatedButton(
    onPressed: () => checkAndRequestPermissions(context),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 12, 2, 29),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: const Text("Download Brochure", style: TextStyle(fontSize: 16, color: Colors.white)),
  ),
),

          ],
        ),
      ),
    );
  }
}
