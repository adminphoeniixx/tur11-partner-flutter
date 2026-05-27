import '../core/api_client.dart';
import '../models/booking_models.dart';
import '../services/booking_service.dart';
import 'safe_change_notifier.dart';

class BookingController extends SafeChangeNotifier {
  final BookingService _bookingService;

  BookingController({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<BookingItem> _bookings = const [];
  BookingStats _stats = const BookingStats();

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<BookingItem> get bookings => _bookings;
  BookingStats get stats => _stats;

  Future<bool> load({String? status, int? turfId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _bookingService.getBookings(
        status: status,
        turfId: turfId,
      );
      if (isDisposed) return false;
      _bookings = response.bookings;
      _stats = response.stats;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load bookings. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> createOwnerBooking(CreateOwnerBookingRequest request) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bookingService.createOwnerBooking(request);
      if (isDisposed) return false;
      final response = await _bookingService.getBookings();
      if (isDisposed) return false;
      _bookings = response.bookings;
      _stats = response.stats;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to create booking. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }
}

class CancellationController extends SafeChangeNotifier {
  final BookingService _bookingService;

  CancellationController({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  bool _isLoading = false;
  String? _errorMessage;
  List<CancellationItem> _cancellations = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CancellationItem> get cancellations => _cancellations;

  Future<bool> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _bookingService.getCancellations();
      if (isDisposed) return false;
      _cancellations = response.cancellations;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load cancellations. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
