import '../core/api_constants.dart';
import '../models/auth_models.dart';
import '../core/api_client.dart';

class AuthService {
  Future<AuthResponse> sendOtp(SendOtpRequest request) {
    return _post(
      ApiConstants.sendOtp,
      body: request.toJson(),
    );
  }

  Future<AuthResponse> resendOtp(ResendOtpRequest request) {
    return _post(
      ApiConstants.resendOtp,
      body: request.toJson(),
    );
  }

  Future<AuthResponse> login(LoginRequest request) {
    return _post(
      ApiConstants.login,
      body: request.toJson(),
    );
  }

  Future<AuthResponse> register(RegisterOwnerRequest request) {
    return _post(
      ApiConstants.register,
      body: request.toJson(),
    );
  }

  Future<AuthResponse> logout() {
    return _post(ApiConstants.logout);
  }

  Future<AuthResponse> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await ApiClient.post(path, data: body);
    final responseBody = _asMap(response.data);
    return AuthResponse.fromJson(responseBody);
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {'data': value};
  }
}
