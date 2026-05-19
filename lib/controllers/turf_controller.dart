import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/turf_models.dart';
import '../services/turf_service.dart';

class TurfController extends ChangeNotifier {
  final TurfService _turfService;

  TurfController({TurfService? turfService})
      : _turfService = turfService ?? TurfService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<TurfItem> _turfs = const [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<TurfItem> get turfs => _turfs;

  Future<bool> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _turfService.getTurfs();
      _turfs = response.turfs;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load turfs. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(CreateTurfRequest request) async {
    return _save(() => _turfService.createTurf(request), reload: true);
  }

  Future<bool> update(int turfId, UpdateTurfRequest request) async {
    return _save(() => _turfService.updateTurf(turfId, request), reload: true);
  }

  Future<bool> uploadMedia({
    required int turfId,
    List<String> photoPaths = const [],
    List<String> videoPaths = const [],
  }) async {
    return _save(
      () => _turfService.uploadMedia(
        turfId: turfId,
        photoPaths: photoPaths,
        videoPaths: videoPaths,
      ),
      reload: true,
    );
  }

  Future<bool> removeMedia({
    required int turfId,
    required String url,
    required String type,
  }) async {
    return _save(
      () => _turfService.removeMedia(turfId: turfId, url: url, type: type),
      reload: true,
    );
  }

  Future<bool> toggleStatus(int turfId) async {
    return _save(() => _turfService.toggleStatus(turfId), reload: true);
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
        final response = await _turfService.getTurfs();
        _turfs = response.turfs;
      }
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save turf changes. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
