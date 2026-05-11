import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bookings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('All bookings across your turfs',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 14),
          _stats(),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent Bookings',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                _bookingCard('#T11-4821', 'Rahul Kumar', '9876543210',
                    'DLF Arena', 'Apr 7, 7:00-9:00 PM', '16', 'Rs 1,600',
                    AppColors.green, StatusType.active, 'Confirmed'),
                _bookingCard('#T11-4820', 'Arjun Kapoor', '9812345678',
                    'Sector 56', 'Apr 7, 5:00-7:00 PM', '12', 'Rs 1,200',
                    AppColors.amber, StatusType.pending, 'Pending Pay'),
                _bookingCard('#T11-4819', 'Priya Verma', '9876000111',
                    'DLF Arena', 'Apr 8, 6:00-8:00 AM', '8', 'Rs 800',
                    AppColors.green, StatusType.active, 'Confirmed'),
                _bookingCard('#T11-4818', 'Sahil Rawat', '9900112233',
                    'CyberHub', 'Apr 6, 8:00-10:00 PM', '10', 'Rs 0',
                    AppColors.red, StatusType.cancelled, 'Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth < 360 ? 1 : 2;
      return GridView.count(
        crossAxisCount: constraints.maxWidth > 700 ? 4 : count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth < 360 ? 2.4 : 1.75,
        children: const [
          StatCard(label: 'Total Bookings', value: '486', change: 'This month'),
          StatCard(
              label: 'Confirmed',
              value: '442',
              change: '91%',
              changeColor: AppColors.green),
          StatCard(
              label: 'Cancelled',
              value: '32',
              change: '6.6%',
              isUp: false),
          StatCard(
              label: 'Pending Pay',
              value: '12',
              change: 'Action needed',
              isUp: false,
              changeColor: AppColors.amber),
        ],
      );
    });
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
        Row(children: [
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
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ),
          StatusBadge(label: statusLabel, type: status),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text(turf,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600))),
          Text(amount,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: amountColor)),
        ]),
        const SizedBox(height: 4),
        Text('$dateTime - $players players',
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }
}




