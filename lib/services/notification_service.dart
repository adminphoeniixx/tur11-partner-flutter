import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/notification_models.dart';

class NotificationService {
  Future<NotificationListResponse> getNotifications() async {
    final response = await ApiClient.get(ApiConstants.notifications);
    return NotificationListResponse.fromJson(response.data);
  }

  Future<NotificationActionResponse> markRead(int notificationId) async {
    final response = await ApiClient.post(
      ApiConstants.notificationRead(notificationId),
    );
    return NotificationActionResponse.fromJson(response.data);
  }

  Future<NotificationPreferences> getPreferences() async {
    final response = await ApiClient.get(ApiConstants.notificationPrefs);
    return NotificationPreferences.fromJson(response.data);
  }

  Future<NotificationActionResponse> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    final response = await ApiClient.put(
      ApiConstants.notificationPrefs,
      data: preferences.toJson(),
    );
    return NotificationActionResponse.fromJson(response.data);
  }

  Future<NotificationActionResponse> updatePreferenceFields(
    Map<String, dynamic> fields,
  ) async {
    final response = await ApiClient.put(
      ApiConstants.notificationPrefs,
      data: fields,
    );
    return NotificationActionResponse.fromJson(response.data);
  }
}
