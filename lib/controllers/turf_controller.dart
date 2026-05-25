import '../core/api_client.dart';
import '../models/turf_models.dart';
import '../services/turf_service.dart';
import 'safe_change_notifier.dart';

class TurfController extends SafeChangeNotifier {
  final TurfService _turfService;

  TurfController({TurfService? turfService})
      : _turfService = turfService ?? TurfService();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isPricingLoading = false;
  String? _errorMessage;
  List<TurfItem> _turfs = const [];
  TurfPricing? _pricing;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isPricingLoading => _isPricingLoading;
  String? get errorMessage => _errorMessage;
  List<TurfItem> get turfs => _turfs;
  TurfPricing? get pricing => _pricing;

  void clearPricing() {
    _pricing = null;
    notifyListeners();
  }

  Future<bool> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _turfService.getTurfs();
      if (isDisposed) return false;
      _turfs = response.turfs;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load turfs. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> create(CreateTurfRequest request) async {
    return _save(() => _turfService.createTurf(request), reload: true);
  }

  Future<bool> update(int turfId, UpdateTurfRequest request) async {
    return _save(() => _turfService.updateTurf(turfId, request), reload: true);
  }

  Future<bool> loadPricing(int turfId) async {
    _isPricingLoading = true;
    _errorMessage = null;
    _pricing = null;
    notifyListeners();

    try {
      _pricing = await _turfService.getPricing(turfId);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load pricing rules. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isPricingLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updatePricing(
    int turfId,
    UpdateTurfPricingRequest request,
  ) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _turfService.updatePricing(turfId, request);
      if (isDisposed) return false;
      _pricing = await _turfService.getPricing(turfId);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save pricing rules. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
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
      if (isDisposed) return false;
      if (reload) {
        final response = await _turfService.getTurfs();
        if (isDisposed) return false;
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
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }
}
