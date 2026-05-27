import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/booking_models.dart';
import 'profile_service.dart';

class BookingService {
  final ProfileService _profileService;

  BookingService({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

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

  Future<void> createOwnerBooking(CreateOwnerBookingRequest request) async {
    final body = request.toJson();

    var ownerName = body['owner_name']?.toString().trim() ?? '';
    if (ownerName.isEmpty) {
      try {
        final profile = await _profileService.getProfile();
        ownerName = profile.displayName.trim();
      } catch (_) {
        ownerName = 'Owner';
      }
    }

    body['owner_name'] = ownerName;
    body['ownerName'] = ownerName;

    await ApiClient.post(ApiConstants.bookings, data: body);
  }
}
