import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'models/app_config_models.dart';
import 'models/auth_models.dart';
import 'screens/auth_screens.dart';
import 'screens/app_shell.dart';
import 'screens/force_update_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_config_service.dart';
import 'widgets/optional_update_dialog.dart';

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
  MaintenanceConfig? _maintenanceConfig;
  UpdateConfig? _forceUpdateConfig;
  UpdateConfig? _pendingOptionalUpdate;
  bool _optionalUpdateShown = false;

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  void _showAuth(String page) {
    setState(() => _authState = page);
    _showOptionalUpdateIfNeeded();
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
    _showOptionalUpdateIfNeeded();
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
    _showOptionalUpdateIfNeeded();
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
    final config = await AppConfigService.checkAppConfig();
    if (!mounted) return;

    if (config?.maintenance?.isActive == true) {
      setState(() {
        _maintenanceConfig = config!.maintenance;
        _authState = 'maintenance';
      });
      return;
    }

    if (config?.update?.isForce == true) {
      setState(() {
        _forceUpdateConfig = config!.update;
        _pendingOptionalUpdate = null;
        _authState = 'forceUpdate';
      });
      return;
    }

    if (config?.update?.isAvailable == true && !_optionalUpdateShown) {
      _pendingOptionalUpdate = config!.update;
    }

    final restored = await _authController.restoreSession();
    if (!mounted) return;

    _showAuth(restored && _authController.isAuthenticated ? 'app' : 'login');
  }

  void _showOptionalUpdateIfNeeded() {
    final update = _pendingOptionalUpdate;
    if (update == null || _optionalUpdateShown) return;
    if (_authState != 'login' && _authState != 'app') return;

    _optionalUpdateShown = true;
    _pendingOptionalUpdate = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showOptionalUpdateDialog(context, update);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authState) {
      case 'splash':
        return SplashScreen(onDone: _completeSplash);
      case 'maintenance':
        return MaintenanceScreen(
          maintenance: _maintenanceConfig ??
              const MaintenanceConfig(
                isActive: true,
                title: 'Under Maintenance',
                message:
                    'We are improving Turf11 Partner. Please try again soon.',
                imageUrl: null,
                estimatedEnd: null,
              ),
          onResolved: _completeSplash,
        );
      case 'forceUpdate':
        return ForceUpdateScreen(
          update: _forceUpdateConfig ??
              const UpdateConfig(
                isAvailable: true,
                isForce: true,
                latestVersion: '',
                minVersion: '',
                title: 'Update Required',
                message: 'Please update Turf11 Partner to continue.',
                imageUrl: null,
                playstoreUrl: null,
                appstoreUrl: null,
                downloadUrl: null,
                updateMode: 'playstore',
                whatsNew: [],
              ),
        );
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
