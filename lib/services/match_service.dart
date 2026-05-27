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

  Future<void> updateStream(int matchId, UpdateStreamRequest request) async {
    await ApiClient.post(
      ApiConstants.matchStream(matchId),
      data: request.toJson(),
    );
  }

  Future<LiveStreamInfo> getStream(int matchId) async {
    final response = await ApiClient.get(ApiConstants.matchStream(matchId));
    return LiveStreamInfo.fromJson(response.data);
  }

  Future<LiveStreamInfo> createMuxStream(int matchId) async {
    final response = await ApiClient.post(ApiConstants.matchMuxStream(matchId));
    return LiveStreamInfo.fromJson(response.data);
  }

  Future<void> endStream(int matchId) async {
    await ApiClient.post(ApiConstants.endMatchStream(matchId));
  }

  Future<void> updateScoreboard(
    int matchId,
    UpdateScoreboardRequest request,
  ) async {
    await ApiClient.post(
      ApiConstants.matchScoreboard(matchId),
      data: request.toJson(),
    );
  }

  Future<void> addCommentary(
    int matchId,
    AddCommentaryRequest request,
  ) async {
    await ApiClient.post(
      ApiConstants.matchCommentary(matchId),
      data: request.toJson(),
    );
  }

  Future<void> deleteCommentary(int matchId, int commentaryId) async {
    await ApiClient.delete(
      ApiConstants.matchCommentaryEntry(matchId, commentaryId),
    );
  }
}
