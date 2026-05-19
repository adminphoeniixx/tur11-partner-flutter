import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/review_models.dart';
import '../models/tournament_models.dart';
import '../services/tournament_service.dart';

class TournamentController extends ChangeNotifier {
  final TournamentService _service;

  TournamentController({TournamentService? service})
      : _service = service ?? TournamentService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<TournamentItem> _tournaments = const [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<TournamentItem> get tournaments => _tournaments;

  Future<bool> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getTournaments();
      _tournaments = response.tournaments;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load tournaments. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(CreateTournamentRequest request) async {
    return _save(() => _service.createTournament(request), reload: true);
  }

  Future<bool> openRegistration(int tournamentId) async {
    return _save(() => _service.openRegistration(tournamentId), reload: true);
  }

  Future<bool> generateFixtures(int tournamentId) async {
    return _save(() => _service.generateFixtures(tournamentId), reload: true);
  }

  Future<bool> recordResult(
    int tournamentId,
    RecordTournamentResultRequest request,
  ) async {
    return _save(() => _service.recordResult(tournamentId, request),
        reload: true);
  }

  Future<bool> complete(
    int tournamentId,
    CompleteTournamentRequest request,
  ) async {
    return _save(() => _service.completeTournament(tournamentId, request),
        reload: true);
  }

  Future<bool> _save(
    Future<void> Function() action, {
    bool reload = false,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      if (reload) {
        final response = await _service.getTournaments();
        _tournaments = response.tournaments;
      }
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save tournament changes. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

class TournamentTeamsController extends ChangeNotifier {
  final TournamentService _service;

  TournamentTeamsController({TournamentService? service})
      : _service = service ?? TournamentService();

  bool _isLoading = false;
  String? _errorMessage;
  List<TournamentTeamItem> _teams = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TournamentTeamItem> get teams => _teams;

  Future<bool> load(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getTeams(tournamentId);
      _teams = response.teams;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load team registrations. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class TournamentReviewsController extends ChangeNotifier {
  final TournamentService _service;

  TournamentReviewsController({TournamentService? service})
      : _service = service ?? TournamentService();

  bool _isLoading = false;
  String? _errorMessage;
  List<ReviewItem> _reviews = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ReviewItem> get reviews => _reviews;

  Future<bool> load(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getReviews(tournamentId);
      _reviews = response.reviews;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load tournament reviews. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
