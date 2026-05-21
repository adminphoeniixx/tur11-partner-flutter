class NotificationListResponse {
  final List<OwnerNotification> notifications;
  final int unreadCount;
  final Map<String, dynamic> data;

  const NotificationListResponse({
    required this.notifications,
    required this.unreadCount,
    this.data = const {},
  });

  factory NotificationListResponse.fromJson(Object? value) {
    final root = notificationResponseMap(value);
    final data = _asMap(root['data']);
    final source = data.isEmpty ? root : data;
    final rawList = _firstPresentList(source, const [
      'notifications',
      'items',
      'data',
      'results',
    ]);
    final notifications = rawList
        .map(_asMap)
        .where((item) => item.isNotEmpty)
        .map(OwnerNotification.fromJson)
        .toList();

    return NotificationListResponse(
      notifications: notifications,
      unreadCount: _asInt(source['unread_count'] ?? source['unreadCount']) ??
          notifications.where((item) => item.unread).length,
      data: source,
    );
  }
}

class OwnerNotification {
  final int? id;
  final String title;
  final String body;
  final String type;
  final String? timeText;
  final DateTime? createdAt;
  final bool unread;
  final Map<String, dynamic> data;

  const OwnerNotification({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    this.timeText,
    this.createdAt,
    required this.unread,
    this.data = const {},
  });

  factory OwnerNotification.fromJson(Map<String, dynamic> json) {
    final nestedData = _asMap(json['data']);
    final readAt = json['read_at'] ?? json['readAt'];
    final createdAtText = _firstString([
      json['created_at'],
      json['createdAt'],
      json['time'],
      json['timestamp'],
    ]);

    return OwnerNotification(
      id: _asInt(json['id'] ?? json['notification_id']),
      title: _firstString([
            json['title'],
            json['heading'],
            nestedData['title'],
            nestedData['heading'],
          ]) ??
          'Notification',
      body: _firstString([
            json['body'],
            json['message'],
            json['description'],
            nestedData['body'],
            nestedData['message'],
          ]) ??
          '',
      type: _firstString([json['type'], nestedData['type']]) ?? 'general',
      timeText: _firstString([
        json['time_ago'],
        json['timeAgo'],
        json['display_time'],
        json['displayTime'],
      ]),
      createdAt: createdAtText == null ? null : DateTime.tryParse(createdAtText),
      unread: _asBool(json['unread'] ?? json['is_unread'] ?? json['isUnread']) ??
          readAt == null,
      data: json,
    );
  }

  OwnerNotification copyWith({
    bool? unread,
    Map<String, dynamic>? data,
  }) {
    return OwnerNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      timeText: timeText,
      createdAt: createdAt,
      unread: unread ?? this.unread,
      data: data ?? this.data,
    );
  }
}

class NotificationPreferences {
  final bool newBooking;
  final bool paymentReceived;
  final bool cancellation;
  final bool newReview;
  final Map<String, dynamic> data;

  const NotificationPreferences({
    this.newBooking = true,
    this.paymentReceived = true,
    this.cancellation = true,
    this.newReview = false,
    this.data = const {},
  });

  factory NotificationPreferences.fromJson(Object? value) {
    final root = notificationResponseMap(value);
    final data = _asMap(root['data']);
    final source = data.isEmpty ? root : data;
    final prefs = _firstPresentMap(source, const [
      'preferences',
      'notification_prefs',
      'notificationPrefs',
      'prefs',
    ]);
    final values = prefs.isEmpty ? source : prefs;

    return NotificationPreferences(
      newBooking: _asBool(values['new_booking'] ?? values['newBooking']) ?? true,
      paymentReceived: _asBool(
            values['payment_received'] ?? values['paymentReceived'],
          ) ??
          true,
      cancellation: _asBool(values['cancellation']) ?? true,
      newReview: _asBool(values['new_review'] ?? values['newReview']) ?? false,
      data: values,
    );
  }

  NotificationPreferences copyWith({
    bool? newBooking,
    bool? paymentReceived,
    bool? cancellation,
    bool? newReview,
  }) {
    return NotificationPreferences(
      newBooking: newBooking ?? this.newBooking,
      paymentReceived: paymentReceived ?? this.paymentReceived,
      cancellation: cancellation ?? this.cancellation,
      newReview: newReview ?? this.newReview,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_booking': newBooking,
      'payment_received': paymentReceived,
      'cancellation': cancellation,
      'new_review': newReview,
    };
  }
}

class NotificationActionResponse {
  final String? message;
  final Map<String, dynamic> data;

  const NotificationActionResponse({this.message, this.data = const {}});

  factory NotificationActionResponse.fromJson(Object? value) {
    final mapped = notificationResponseMap(value);
    return NotificationActionResponse(
      message: mapped['message']?.toString(),
      data: mapped,
    );
  }
}

Map<String, dynamic> notificationResponseMap(Object? value) {
  final mapped = _asMap(value);
  if (mapped.isNotEmpty) return mapped;
  return {'data': value};
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<Object?> _firstPresentList(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) return value.cast<Object?>();
    final nested = _asMap(value);
    final nestedData = nested['data'];
    if (nestedData is List) return nestedData.cast<Object?>();
  }
  return const [];
}

Map<String, dynamic> _firstPresentMap(
  Map<String, dynamic> source,
  List<String> keys,
) {
  for (final key in keys) {
    final mapped = _asMap(source[key]);
    if (mapped.isNotEmpty) return mapped;
  }
  return {};
}

String? _firstString(List<Object?> values) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value == null) return null;
  return int.tryParse(value.toString());
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value == null) return null;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == '1' || normalized == 'true' || normalized == 'yes') {
    return true;
  }
  if (normalized == '0' || normalized == 'false' || normalized == 'no') {
    return false;
  }
  return null;
}
