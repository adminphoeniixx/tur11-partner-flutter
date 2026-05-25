import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'models/auth_models.dart';
import 'screens/auth_screens.dart';
import 'screens/app_shell.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Turf11App());
}

class Turf11App extends StatelessWidget {
  const Turf11App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turf11 Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const Turf11Root(),
    );
  }
}

class Turf11Root extends StatefulWidget {
  const Turf11Root({super.key});

  @override
  State<Turf11Root> createState() => _Turf11RootState();
}

class _Turf11RootState extends State<Turf11Root> {
  final AuthController _authController = AuthController();
  String _authState = 'splash';
  String _otpSource = 'login';
  String? _otpPhone;
  RegisterOwnerRequest? _pendingRegistration;

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  void _showAuth(String page) {
    setState(() => _authState = page);
  }

  void _showOtp(String phone, {RegisterOwnerRequest? registration}) {
    setState(() {
      _otpPhone = phone;
      _pendingRegistration = registration;
      _otpSource = registration == null ? 'login' : 'register';
      _authState = 'otp';
    });
  }

  void _backFromOtp() {
    setState(() {
      _authState = _otpSource == 'register' ? 'register' : 'login';
    });
  }

  void _showLogin() {
    setState(() {
      _otpPhone = null;
      _pendingRegistration = null;
      _otpSource = 'login';
      _authState = 'login';
    });
  }

  void _showRegister() {
    setState(() {
      _otpPhone = null;
      _otpSource = 'register';
      _authState = 'register';
    });
  }

  void _showApp() {
    setState(() {
      _otpPhone = null;
      _pendingRegistration = null;
      _otpSource = 'login';
      _authState = 'app';
    });
  }

  void _logout() {
    _authController.logout().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _otpPhone = null;
        _pendingRegistration = null;
        _otpSource = 'login';
        _authState = 'login';
      });
    });
  }

  Future<void> _completeSplash() async {
    final restored = await _authController.restoreSession();
    if (!mounted) return;

    _showAuth(restored && _authController.isAuthenticated ? 'app' : 'login');
  }

  @override
  Widget build(BuildContext context) {
    switch (_authState) {
      case 'splash':
        return SplashScreen(onDone: _completeSplash);
      case 'login':
        return LoginScreen(
          authController: _authController,
          initialPhone: _otpSource == 'login' ? _otpPhone : null,
          onOtp: (phone) => _showOtp(phone),
          onRegister: _showRegister,
        );
      case 'otp':
        return OtpScreen(
          authController: _authController,
          phone: _otpPhone ?? '',
          pendingRegistration: _pendingRegistration,
          onVerify: _showApp,
          onBack: _backFromOtp,
        );
      case 'register':
        return RegisterScreen(
          authController: _authController,
          initialRequest: _pendingRegistration,
          onContinue: (registration) => _showOtp(
            registration.phone,
            registration: registration,
          ),
          onLogin: _showLogin,
        );
      case 'app':
        return AppShell(onLogout: _logout);
      default:
        return LoginScreen(
          authController: _authController,
          initialPhone: _otpSource == 'login' ? _otpPhone : null,
          onOtp: (phone) => _showOtp(phone),
          onRegister: _showRegister,
        );
    }
  }
}
