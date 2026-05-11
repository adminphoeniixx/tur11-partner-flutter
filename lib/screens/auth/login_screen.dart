import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onOtp;
  final VoidCallback onRegister;
  const LoginScreen({super.key, required this.onOtp, required this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _roleIndex = 0;

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
              const FieldLabel('Role'),
              ChipSelector(
                options: const ['Turf Owner', 'Organizer', 'Both'],
                selected: _roleIndex,
                onSelected: (i) => setState(() => _roleIndex = i),
              ),
              const SizedBox(height: 18),
              const FieldLabel('Mobile Number'),
              const PrefixInput(
                prefix: '+91',
                hint: 'Enter mobile number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Get OTP', onPressed: widget.onOtp),
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





