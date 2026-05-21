import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/verification_models.dart';

class VerificationService {
  Future<VerificationStatus> getStatus() async {
    final response = await ApiClient.get(ApiConstants.verification);
    return VerificationStatus.fromJson(verificationResponseMap(response.data));
  }

  Future<VerificationActionResponse> uploadDocument({
    required String docType,
    required String documentPath,
  }) async {
    final form = FormData.fromMap({
      'doc_type': docType,
      'document': await MultipartFile.fromFile(documentPath),
    });

    final response = await ApiClient.postForm(
      ApiConstants.verificationUpload,
      form,
    );
    return VerificationActionResponse.fromJson(
      verificationResponseMap(response.data),
    );
  }

  Future<VerificationActionResponse> acceptTerms() async {
    final response = await ApiClient.post(ApiConstants.acceptTerms);
    return VerificationActionResponse.fromJson(
      verificationResponseMap(response.data),
    );
  }
}
