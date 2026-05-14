import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/profile_models.dart';

class ProfileService {
  Future<OwnerProfile> getProfile() async {
    final response = await ApiClient.get(ApiConstants.profile);
    return OwnerProfile.fromJson(profileDataFromResponse(response.data));
  }

  Future<OwnerProfile> updateProfile(UpdateProfileRequest request) async {
    final response = await ApiClient.put(
      ApiConstants.profile,
      data: request.toJson(),
    );
    return OwnerProfile.fromJson(profileDataFromResponse(response.data));
  }

  Future<ProfileActionResponse> updateFcmToken(
    UpdateFcmTokenRequest request,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.fcmToken,
      data: request.toJson(),
    );
    return ProfileActionResponse.fromJson(responseMap(response.data));
  }

  Future<ProfileActionResponse> updateBankDetails(
    UpdateBankDetailsRequest request,
  ) async {
    final response = await ApiClient.post(
      ApiConstants.bankDetails,
      data: request.toJson(),
    );
    return ProfileActionResponse.fromJson(responseMap(response.data));
  }
}
