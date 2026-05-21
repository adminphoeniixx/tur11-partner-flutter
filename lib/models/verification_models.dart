class VerificationStatus {
  final String status;
  final bool mobileVerified;
  final bool gstVerified;
  final bool documentVerified;
  final bool bankVerified;
  final bool locationVerified;
  final bool termsAccepted;
  final String? mobileSubtitle;
  final String? gstSubtitle;
  final String? documentSubtitle;
  final String? bankSubtitle;
  final String? locationSubtitle;
  final String? message;
  final Map<String, dynamic> data;

  const VerificationStatus({
    required this.status,
    required this.mobileVerified,
    required this.gstVerified,
    required this.documentVerified,
    required this.bankVerified,
    required this.locationVerified,
    required this.termsAccepted,
    this.mobileSubtitle,
    this.gstSubtitle,
    this.documentSubtitle,
    this.bankSubtitle,
    this.locationSubtitle,
    this.message,
    this.data = const {},
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    final data = verificationDataFromResponse(json);
    final verification = _firstPresentMap(data, const [
      'verification',
      'verification_status',
      'verificationStatus',
      'owner_verification',
      'ownerVerification',
    ]);
    final source = verification.isEmpty ? data : {...data, ...verification};
    final documents = _asMap(
      source['documents'] ?? source['document'] ?? source['kyc_documents'],
    );

    final documentStatus = _firstString([
      source['document_status'],
      source['documentStatus'],
      source['kyc_status'],
      documents['status'],
    ]);

    return VerificationStatus(
      status: _firstString([
            source['status'],
            source['verification_status'],
            source['verificationStatus'],
          ]) ??
          'pending',
      mobileVerified: _truthyAny([
        source['mobile_verified'],
        source['mobileVerified'],
        source['phone_verified'],
        source['phoneVerified'],
        source['otp_verified'],
      ]),
      gstVerified: _truthyAny([
        source['gst_verified'],
        source['gstVerified'],
        source['gst_status'],
      ]),
      documentVerified: _truthyAny([
        source['document_verified'],
        source['documentVerified'],
        source['kyc_verified'],
        documentStatus,
      ]),
      bankVerified: _truthyAny([
        source['bank_verified'],
        source['bankVerified'],
        source['bank_status'],
      ]),
      locationVerified: _truthyAny([
        source['location_verified'],
        source['locationVerified'],
        source['turf_location_verified'],
        source['turfLocationVerified'],
      ]),
      termsAccepted: _truthyAny([
        source['terms_accepted'],
        source['termsAccepted'],
        source['accepted_terms'],
        source['acceptedTerms'],
      ]),
      mobileSubtitle: _firstString([
        source['phone'],
        source['mobile'],
        source['mobile_subtitle'],
        source['mobileSubtitle'],
      ]),
      gstSubtitle: _firstString([
        source['gst_number'],
        source['gstNumber'],
        source['gst_subtitle'],
        source['gstSubtitle'],
      ]),
      documentSubtitle: _firstString([
        documentStatus,
        source['document_message'],
        source['documentMessage'],
        documents['doc_type'],
      ]),
      bankSubtitle: _firstString([
        source['bank_message'],
        source['bankMessage'],
        source['bank_status'],
      ]),
      locationSubtitle: _firstString([
        source['location_message'],
        source['locationMessage'],
        source['location_status'],
      ]),
      message: _firstString([json['message'], source['message']]),
      data: source,
    );
  }
}

class VerificationActionResponse {
  final String? message;
  final Map<String, dynamic> data;

  const VerificationActionResponse({this.message, this.data = const {}});

  factory VerificationActionResponse.fromJson(Map<String, dynamic> json) {
    return VerificationActionResponse(
      message: json['message']?.toString(),
      data: json,
    );
  }
}

Map<String, dynamic> verificationDataFromResponse(Object? value) {
  final root = _asMap(value);
  final data = _asMap(root['data']);
  if (data.isNotEmpty) return data;
  return root;
}

Map<String, dynamic> verificationResponseMap(Object? value) {
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

String? _firstString(List<Object?> values) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

bool _truthyAny(List<Object?> values) {
  for (final value in values) {
    if (_asBool(value) == true) return true;
  }
  return false;
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value == null) return null;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == '1' ||
      normalized == 'true' ||
      normalized == 'yes' ||
      normalized == 'verified' ||
      normalized == 'approved' ||
      normalized == 'accepted' ||
      normalized == 'complete' ||
      normalized == 'completed') {
    return true;
  }
  if (normalized == '0' ||
      normalized == 'false' ||
      normalized == 'no' ||
      normalized == 'pending' ||
      normalized == 'rejected' ||
      normalized == 'failed') {
    return false;
  }
  return null;
}
