import 'package:flutter/material.dart';

import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../models/profile_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;
  final OwnerProfile? profile;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
    this.profile,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDashboardChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onDashboardChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onDashboardChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    final dashboard = _controller.dashboard ?? const DashboardData();

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(dashboard, isPhone),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          _statsGrid(dashboard),
          const SizedBox(height: 14),
          _recentBookings(dashboard),
          _actionAndOccupancySection(),
        ]),
      ),
    );
  }

  Widget _header(DashboardData dashboard, bool isPhone) {
    final title = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Good morning, ${_shortName(widget.profile)}!',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.dark,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        '${dashboard.activeTurfs} active turfs${_cityText(widget.profile)}',
        style: const TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    ]);

    final addButton = PillButton.green(
      'Add Turf',
      icon: Icons.add,
      onPressed: () => widget.onNavigate('add_turf'),
    );

    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: addButton),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        addButton,
      ],
    );
  }

  Widget _statsGrid(DashboardData dashboard) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700
          ? 4
          : (constraints.maxWidth < 360 ? 1 : 2);
      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth < 360 ? 2.25 : 1.35,
        children: [
          StatCard(
            label: 'Revenue Today',
            value: dashboard.revenueToday,
            change: dashboard.revenueChange,
            icon: _statIcon(
              Icons.account_balance_wallet,
              AppColors.greenLt,
              AppColors.green,
            ),
          ),
          StatCard(
            label: 'Bookings Today',
            value: dashboard.bookingsToday,
            change: dashboard.bookingsChange,
            icon: _statIcon(
              Icons.description_outlined,
              AppColors.blueLt,
              AppColors.blue,
            ),
          ),
          StatCard(
            label: 'Active Slots',
            value: dashboard.activeSlots,
            change: dashboard.activeSlotsChange,
            isUp: false,
            icon: _statIcon(
              Icons.people_outline,
              AppColors.amberLt,
              AppColors.amber,
            ),
          ),
          StatCard(
            label: 'Pending Payouts',
            value: dashboard.pendingPayouts,
            change: dashboard.pendingPayoutsChange,
            isUp: false,
            changeColor: AppColors.muted,
            icon: _statIcon(
              Icons.emoji_events_outlined,
              AppColors.redLt,
              AppColors.red,
            ),
          ),
        ],
      );
    });
  }

  Widget _recentBookings(DashboardData dashboard) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            const Expanded(
              child: Text(
                'Recent Bookings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            PillButton.ghost(
              'View all',
              onPressed: () => widget.onNavigate('bookings'),
            ),
          ]),
          const SizedBox(height: 14),
          if (_controller.isLoading && dashboard.recentBookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(),
            )
          else if (dashboard.recentBookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No recent bookings yet.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            )
          else
            ...dashboard.recentBookings.map(_bookingFromApi),
        ]),
      ),
    );
  }

  Widget _bookingFromApi(DashboardBooking booking) {
    return _bookingCard(
      booking.customerName,
      booking.phone,
      booking.turfName,
      booking.date,
      booking.time,
      booking.amount,
      _statusType(booking.status),
      _statusLabel(booking.status),
      booking.initials,
    );
  }

  Widget _statIcon(IconData icon, Color bg, Color fg) {
    return Container(
      width: 34,
      height: 34,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: fg, size: 18),
    );
  }

  Widget _bookingCard(
    String name,
    String phone,
    String turf,
    String date,
    String time,
    String amount,
    StatusType status,
    String statusLabel,
    String initials,
  ) {
    final amountColor = status == StatusType.cancelled
        ? AppColors.red
        : (status == StatusType.pending ? AppColors.amber : AppColors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppAvatar(initials: initials, size: 34, bg: AppColors.dark),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: StatusBadge(label: statusLabel, type: status),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Text(
              turf,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            flex: 0,
            child: Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          [date, time].where((part) => part.trim().isNotEmpty).join(', '),
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ]),
    );
  }

  Widget _quickActions() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        _actionBtn('Add New Turf', Icons.add, AppColors.green, Colors.white,
            () => widget.onNavigate('add_turf')),
        const SizedBox(height: 8),
        _actionBtn('Manage Slots', Icons.calendar_month, AppColors.white,
            AppColors.dark, () => widget.onNavigate('manage_slots'),
            outlined: true),
        const SizedBox(height: 8),
        _actionBtn('Create Tournament', Icons.emoji_events_outlined,
            AppColors.white, AppColors.dark,
            () => widget.onNavigate('add_tournament'),
            outlined: true),
        const SizedBox(height: 8),
        _actionBtn('View Payments', Icons.account_balance_wallet_outlined,
            AppColors.white, AppColors.dark, () => widget.onNavigate('payments'),
            outlined: true),
      ]),
    );
  }

  Widget _actionAndOccupancySection() {
    return LayoutBuilder(builder: (context, constraints) {
      final twoColumn = constraints.maxWidth >= 860;
      if (!twoColumn) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _quickActions(),
            _occupancy(),
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _quickActions()),
          const SizedBox(width: 12),
          Expanded(child: _occupancy()),
        ],
      );
    });
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color bg,
    Color fg,
    VoidCallback onTap, {
    bool outlined = false,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.5),
                )
              : null,
          child: Row(children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: fg),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _occupancy() {
    final items = _controller.occupancy;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Today's Occupancy",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (_controller.isLoading && items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              ),
            )
          else if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No occupancy data yet.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            )
          else
            ...List.generate(items.length, (index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == items.length - 1 ? 0 : 10,
                ),
                child: _occRow(
                  item.name,
                  item.value,
                  item.percentLabel,
                  _occupancyColor(item.value),
                ),
              );
            }),
        ]),
      ),
    );
  }

  Widget _occRow(String name, double value, String pct, Color color) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          pct,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ]),
      const SizedBox(height: 4),
      AppProgressBar(value: value, color: color),
    ]);
  }

  Color _occupancyColor(double value) {
    if (value >= 0.7) return AppColors.green;
    if (value >= 0.4) return AppColors.amber;
    return AppColors.red;
  }

  StatusType _statusType(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('cancel')) return StatusType.cancelled;
    if (normalized.contains('pending')) return StatusType.pending;
    if (normalized.contains('complete')) return StatusType.completed;
    return StatusType.active;
  }

  String _statusLabel(String status) {
    final cleaned = status.trim();
    if (cleaned.isEmpty) return 'Confirmed';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .map((part) => part.isEmpty
            ? part
            : '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _shortName(OwnerProfile? profile) {
    final firstName = profile?.firstName?.trim();
    if (firstName != null && firstName.isNotEmpty) return firstName;

    final displayName = profile?.displayName.trim();
    if (displayName == null || displayName.isEmpty || displayName == 'Owner') {
      return 'Owner';
    }
    return displayName.split(RegExp(r'\s+')).first;
  }

  String _cityText(OwnerProfile? profile) {
    final city = profile?.city?.trim();
    if (city == null || city.isEmpty) return '';
    return ' - $city';
  }
}
