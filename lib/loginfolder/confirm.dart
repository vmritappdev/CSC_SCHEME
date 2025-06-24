import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MpinScreen extends StatefulWidget {
  const MpinScreen({super.key});

  @override
  State<MpinScreen> createState() => _MpinScreenState();
}

class _MpinScreenState extends State<MpinScreen> {
  TextEditingController mpinController = TextEditingController();
  TextEditingController confirmMpinController = TextEditingController();

  String? errorText;
  bool isButtonEnabled = false;

  void validateInputs() {
    String mpin = mpinController.text;
    String confirm = confirmMpinController.text;

    if (mpin.length == 4 && confirm.length == 4) {
      if (mpin == confirm) {
        setState(() {
          errorText = null;
          isButtonEnabled = true;
        });
      } else {
        setState(() {
          errorText = "MPIN మరియు Confirm MPIN మెచ్చుకోవడం లేదు.";
          isButtonEnabled = false;
        });
      }
    } else {
      setState(() {
        errorText = null;
        isButtonEnabled = false;
      });
    }
  }

  void onSubmitMpin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("MPIN Successfully Set")),
    );
    // Proceed to next screen or save
  }

  @override
  void initState() {
    super.initState();
    mpinController.addListener(validateInputs);
    confirmMpinController.addListener(validateInputs);
  }

  @override
  void dispose() {
    mpinController.dispose();
    confirmMpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Set MPIN"),
        centerTitle: true,
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              "మీ MPIN ను నమోదు చేయండి",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildPinInputField("MPIN", mpinController),
            const SizedBox(height: 20),
            _buildPinInputField("Confirm MPIN", confirmMpinController),
            const SizedBox(height: 12),
            if (errorText != null)
              Text(
                errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? onSubmitMpin : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: isButtonEnabled ? themeColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "మీ MPIN ని ఎవరితోనూ పంచుకోకండి",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        PinCodeTextField(
          controller: controller,
          appContext: context,
          length: 4,
          obscureText: true,
          obscuringCharacter: '●',
          keyboardType: TextInputType.number,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            fieldHeight: 55,
            fieldWidth: 55,
            activeColor: Colors.teal,
            selectedColor: Colors.teal.shade300,
            inactiveColor: Colors.grey.shade300,
          ),
          onChanged: (_) {},
        ),
      ],
    );
  }
}
