import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onLogin;
  const RegisterScreen(
      {super.key, required this.onContinue, required this.onLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                  onPressed: widget.onLogin,
                  child: const Text('Login',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Register business',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark)),
              const SizedBox(height: 6),
              const Text('Create your owner account and start accepting bookings.',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 16),
              _steps(),
              const SizedBox(height: 18),
              const FieldLabel('I am a'),
              ChipSelector(
                options: const ['Turf Owner', 'Organizer', 'Both'],
                selected: _roleIndex,
                onSelected: (i) => setState(() => _roleIndex = i),
              ),
              const SizedBox(height: 18),
              const FieldLabel('First Name'),
              TextFormField(
                  decoration: const InputDecoration(hintText: 'Vikram')),
              const SizedBox(height: 16),
              const FieldLabel('Last Name'),
              TextFormField(decoration: const InputDecoration(hintText: 'Singh')),
              const SizedBox(height: 16),
              const FieldLabel('Business / Organization Name'),
              TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'DLF Sports Arena Pvt. Ltd.')),
              const SizedBox(height: 16),
              const FieldLabel('Mobile Number'),
              const PrefixInput(
                  prefix: '+91',
                  hint: '9876543210',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              const FieldLabel('Email Address'),
              TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'vikram@dlfarena.com'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              const FieldLabel('City'),
              TextFormField(
                  decoration: const InputDecoration(hintText: 'Gurugram')),
              const SizedBox(height: 16),
              const FieldLabel('GST Number (optional)'),
              TextFormField(
                  decoration: const InputDecoration(hintText: '22AAAAA0000A1Z5')),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Continue', onPressed: widget.onContinue),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: widget.onLogin,
                  child: const Text('Already registered? Login',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _steps() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _step('1', 'Account', true),
          Expanded(child: Container(height: 2, color: AppColors.border)),
          _step('2', 'Business', true),
          Expanded(child: Container(height: 2, color: AppColors.border)),
          _step('3', 'Verify', false),
        ],
      ),
    );
  }

  Widget _step(String number, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.green : AppColors.white,
            border: Border.all(
                color: active ? AppColors.green : AppColors.border, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(number,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppColors.muted)),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted)),
      ],
    );
  }
}





