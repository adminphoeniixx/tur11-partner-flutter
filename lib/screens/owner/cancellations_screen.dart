import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class CancellationsScreen extends StatelessWidget {
  const CancellationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cancellations & Refunds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Track cancellations and process refunds',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        _stats(),
        const SizedBox(height: 16),
        AppCard(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cancellation Log',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _cancelCard('#T11-4818', 'Sahil Rawat', 'CyberHub Arena',
                  'Apr 6, 6:00 PM', '2 hrs before', AppColors.redLt,
                  AppColors.red, 'Rs 0 (no refund)', AppColors.red,
                  StatusType.completed, 'Processed'),
              _cancelCard('#T11-4810', 'Priya Kapoor', 'DLF Arena',
                  'Apr 5, 10:00 AM', '14 hrs before', AppColors.amberLt,
                  AppColors.amber, 'Rs 600 (50%)', AppColors.amber,
                  StatusType.active, 'Refunded'),
              _cancelCard('#T11-4802', 'Mohit Jain', 'Sector 56 Box',
                  'Apr 4, 9:00 AM', '36 hrs before', AppColors.greenLt,
                  AppColors.green, 'Rs 1,200 (full)', AppColors.green,
                  StatusType.active, 'Refunded'),
              _cancelCard('#T11-4795', 'Karan Malhotra', 'DLF Arena',
                  'Apr 3, 4:00 PM', '1 hr before', AppColors.redLt,
                  AppColors.red, 'Rs 0 + Rs 50 penalty', AppColors.red,
                  StatusType.pending, 'Processing'),
            ])),
      ]),
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
          StatCard(
              label: 'Cancellations',
              value: '32',
              change: '6.6% of bookings',
              isUp: false),
          StatCard(
              label: 'Refunds Issued',
              value: 'Rs 14,200',
              change: 'Auto-processed',
              isUp: false,
              changeColor: AppColors.muted),
          StatCard(
              label: 'Penalties',
              value: 'Rs 2,400',
              change: '48 no-shows'),
          StatCard(
              label: 'Pending Refunds',
              value: 'Rs 3,600',
              change: '4 pending',
              isUp: false,
              changeColor: AppColors.amber),
        ],
      );
    });
  }

  Widget _cancelCard(
    String id,
    String name,
    String turf,
    String time,
    String before,
    Color beforeBg,
    Color beforeFg,
    String refund,
    Color refundColor,
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
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700))),
          StatusBadge(label: statusLabel, type: status),
        ]),
        const SizedBox(height: 4),
        Text('$id - $turf',
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: 12),
        Row(children: [
          AppBadge(label: before, bg: beforeBg, fg: beforeFg),
          const Spacer(),
          Text(refund,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: refundColor)),
        ]),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }
}




