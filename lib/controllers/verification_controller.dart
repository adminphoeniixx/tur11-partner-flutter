import '../core/api_client.dart';
import '../models/verification_models.dart';
import '../services/verification_service.dart';
import 'safe_change_notifier.dart';

class VerificationController extends SafeChangeNotifier {
  final VerificationService _verificationService;

  VerificationController({VerificationService? verificationService})
      : _verificationService = verificationService ?? VerificationService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  VerificationStatus? _status;
  VerificationActionResponse? _lastResponse;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  VerificationStatus? get status => _status;
  VerificationActionResponse? get lastResponse => _lastResponse;

  Future<bool> loadStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final status = await _verificationService.getStatus();
      if (isDisposed) return false;
      _status = status;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load verification status. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> uploadDocument({
    required String docType,
    required String documentPath,
  }) {
    return _save(
      () => _verificationService.uploadDocument(
        docType: docType,
        documentPath: documentPath,
      ),
      reload: true,
    );
  }

  Future<bool> acceptTerms() {
    return _save(_verificationService.acceptTerms, reload: true);
  }

  Future<bool> _save(
    Future<VerificationActionResponse> Function() action, {
    bool reload = false,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastResponse = await action();
      if (isDisposed) return false;
      if (reload) {
        final status = await _verificationService.getStatus();
        if (isDisposed) return false;
        _status = status;
      }
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save verification changes. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }
}
