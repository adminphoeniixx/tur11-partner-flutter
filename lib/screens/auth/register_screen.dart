import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../models/auth_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController authController;
  final RegisterOwnerRequest? initialRequest;
  final ValueChanged<RegisterOwnerRequest> onContinue;
  final VoidCallback onLogin;
  const RegisterScreen({
    super.key,
    required this.authController,
    this.initialRequest,
    required this.onContinue,
    required this.onLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _sportsController =
      TextEditingController(text: 'Cricket');
  final TextEditingController _gstController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fillFromInitialRequest();
    widget.authController.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    widget.authController.removeListener(_onAuthChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _sportsController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _fillFromInitialRequest() {
    final request = widget.initialRequest;
    if (request == null) return;

    _firstNameController.text = request.firstName;
    _lastNameController.text = request.lastName;
    _businessNameController.text = request.businessName;
    _phoneController.text = request.phone;
    _emailController.text = request.email;
    _cityController.text = request.city;
    _stateController.text = request.state;
    _sportsController.text = request.sports.join(', ');
    _gstController.text = request.gstNumber ?? '';
  }

  Future<void> _continue() async {
    final request = RegisterOwnerRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      businessName: _businessNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      sports: _sportsController.text
          .split(',')
          .map((sport) => sport.trim())
          .where((sport) => sport.isNotEmpty)
          .toList(),
      gstNumber: _gstController.text.trim(),
    );

    if (request.firstName.isEmpty ||
        request.lastName.isEmpty ||
        request.businessName.isEmpty ||
        request.phone.length < 10 ||
        request.email.isEmpty ||
        request.city.isEmpty) {
      _showMessage('Please fill all required fields.');
      return;
    }

    if (!_isValidEmail(request.email)) {
      _showMessage('Enter a valid email address.');
      return;
    }

    final success = await widget.authController.sendOtp(
      phone: request.phone,
    );
    if (!mounted) return;

    if (success) {
      widget.onContinue(request);
    } else {
      _showMessage(widget.authController.errorMessage ?? 'Unable to send OTP.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
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
              const FieldLabel('First Name'),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(hintText: 'Vikram'),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Last Name'),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(hintText: 'Singh'),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Business / Organization Name'),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                    hintText: 'DLF Sports Arena Pvt. Ltd.'),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Mobile Number'),
              PrefixInput(
                prefix: '+91',
                hint: '9876543210',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
              ),
              const SizedBox(height: 16),
              const FieldLabel('Email Address'),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(hintText: 'vikram@dlfarena.com'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const FieldLabel('City'),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(hintText: 'Gurugram'),
              ),
              const SizedBox(height: 16),
              const FieldLabel('State'),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(hintText: 'Haryana'),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Sports'),
              TextFormField(
                controller: _sportsController,
                decoration: const InputDecoration(hintText: 'Cricket, Football'),
              ),
              const SizedBox(height: 16),
              const FieldLabel('GST Number (optional)'),
              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(hintText: '22AAAAA0000A1Z5'),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: isLoading ? 'Sending OTP...' : 'Continue',
                onPressed: isLoading ? null : _continue,
              ),
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





