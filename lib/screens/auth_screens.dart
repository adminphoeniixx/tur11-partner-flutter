import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// ═══════════════════ LOGIN SCREEN ═══════════════════
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
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Turf',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const Text('11',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green)),
            const SizedBox(width: 6),
            Text('Owner Panel',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          PillButton.ghost('Login', onPressed: () {}),
          const SizedBox(width: 8),
          PillButton(
            label: 'Register',
            onPressed: widget.onRegister,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Turf',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const Text('11',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green)),
                    const SizedBox(width: 4),
                    Text('Owner & Organizer',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Welcome back.',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark)),
                const SizedBox(height: 4),
                const Text('Sign in with your registered mobile number',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 24),
                const FieldLabel('Role'),
                ChipSelector(
                  options: const ['Turf Owner', 'Tournament Organizer', 'Both'],
                  selected: _roleIndex,
                  onSelected: (i) => setState(() => _roleIndex = i),
                ),
                const SizedBox(height: 16),
                const FieldLabel('Mobile Number'),
                PrefixInput(
                    prefix: '🇮🇳 +91',
                    hint: 'Enter your mobile number',
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Get OTP', onPressed: widget.onOtp),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: widget.onRegister,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted),
                        children: [
                          const TextSpan(text: 'New to Turf11? '),
                          TextSpan(
                            text: 'Register your business →',
                            style: const TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.greenLt,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 16, color: AppColors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Secured OTP login · No password required · Turf11 will never ask for your OTP',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.dark, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════ OTP SCREEN ═══════════════════
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
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Turf',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const Text('11',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: AppColors.greenLt,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.smartphone,
                      color: AppColors.green, size: 24),
                ),
                const SizedBox(height: 16),
                const Text('Verify Number',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.muted),
                    children: [
                      const TextSpan(text: 'OTP sent to '),
                      const TextSpan(
                          text: '+91 9876543210',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark)),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'Change',
                        style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 48,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.border, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.border, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.green, width: 2),
                          ),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5)
                            _focusNodes[i + 1].requestFocus();
                          if (v.isEmpty && i > 0)
                            _focusNodes[i - 1].requestFocus();
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                    label: 'Verify & Enter', onPressed: widget.onVerify),
                const SizedBox(height: 14),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.muted),
                      children: [
                        const TextSpan(text: "Didn't receive? "),
                        TextSpan(
                            text: 'Resend OTP',
                            style: const TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w700)),
                        const TextSpan(text: ' · Expires in '),
                        const TextSpan(
                            text: '02:00',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════ REGISTER SCREEN ═══════════════════
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Turf',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark)),
                    const Text('11',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green)),
                    const SizedBox(width: 4),
                    Text('Owner & Organizer',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Register Your Business',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Join Turf11 and start accepting bookings',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 20),
                // Steps
                _buildSteps(),
                const SizedBox(height: 24),
                const FieldLabel('I am a'),
                ChipSelector(
                  options: const ['Turf Owner', 'Tournament Organizer', 'Both'],
                  selected: _roleIndex,
                  onSelected: (i) => setState(() => _roleIndex = i),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const FieldLabel('First Name'),
                          TextFormField(
                              decoration:
                                  const InputDecoration(hintText: 'Vikram')),
                        ])),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const FieldLabel('Last Name'),
                          TextFormField(
                              decoration:
                                  const InputDecoration(hintText: 'Singh')),
                        ])),
                  ],
                ),
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
                    decoration:
                        const InputDecoration(hintText: '22AAAAA0000A1Z5')),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Continue', onPressed: widget.onContinue),
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: widget.onLogin,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                        children: [
                          TextSpan(text: 'Already registered? '),
                          TextSpan(
                              text: 'Login here',
                              style: TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Row(
      children: [
        _stepDot('Account', true, false),
        Expanded(child: Container(height: 2, color: AppColors.border)),
        _stepDot('Business', false, true),
        Expanded(child: Container(height: 2, color: AppColors.border)),
        _stepDot('Verify', false, false),
        Expanded(child: Container(height: 2, color: AppColors.border)),
        _stepDot('Go Live', false, false),
      ],
    );
  }

  Widget _stepDot(String label, bool done, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.green : AppColors.white,
            border: Border.all(
                color: done
                    ? AppColors.green
                    : (active ? AppColors.dark : AppColors.border),
                width: 2),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(active ? '2' : '',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? AppColors.dark : AppColors.muted)),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted)),
      ],
    );
  }
}
