import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth_controller.dart';
import '../../models/auth_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class OtpScreen extends StatefulWidget {
  final AuthController authController;
  final String phone;
  final RegisterOwnerRequest? pendingRegistration;
  final VoidCallback onVerify;
  final VoidCallback onBack;
  const OtpScreen({
    super.key,
    required this.authController,
    required this.phone,
    this.pendingRegistration,
    required this.onVerify,
    required this.onBack,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    widget.authController.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    widget.authController.removeListener(_onAuthChanged);
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != _controllers.length) {
      _showMessage('Enter the complete OTP.');
      return;
    }

    final pendingRegistration = widget.pendingRegistration;
    final verified = await widget.authController.verifyOtp(
      phone: widget.phone,
      otp: otp,
    );
    final bool success;
    if (pendingRegistration == null) {
      success = verified && widget.authController.isAuthenticated;
    } else {
      success =
          verified && await widget.authController.registerOwner(pendingRegistration);
    }
    if (!mounted) return;

    if (success) {
      widget.onVerify();
    } else {
      _showMessage(
          widget.authController.errorMessage ?? 'OTP verification failed.');
    }
  }

  Future<void> _resendOtp() async {
    final success = await widget.authController.resendOtp(
      phone: widget.phone,
    );
    if (!mounted) return;

    _showMessage(success
        ? 'OTP sent again.'
        : widget.authController.errorMessage ?? 'Unable to resend OTP.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authController.isLoading;
    final phoneText =
        widget.phone.isEmpty ? 'your mobile number' : '+91 ${widget.phone}';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) widget.onBack();
      },
      child: Scaffold(
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
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.muted, height: 1.4),
                    children: [
                      const TextSpan(text: 'Enter the 6 digit code sent to '),
                      TextSpan(
                        text: phoneText,
                        style: const TextStyle(
                            color: AppColors.dark, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _otpFields(),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: isLoading ? 'Verifying...' : 'Verify & Enter',
                  onPressed: isLoading ? null : _verifyOtp,
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : _resendOtp,
                    child: const Text('Resend OTP',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpFields() {
    return Row(
      children: List.generate(_controllers.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == _controllers.length - 1 ? 0 : 8),
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
                  if (v.isNotEmpty && i < _controllers.length - 1) {
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





