import 'package:csc/chaingedscreens.dart/chainge%20mobile%20.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

/// Premium‑look OTP verification screen matching the provided design screenshot.
///
/// _Usage_
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (_) => const OtpVerificationScreen(maskedPhone: '+XXXXXX7917'),
///   ),
/// );
/// ```
///
/// _Dependencies_
/// ```yaml
/// dependencies:
///   flutter:
///     sdk: flutter
///   pinput: ^3.0.1
/// ```
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.maskedPhone});

  /// The partially‑hidden phone number (e.g. "+XXXXXX7917").
  final String maskedPhone;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpCtrl = TextEditingController();
  final FocusNode _otpFocus = FocusNode();

  @override
  void dispose() {
    _otpCtrl.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    // TODO: Implement verification logic
  }

  void _resendOtp() {
    // TODO: Implement resend logic
  }

  void _changePhone() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: theme.textTheme.titleLarge,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCED0D9), width: 1.4),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF0E0A63), width: 2),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 10,
            spreadRadius: 1,
            color: Color(0x260E0A63), // 15% opacity shadow
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Otp Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).maybePop,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(
              'OTP Verification',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Verification Code Sent to ${widget.maskedPhone}',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MobileScreen()),
        );
      },
      child: Row(
        children: [
          Text(
            ('Change Phone Number'),
            style: GoogleFonts.lato(
              color: const Color(0xFFE55135),
              fontSize: MediaQuery.of(context).size.height * 0.02,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.edit,
            size: 18,
            color: Color(0xFFE55135),
          ),
        ],
      ),
    ),
  ],
),

            const SizedBox(height: 24),
            Pinput(
              length: 6,
              controller: _otpCtrl,
              focusNode: _otpFocus,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              cursor:
                  const Align(alignment: Alignment.bottomCenter, child: SizedBox(width: 2, height: 20, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF0E0A63))))),
            ),
            const SizedBox(height: 32),
            // Gradient button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF0E0A63), Color(0xFF3A2CDA)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Verify OTP',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the OTP?",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _resendOtp,
                  child: Text(
                    'Resend',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
