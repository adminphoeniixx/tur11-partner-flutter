import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../core/storage_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  AuthUser? _user;
  AuthResponse? _lastResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  AuthUser? get user => _user;
  AuthResponse? get lastResponse => _lastResponse;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<bool> restoreSession() {
    return _run(() async {
      final savedToken = await StorageService.getToken();
      if (savedToken == null || savedToken.trim().isEmpty) {
        _token = null;
        _user = null;
        return;
      }

      _token = savedToken.trim();
    });
  }

  Future<bool> sendOtp({
    required String phone,
  }) {
    return _run(() async {
      _lastResponse = await _authService.sendOtp(
        SendOtpRequest(phone: phone),
      );
    });
  }

  Future<bool> resendOtp({
    required String phone,
  }) {
    return _run(() async {
      _lastResponse = await _authService.resendOtp(
        ResendOtpRequest(phone: phone),
      );
    });
  }

  Future<bool> login({
    required String phone,
    required String otp,
  }) {
    return _run(() async {
      final response = await _authService.verifyOtp(
        VerifyOtpRequest(phone: phone, otp: otp),
      );
      await _setSession(response);
    });
  }

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _run(() async {
      final response = await _authService.verifyOtp(
        VerifyOtpRequest(phone: phone, otp: otp),
      );
      _lastResponse = response;
      if (response.verified != true) {
        throw ApiException(response.message ?? 'OTP verification failed.');
      }
      if (response.token != null && response.token!.trim().isNotEmpty) {
        await _setSession(response);
      }
    });
  }

  Future<bool> registerOwner(RegisterOwnerRequest request) {
    return _run(() async {
      final response = await _authService.register(request);
      await _setSession(response);
    });
  }

  Future<bool> logout() {
    return _run(() async {
      final activeToken = _token;
      try {
        if (activeToken != null && activeToken.isNotEmpty) {
          _lastResponse = await _authService.logout();
        }
      } finally {
        await StorageService.clear();
        _token = null;
        _user = null;
      }
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _setSession(AuthResponse response) async {
    _lastResponse = response;
    final token = response.token?.trim();
    if (token == null || token.isEmpty) {
      throw const ApiException('Login successful, but token was not returned.');
    }

    await StorageService.saveToken(token);
    _token = token;
    _user = response.user;
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
