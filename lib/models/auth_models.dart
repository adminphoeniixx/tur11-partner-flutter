class SendOtpRequest {
  final String phone;

  const SendOtpRequest({
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone.trim(),
    };
  }
}

class VerifyOtpRequest {
  final String phone;
  final String otp;

  const VerifyOtpRequest({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone.trim(),
      'otp': otp.trim(),
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
  static const String ownerRole = 'both';

  final String firstName;
  final String lastName;
  final String businessName;
  final String phone;
  final String email;
  final String city;
  final String state;
  final List<String> sports;
  final String? gstNumber;

  const RegisterOwnerRequest({
    required this.firstName,
    required this.lastName,
    required this.businessName,
    required this.phone,
    required this.email,
    required this.city,
    required this.state,
    this.sports = const [],
    this.gstNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'business_name': businessName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'city': city.trim(),
      if (state.trim().isNotEmpty) 'state': state.trim(),
      'role': ownerRole,
      if (gstNumber != null && gstNumber!.trim().isNotEmpty)
        'gst_number': gstNumber!.trim(),
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
    );
  }
}

class AuthResponse {
  final String? message;
  final String? token;
  final AuthUser? user;
  final bool? verified;
  final bool? isRegistered;
  final Map<String, dynamic> data;

  const AuthResponse({
    this.message,
    this.token,
    this.user,
    this.verified,
    this.isRegistered,
    this.data = const {},
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final nestedData = _asMap(json['data']);
    final source = nestedData.isEmpty ? json : {...json, ...nestedData};
    final userJson = _firstPresentMap(source, const [
      'user',
      'owner',
      'profile',
      'turf_owner',
      'turfOwner',
      'partner',
    ]);

    return AuthResponse(
      message: source['message']?.toString(),
      token: _firstPresentString(source, const [
        'token',
        'access_token',
        'accessToken',
        'bearer_token',
      ]),
      user: userJson.isEmpty ? null : AuthUser.fromJson(userJson),
      verified: _asBool(source['verified'] ?? source['success']),
      isRegistered: _asBool(source['is_registered'] ?? source['isRegistered']),
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

Map<String, dynamic> _firstPresentMap(
  Map<String, dynamic> source,
  List<String> keys,
) {
  for (final key in keys) {
    final mapped = _asMap(source[key]);
    if (mapped.isNotEmpty) return mapped;
  }
  return {};
}

String? _firstPresentString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value == null) return null;
  return int.tryParse(value.toString());
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value == null) return null;
  final normalized = value.toString().toLowerCase();
  if (normalized == '1' || normalized == 'true' || normalized == 'yes') {
    return true;
  }
  if (normalized == '0' || normalized == 'false' || normalized == 'no') {
    return false;
  }
  return null;
}
