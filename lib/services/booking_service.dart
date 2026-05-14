import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/booking_models.dart';

class BookingService {
  Future<BookingsResponse> getBookings({
    String? status,
    int? turfId,
  }) async {
    final response = await ApiClient.get(
      ApiConstants.bookings,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (turfId != null) 'turf_id': turfId,
      },
    );
    return BookingsResponse.fromJson(response.data);
  }

  Future<CancellationsResponse> getCancellations() async {
    final response = await ApiClient.get(ApiConstants.cancellations);
    return CancellationsResponse.fromJson(response.data);
  }
}
