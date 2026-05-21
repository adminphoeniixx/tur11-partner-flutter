import 'package:flutter/material.dart';

import '../controllers/notification_controller.dart';
import '../models/notification_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _controller = NotificationController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _controller.notifications;

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_controller.errorMessage!,
                style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ],
          const SizedBox(height: 14),
          _preferencesCard(),
          if (_controller.isLoading && notifications.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (notifications.isEmpty)
            const AppCard(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No notifications yet.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ),
            )
          else
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                for (var i = 0; i < notifications.length; i++) ...[
                  _notifItem(notifications[i]),
                  if (i != notifications.length - 1) _divider(),
                ],
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _preferencesCard() {
    final prefs = _controller.preferences;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.tune, size: 17, color: AppColors.dark),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Notification Preferences',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          if (_controller.isSaving)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ]),
        const SizedBox(height: 8),
        ToggleRow(
          label: 'New booking',
          subtitle: 'Booking confirmations and schedule updates',
          value: prefs.newBooking,
          onChanged: _controller.isSaving
              ? null
              : (value) => _updatePref(newBooking: value),
        ),
        ToggleRow(
          label: 'Payment received',
          subtitle: 'Payout and collection alerts',
          value: prefs.paymentReceived,
          onChanged: _controller.isSaving
              ? null
              : (value) => _updatePref(paymentReceived: value),
        ),
        ToggleRow(
          label: 'Cancellation',
          subtitle: 'Cancelled bookings and refund events',
          value: prefs.cancellation,
          onChanged: _controller.isSaving
              ? null
              : (value) => _updatePref(cancellation: value),
        ),
        ToggleRow(
          label: 'New review',
          subtitle: 'Player feedback on turfs and tournaments',
          value: prefs.newReview,
          onChanged: _controller.isSaving
              ? null
              : (value) => _updatePref(newReview: value),
        ),
      ]),
    );
  }

  Widget _header() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('${_controller.unreadCount} unread notifications',
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        );

        final button = _MarkAllReadButton(
          isSaving: _controller.isSaving,
          enabled: !_controller.isSaving && _controller.unreadCount > 0,
          onPressed: _markAllRead,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: button),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            button,
          ],
        );
      },
    );
  }

  Widget _notifItem(OwnerNotification notification) {
    final colors = _notificationColors(notification.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _markRead(notification),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (notification.unread)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 5, right: 8),
                decoration: const BoxDecoration(
                    color: AppColors.red, shape: BoxShape.circle),
              )
            else
              const SizedBox(width: 15),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(colors.icon, size: 18, color: colors.foreground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(notification.body,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              height: 1.45)),
                    ],
                    const SizedBox(height: 5),
                    Text(_timeLabel(notification),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted2)),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _markRead(OwnerNotification notification) async {
    final saved = await _controller.markRead(notification);
    if (!mounted || saved) return;
    _showSnack(_controller.errorMessage ?? 'Unable to mark notification read.',
        isError: true);
  }

  Future<void> _markAllRead() async {
    final saved = await _controller.markAllRead();
    if (!mounted) return;
    _showSnack(
      saved
          ? _controller.lastResponse?.message ?? 'Notifications marked read.'
          : _controller.errorMessage ?? 'Unable to mark notifications read.',
      isError: !saved,
    );
  }

  Future<void> _updatePref({
    bool? newBooking,
    bool? paymentReceived,
    bool? cancellation,
    bool? newReview,
  }) async {
    final saved = await _controller.updatePreference(
      newBooking: newBooking,
      paymentReceived: paymentReceived,
      cancellation: cancellation,
      newReview: newReview,
    );
    if (!mounted || saved) return;
    _showSnack(_controller.errorMessage ?? 'Unable to update preferences.',
        isError: true);
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.green,
      ),
    );
  }

  String _timeLabel(OwnerNotification notification) {
    final explicit = notification.timeText?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final createdAt = notification.createdAt;
    if (createdAt == null) return 'Just now';

    final difference = DateTime.now().difference(createdAt.toLocal());
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays}d ago';
  }

  _NotificationStyle _notificationColors(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('payment') || normalized.contains('payout')) {
      return const _NotificationStyle(
        icon: Icons.account_balance_wallet,
        background: AppColors.amberLt,
        foreground: AppColors.amber,
      );
    }
    if (normalized.contains('cancel') || normalized.contains('refund')) {
      return const _NotificationStyle(
        icon: Icons.cancel_outlined,
        background: AppColors.redLt,
        foreground: AppColors.red,
      );
    }
    if (normalized.contains('review') || normalized.contains('rating')) {
      return const _NotificationStyle(
        icon: Icons.star_outline,
        background: AppColors.blueLt,
        foreground: AppColors.blue,
      );
    }
    if (normalized.contains('tournament')) {
      return const _NotificationStyle(
        icon: Icons.emoji_events_outlined,
        background: AppColors.greenLt,
        foreground: AppColors.green,
      );
    }
    return const _NotificationStyle(
      icon: Icons.description_outlined,
      background: AppColors.greenLt,
      foreground: AppColors.green,
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.border);
}

class _NotificationStyle {
  final IconData icon;
  final Color background;
  final Color foreground;

  const _NotificationStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

class _MarkAllReadButton extends StatelessWidget {
  final bool isSaving;
  final bool enabled;
  final VoidCallback onPressed;

  const _MarkAllReadButton({
    required this.isSaving,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled || isSaving ? 1 : 0.48,
      child: SizedBox(
        height: 34,
        child: OutlinedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: isSaving
              ? const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.done_all, size: 15),
          label: Text(isSaving ? 'Saving...' : 'Mark all read'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.dark,
            disabledForegroundColor: AppColors.muted,
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.border, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
