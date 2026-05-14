import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/booking_models.dart';
import '../services/booking_service.dart';

class BookingController extends ChangeNotifier {
  final BookingService _bookingService;

  BookingController({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  bool _isLoading = false;
  String? _errorMessage;
  List<BookingItem> _bookings = const [];
  BookingStats _stats = const BookingStats();

  bool get isLoading => _isLoading;
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
      _isLoading = false;
      notifyListeners();
    }
  }
}

class CancellationController extends ChangeNotifier {
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
      _cancellations = response.cancellations;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load cancellations. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
