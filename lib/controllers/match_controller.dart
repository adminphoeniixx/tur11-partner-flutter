import '../core/api_client.dart';
import '../models/match_models.dart';
import '../services/match_service.dart';
import 'safe_change_notifier.dart';

class MatchController extends SafeChangeNotifier {
  final MatchService _matchService;

  MatchController({MatchService? matchService})
      : _matchService = matchService ?? MatchService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<MatchItem> _matches = const [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<MatchItem> get matches => _matches;

  Future<bool> load({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _matchService.getMatches(status: status);
      if (isDisposed) return false;
      _matches = response.matches;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load matches. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> createMatch(CreateMatchRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _matchService.createMatch(request);
      if (isDisposed) return false;
      await load();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to create match. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updateStream(int matchId, UpdateStreamRequest request) {
    return _saveAction(
      () => _matchService.updateStream(matchId, request),
      fallback: 'Unable to update stream. Please try again.',
    );
  }

  Future<Object?> getStreamInfo(int matchId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stream = await _matchService.getStream(matchId);
      if (isDisposed) return null;
      return stream;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Unable to get stream info. Please try again.';
      return null;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }

  Future<bool> createMuxStream(int matchId) {
    return _saveAction(
      () => _matchService.createMuxStream(matchId),
      fallback: 'Unable to create Mux stream. Please try again.',
    );
  }

  Future<bool> endStream(int matchId) {
    return _saveAction(
      () => _matchService.endStream(matchId),
      fallback: 'Unable to end stream. Please try again.',
    );
  }

  Future<bool> updateScoreboard(
    int matchId,
    UpdateScoreboardRequest request,
  ) {
    return _saveAction(
      () => _matchService.updateScoreboard(matchId, request),
      fallback: 'Unable to update scoreboard. Please try again.',
    );
  }

  Future<bool> addCommentary(int matchId, AddCommentaryRequest request) {
    return _saveAction(
      () => _matchService.addCommentary(matchId, request),
      fallback: 'Unable to add commentary. Please try again.',
    );
  }

  Future<bool> deleteCommentary(int matchId, int commentaryId) {
    return _saveAction(
      () => _matchService.deleteCommentary(matchId, commentaryId),
      fallback: 'Unable to delete commentary. Please try again.',
    );
  }

  Future<bool> _saveAction(
    Future<void> Function() action, {
    required String fallback,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      if (isDisposed) return false;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = fallback;
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }
}
