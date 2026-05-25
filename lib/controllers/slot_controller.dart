import '../core/api_client.dart';
import '../models/slot_models.dart';
import '../services/slot_service.dart';
import 'safe_change_notifier.dart';

class SlotController extends SafeChangeNotifier {
  final SlotService _slotService;

  SlotController({SlotService? slotService})
      : _slotService = slotService ?? SlotService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<SlotItem> _slots = const [];
  int? _turfId;
  String? _date;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<SlotItem> get slots => _slots;

  void clear() {
    _slots = const [];
    _turfId = null;
    _date = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> load({required int turfId, required String date}) async {
    _isLoading = true;
    _errorMessage = null;
    _turfId = turfId;
    _date = date;
    notifyListeners();

    try {
      final response = await _slotService.getSlots(turfId: turfId, date: date);
      if (isDisposed) return false;
      _slots = response.slots;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load slots. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> generate(GenerateSlotsRequest request) async {
    return _save(() => _slotService.generateSlots(request),
        turfId: request.turfId, date: request.dateFrom);
  }

  Future<bool> block({
    required List<int> slotIds,
    required String reason,
  }) async {
    return _save(
      () => _slotService.blockSlots(slotIds: slotIds, reason: reason),
    );
  }

  Future<bool> unblock(List<int> slotIds) async {
    return _save(() => _slotService.unblockSlots(slotIds));
  }

  Future<bool> updatePrice({
    required List<int> slotIds,
    required num price,
  }) async {
    return _save(
      () => _slotService.updateSlotPrice(slotIds: slotIds, price: price),
    );
  }

  Future<bool> _save(
    Future<void> Function() action, {
    int? turfId,
    String? date,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      if (isDisposed) return false;
      final reloadTurfId = turfId ?? _turfId;
      final reloadDate = date ?? _date;
      if (reloadTurfId != null && reloadDate != null) {
        final response =
            await _slotService.getSlots(turfId: reloadTurfId, date: reloadDate);
        if (isDisposed) return false;
        _slots = response.slots;
        _turfId = reloadTurfId;
        _date = reloadDate;
      }
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save slot changes. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }

}
