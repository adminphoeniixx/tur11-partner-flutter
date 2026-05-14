import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/match_models.dart';
import '../services/match_service.dart';

class MatchController extends ChangeNotifier {
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

  Future<bool> load({String? status = 'open'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _matchService.getMatches(status: status);
      _matches = response.matches;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load matches. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMatch(CreateMatchRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _matchService.createMatch(request);
      await load();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to create match. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
