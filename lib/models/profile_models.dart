class OwnerProfile {
  final int? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? businessName;
  final String? phone;
  final String? email;
  final String? city;
  final String? state;
  final String? role;
  final String? gstNumber;
  final String? panNumber;
  final bool? isVerified;
  final BankDetails? bankDetails;
  final Map<String, dynamic> data;

  const OwnerProfile({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.businessName,
    this.phone,
    this.email,
    this.city,
    this.state,
    this.role,
    this.gstNumber,
    this.panNumber,
    this.isVerified,
    this.bankDetails,
    this.data = const {},
  });

  String get displayName {
    final explicit = name?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final combined = [
      firstName?.trim(),
      lastName?.trim(),
    ].where((part) => part != null && part.isNotEmpty).join(' ');

    return combined.isEmpty ? 'Owner' : combined;
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'TO';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    final bankJson = _asMap(
      json['bank_details'] ??
          json['bankDetails'] ??
          json['bank'] ??
          json['bank_detail'] ??
          json['bankDetail'],
    );

    return OwnerProfile(
      id: _asInt(json['id']),
      name: json['name']?.toString() ??
          json['owner_name']?.toString() ??
          json['ownerName']?.toString(),
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      businessName:
          json['business_name']?.toString() ??
          json['businessName']?.toString() ??
          json['company_name']?.toString() ??
          json['companyName']?.toString(),
      phone: json['phone']?.toString() ?? json['mobile']?.toString(),
      email: json['email']?.toString(),
      city: json['city']?.toString() ?? _asMap(json['address'])['city']?.toString(),
      state:
          json['state']?.toString() ?? _asMap(json['address'])['state']?.toString(),
      role: json['role']?.toString(),
      gstNumber: json['gst_number']?.toString() ?? json['gstNumber']?.toString(),
      panNumber: json['pan_number']?.toString() ?? json['panNumber']?.toString(),
      isVerified: _asBool(json['is_verified'] ?? json['isVerified']),
      bankDetails: bankJson.isEmpty ? null : BankDetails.fromJson(bankJson),
      data: json,
    );
  }
}

class UpdateProfileRequest {
  final String name;
  final String businessName;
  final String email;
  final String city;

  const UpdateProfileRequest({
    required this.name,
    required this.businessName,
    required this.email,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'business_name': businessName.trim(),
      'email': email.trim(),
      'city': city.trim(),
    };
  }
}

class UpdateFcmTokenRequest {
  final String fcmToken;

  const UpdateFcmTokenRequest({required this.fcmToken});

  Map<String, dynamic> toJson() {
    return {'fcm_token': fcmToken.trim()};
  }
}

class BankDetails {
  final String? accountNumber;
  final String? bankName;
  final String? ifsc;
  final String? upiId;
  final String? accountHolder;
  final Map<String, dynamic> data;

  const BankDetails({
    this.accountNumber,
    this.bankName,
    this.ifsc,
    this.upiId,
    this.accountHolder,
    this.data = const {},
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountNumber:
          json['account_number']?.toString() ?? json['accountNumber']?.toString(),
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString(),
      ifsc: json['ifsc']?.toString(),
      upiId: json['upi_id']?.toString() ?? json['upiId']?.toString(),
      accountHolder:
          json['account_holder']?.toString() ?? json['accountHolder']?.toString(),
      data: json,
    );
  }
}

class UpdateBankDetailsRequest {
  final String accountNumber;
  final String bankName;
  final String ifsc;
  final String upiId;
  final String accountHolder;

  const UpdateBankDetailsRequest({
    required this.accountNumber,
    required this.bankName,
    required this.ifsc,
    required this.upiId,
    required this.accountHolder,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber.trim(),
      'bank_name': bankName.trim(),
      'ifsc': ifsc.trim(),
      'upi_id': upiId.trim(),
      'account_holder': accountHolder.trim(),
    };
  }
}

class ProfileActionResponse {
  final String? message;
  final Map<String, dynamic> data;

  const ProfileActionResponse({this.message, this.data = const {}});

  factory ProfileActionResponse.fromJson(Map<String, dynamic> json) {
    return ProfileActionResponse(
      message: json['message']?.toString(),
      data: json,
    );
  }
}

Map<String, dynamic> profileDataFromResponse(Object? value) {
  final root = _asMap(value);
  final nestedData = _asMap(root['data']);
  final nestedProfile = _firstPresentMap(nestedData, const [
    'profile',
    'owner',
    'turf_owner',
    'turfOwner',
    'partner',
    'user',
  ]);
  final rootProfile = _firstPresentMap(root, const [
    'profile',
    'owner',
    'turf_owner',
    'turfOwner',
    'partner',
    'user',
  ]);
  final nestedUser = _asMap(nestedData['user']);
  final rootUser = _asMap(root['user']);

  if (nestedProfile.isNotEmpty) return _mergeRelatedData(nestedData, nestedProfile);
  if (rootProfile.isNotEmpty) return _mergeRelatedData(root, rootProfile);
  if (nestedUser.isNotEmpty) return nestedUser;
  if (rootUser.isNotEmpty) return rootUser;
  if (nestedData.isNotEmpty) return nestedData;
  return root;
}

Map<String, dynamic> responseMap(Object? value) {
  final mapped = _asMap(value);
  if (mapped.isNotEmpty) return mapped;
  return {'data': value};
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

Map<String, dynamic> _mergeRelatedData(
  Map<String, dynamic> parent,
  Map<String, dynamic> profile,
) {
  return {
    ...parent,
    ...profile,
    if (profile['bank_details'] == null && parent['bank_details'] != null)
      'bank_details': parent['bank_details'],
    if (profile['bankDetails'] == null && parent['bankDetails'] != null)
      'bankDetails': parent['bankDetails'],
    if (profile['stats'] == null && parent['stats'] != null)
      'stats': parent['stats'],
  };
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
