import '../core/api_client.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';
import 'safe_change_notifier.dart';

class ProfileController extends SafeChangeNotifier {
  final ProfileService _profileService;

  ProfileController({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  OwnerProfile? _profile;
  ProfileActionResponse? _lastResponse;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  OwnerProfile? get profile => _profile;
  ProfileActionResponse? get lastResponse => _lastResponse;

  Future<bool> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _profileService.getProfile();
      if (isDisposed) return false;
      _profile = profile;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load profile. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updateProfile(UpdateProfileRequest request) {
    return _save(() async {
      _profile = await _profileService.updateProfile(request);
    });
  }

  Future<bool> updateBankDetails(UpdateBankDetailsRequest request) {
    return _save(() async {
      _lastResponse = await _profileService.updateBankDetails(request);
      await loadProfile();
    });
  }

  Future<bool> updateFcmToken(String fcmToken) {
    return _save(() async {
      _lastResponse = await _profileService.updateFcmToken(
        UpdateFcmTokenRequest(fcmToken: fcmToken),
      );
    });
  }

  Future<bool> _save(Future<void> Function() action) async {
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
      _errorMessage = 'Unable to save changes. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }
}
