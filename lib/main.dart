import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'screens/auth_screens.dart';
import 'screens/app_shell.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  String _authState = 'splash';

  void _showAuth(String page) {
    setState(() => _authState = page);
  }

  @override
  Widget build(BuildContext context) {
    switch (_authState) {
      case 'splash':
        return SplashScreen(onDone: () => _showAuth('login'));
      case 'login':
        return LoginScreen(
          onOtp: () => _showAuth('otp'),
          onRegister: () => _showAuth('register'),
        );
      case 'otp':
        return OtpScreen(
          onVerify: () => _showAuth('app'),
          onBack: () => _showAuth('login'),
        );
      case 'register':
        return RegisterScreen(
          onContinue: () => _showAuth('otp'),
          onLogin: () => _showAuth('login'),
        );
      case 'app':
        return AppShell(onLogout: () => _showAuth('login'));
      default:
        return LoginScreen(
          onOtp: () => _showAuth('otp'),
          onRegister: () => _showAuth('register'),
        );
    }
  }
}
