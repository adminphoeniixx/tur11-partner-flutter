import 'package:flutter/material.dart';

import '../../controllers/booking_controller.dart';
import '../../models/booking_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingController _controller = BookingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onBookingsChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onBookingsChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bookings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('All bookings across your turfs',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          _stats(_controller.stats),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Bookings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    if (_controller.isLoading && _controller.bookings.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_controller.bookings.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No bookings found.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      )
                    else
                      ..._controller.bookings.map(_bookingFromApi),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stats(BookingStats stats) {
    return LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth < 360 ? 1 : 2;
      return GridView.count(
        crossAxisCount: constraints.maxWidth > 700 ? 4 : count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth < 360 ? 2.4 : 1.75,
        children: [
          StatCard(
              label: 'Total Bookings',
              value: stats.total,
              change: 'All bookings'),
          StatCard(
              label: 'Confirmed',
              value: stats.confirmed,
              change: 'Confirmed',
              changeColor: AppColors.green),
          StatCard(
              label: 'Cancelled',
              value: stats.cancelled,
              change: 'Cancelled',
              isUp: false),
          StatCard(
              label: 'Pending Pay',
              value: stats.pendingPay,
              change: 'Action needed',
              isUp: false,
              changeColor: AppColors.amber),
        ],
      );
    });
  }

  Widget _bookingFromApi(BookingItem booking) {
    final status = _statusType(booking.status);
    return _bookingCard(
      booking.id.startsWith('#') ? booking.id : '#${booking.id}',
      booking.customerName,
      booking.phone,
      booking.turfName,
      booking.dateTime,
      booking.players,
      booking.amount,
      _amountColor(status),
      status,
      _statusLabel(booking.status),
    );
  }

  Widget _bookingCard(
    String id,
    String name,
    String phone,
    String turf,
    String dateTime,
    String players,
    String amount,
    Color amountColor,
    StatusType status,
    String statusLabel,
  ) {
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
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('$id - $phone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
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
              child: Text(turf,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: Text(amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: amountColor)),
          ),
        ]),
        const SizedBox(height: 4),
        Text('$dateTime - $players players',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }

  StatusType _statusType(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('cancel')) return StatusType.cancelled;
    if (normalized.contains('pending')) return StatusType.pending;
    if (normalized.contains('complete')) return StatusType.completed;
    return StatusType.active;
  }

  Color _amountColor(StatusType status) {
    if (status == StatusType.cancelled) return AppColors.red;
    if (status == StatusType.pending) return AppColors.amber;
    return AppColors.green;
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
}
