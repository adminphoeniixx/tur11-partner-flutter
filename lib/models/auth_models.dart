class SendOtpRequest {
  static const String ownerRole = 'turf_owner';

  final String phone;

  const SendOtpRequest({
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone.trim(),
      'role': ownerRole,
    };
  }
}

class LoginRequest {
  final String phone;
  final String otp;

  const LoginRequest({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }
}

class ResendOtpRequest {
  final String phone;

  const ResendOtpRequest({
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone.trim(),
    };
  }
}

class RegisterOwnerRequest {
  static const String ownerRole = 'turf_owner';

  final String firstName;
  final String lastName;
  final String businessName;
  final String phone;
  final String email;
  final String city;
  final String state;
  final List<String> sports;
  final String? gstNumber;
  final String otp;

  const RegisterOwnerRequest({
    required this.firstName,
    required this.lastName,
    required this.businessName,
    required this.phone,
    required this.email,
    required this.city,
    required this.state,
    required this.sports,
    this.gstNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    final fullName = [firstName.trim(), lastName.trim()]
        .where((part) => part.isNotEmpty)
        .join(' ');

    return {
      'name': fullName,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'business_name': businessName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'sports': sports,
      'role': ownerRole,
      if (gstNumber != null && gstNumber!.trim().isNotEmpty)
        'gst_number': gstNumber!.trim(),
      'otp': otp.trim(),
    };
  }

  RegisterOwnerRequest copyWith({
    String? firstName,
    String? lastName,
    String? businessName,
    String? phone,
    String? email,
    String? city,
    String? state,
    List<String>? sports,
    String? gstNumber,
    String? otp,
  }) {
    return RegisterOwnerRequest(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      state: state ?? this.state,
      sports: sports ?? this.sports,
      gstNumber: gstNumber ?? this.gstNumber,
      otp: otp ?? this.otp,
    );
  }
}

class AuthResponse {
  final String? message;
  final String? token;
  final AuthUser? user;
  final Map<String, dynamic> data;

  const AuthResponse({
    this.message,
    this.token,
    this.user,
    this.data = const {},
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final nestedData = _asMap(json['data']);
    final source = nestedData.isEmpty ? json : {...json, ...nestedData};
    final userJson = _asMap(source['user']);

    return AuthResponse(
      message: source['message']?.toString(),
      token: source['token']?.toString(),
      user: userJson.isEmpty ? null : AuthUser.fromJson(userJson),
      data: json,
    );
  }
}

class AuthUser {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? businessName;
  final String? phone;
  final String? email;
  final String? city;
  final String? state;
  final String? role;
  final String? gstNumber;
  final Map<String, dynamic> data;

  const AuthUser({
    this.id,
    this.firstName,
    this.lastName,
    this.businessName,
    this.phone,
    this.email,
    this.city,
    this.state,
    this.role,
    this.gstNumber,
    this.data = const {},
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: _asInt(json['id']),
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      businessName:
          json['business_name']?.toString() ?? json['businessName']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      role: json['role']?.toString(),
      gstNumber: json['gst_number']?.toString() ?? json['gstNumber']?.toString(),
      data: json,
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value == null) return null;
  return int.tryParse(value.toString());
}
