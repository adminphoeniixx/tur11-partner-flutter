import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/match_models.dart';

class MatchService {
  Future<MatchesResponse> getMatches({String? status}) async {
    final response = await ApiClient.get(
      ApiConstants.matches,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return MatchesResponse.fromJson(response.data);
  }

  Future<void> createMatch(CreateMatchRequest request) async {
    await ApiClient.post(ApiConstants.matches, data: request.toJson());
  }
}
