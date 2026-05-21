import '../core/api_client.dart';
import '../models/notification_models.dart';
import '../services/notification_service.dart';
import 'safe_change_notifier.dart';

class NotificationController extends SafeChangeNotifier {
  final NotificationService _notificationService;

  NotificationController({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<OwnerNotification> _notifications = const [];
  int _unreadCount = 0;
  NotificationPreferences _preferences = const NotificationPreferences();
  NotificationActionResponse? _lastResponse;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<OwnerNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  NotificationPreferences get preferences => _preferences;
  NotificationActionResponse? get lastResponse => _lastResponse;

  Future<bool> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _notificationService.getNotifications(),
        _notificationService.getPreferences(),
      ]);
      if (isDisposed) return false;
      final list = results[0] as NotificationListResponse;
      _notifications = list.notifications;
      _unreadCount = list.unreadCount;
      _preferences = results[1] as NotificationPreferences;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load notifications. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> markRead(OwnerNotification notification) async {
    final id = notification.id;
    if (id == null || !notification.unread) return true;

    final saved = await _save(() => _notificationService.markRead(id));
    if (saved) _markLocalRead({id});
    return saved;
  }

  Future<bool> markAllRead() async {
    final unreadNotifications = _notifications
        .where((notification) => notification.unread && notification.id != null)
        .toList();
    final unreadIds =
        unreadNotifications.map((notification) => notification.id!).toSet();
    if (unreadIds.isEmpty) return true;

    final saved = await _save(() async {
      NotificationActionResponse? last;
      for (final id in unreadIds) {
        last = await _notificationService.markRead(id);
      }
      return last ?? const NotificationActionResponse();
    });
    if (saved) _markLocalRead(unreadIds);
    return saved;
  }

  Future<bool> updatePreference({
    bool? newBooking,
    bool? paymentReceived,
    bool? cancellation,
    bool? newReview,
  }) {
    final next = _preferences.copyWith(
      newBooking: newBooking,
      paymentReceived: paymentReceived,
      cancellation: cancellation,
      newReview: newReview,
    );

    return _save(() => _notificationService.updatePreferences(next),
        nextPreferences: next);
  }

  Future<bool> _save(
    Future<NotificationActionResponse> Function() action, {
    bool reloadList = false,
    NotificationPreferences? nextPreferences,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    if (nextPreferences != null) _preferences = nextPreferences;
    notifyListeners();

    try {
      _lastResponse = await action();
      if (isDisposed) return false;
      if (reloadList) {
        final response = await _notificationService.getNotifications();
        if (isDisposed) return false;
        _notifications = response.notifications;
        _unreadCount = response.unreadCount;
      }
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save notification changes. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }

  void _markLocalRead(Set<int> ids) {
    if (isDisposed) return;
    _notifications = _notifications.map((notification) {
      final id = notification.id;
      if (id == null || !ids.contains(id)) return notification;

      return notification.copyWith(
        unread: false,
        data: {
          ...notification.data,
          'read_at': DateTime.now().toIso8601String(),
        },
      );
    }).toList();
    _unreadCount = _notifications.where((notification) => notification.unread).length;
    notifyListeners();
  }
}
