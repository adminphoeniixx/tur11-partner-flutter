import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/review_models.dart';
import '../models/tournament_models.dart';

class TournamentService {
  Future<TournamentsResponse> getTournaments() async {
    final response = await ApiClient.get(ApiConstants.tournaments);
    return TournamentsResponse.fromJson(response.data);
  }

  Future<void> createTournament(CreateTournamentRequest request) async {
    await ApiClient.post(ApiConstants.tournaments, data: request.toJson());
  }

  Future<void> openRegistration(int tournamentId) async {
    await ApiClient.post(ApiConstants.tournamentOpenRegistration(tournamentId));
  }

  Future<TournamentTeamsResponse> getTeams(int tournamentId) async {
    final response =
        await ApiClient.get(ApiConstants.tournamentTeams(tournamentId));
    return TournamentTeamsResponse.fromJson(response.data);
  }

  Future<void> generateFixtures(int tournamentId) async {
    await ApiClient.post(ApiConstants.tournamentGenerateFixtures(tournamentId));
  }

  Future<void> recordResult(
    int tournamentId,
    RecordTournamentResultRequest request,
  ) async {
    await ApiClient.post(
      ApiConstants.tournamentRecordResult(tournamentId),
      data: request.toJson(),
    );
  }

  Future<void> completeTournament(
    int tournamentId,
    CompleteTournamentRequest request,
  ) async {
    await ApiClient.post(
      ApiConstants.tournamentComplete(tournamentId),
      data: request.toJson(),
    );
  }

  Future<ReviewsResponse> getReviews(int tournamentId) async {
    final response =
        await ApiClient.get(ApiConstants.tournamentReviews(tournamentId));
    return ReviewsResponse.fromJson(response.data);
  }
}
