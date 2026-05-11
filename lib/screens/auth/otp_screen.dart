import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class OtpScreen extends StatefulWidget {
  final VoidCallback onVerify;
  final VoidCallback onBack;
  const OtpScreen({super.key, required this.onVerify, required this.onBack});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton.filledTonal(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.dark,
                ),
              ),
              const SizedBox(height: 16),
              const Turf11PartnerLogo(markSize: 48, showText: false),
              const SizedBox(height: 14),
              const Text('Verify number',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark)),
              const SizedBox(height: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 14, color: AppColors.muted, height: 1.4),
                  children: [
                    TextSpan(text: 'Enter the 6 digit code sent to '),
                    TextSpan(
                      text: '+91 9876543210',
                      style: TextStyle(
                          color: AppColors.dark, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _otpFields(),
              const SizedBox(height: 18),
              PrimaryButton(label: 'Verify & Enter', onPressed: widget.onVerify),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Resend OTP in 02:00',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpFields() {
    return Row(
      children: List.generate(6, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 5 ? 0 : 8),
            child: SizedBox(
              height: 54,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) {
                    _focusNodes[i + 1].requestFocus();
                  } else if (v.isEmpty && i > 0) {
                    _focusNodes[i - 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}





