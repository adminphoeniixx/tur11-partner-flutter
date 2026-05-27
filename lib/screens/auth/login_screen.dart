import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/input_validators.dart';
import '../../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;
  final String? initialPhone;
  final ValueChanged<String> onOtp;
  final VoidCallback onRegister;
  const LoginScreen({
    super.key,
    required this.authController,
    this.initialPhone,
    required this.onOtp,
    required this.onRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.initialPhone ?? '';
    widget.authController.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    widget.authController.removeListener(_onAuthChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final phoneError = InputValidators.phone(phone);
    if (phoneError != null) {
      setState(() => _phoneError = phoneError);
      return;
    }
    setState(() => _phoneError = null);

    final success = await widget.authController.sendOtp(
      phone: phone,
    );
    if (!mounted) return;

    if (success) {
      widget.onOtp(phone);
    } else {
      _showMessage(widget.authController.errorMessage ?? 'Unable to send OTP.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authController.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onRegister,
                  child: const Text('Register',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              const Turf11PartnerLogo(markSize: 48, showText: false),
              const SizedBox(height: 14),
              const Text('Welcome back',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark)),
              const SizedBox(height: 6),
              const Text('Login to manage turfs, bookings and payouts.',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 18),
              const FieldLabel('Mobile Number'),
              PrefixInput(
                prefix: '+91',
                hint: 'Enter mobile number',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                errorText: _phoneError,
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: isLoading ? 'Sending OTP...' : 'Get OTP',
                onPressed: isLoading ? null : _sendOtp,
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: widget.onRegister,
                  child: const Text('New to Turf11? Register your business',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 18, color: AppColors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Secured OTP login. Turf11 will never ask for your OTP.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.dark, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





