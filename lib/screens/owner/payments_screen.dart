import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SizedBox(
              width: 230,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payments',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Revenue & payout tracking',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  ]),
            ),
            PillButton.ghost('Export CSV', icon: Icons.upload),
          ],
        ),
        const SizedBox(height: 14),
        _stats(),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Payment Transactions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _txnCard('TXN-8821042', 'Booking', AppColors.greenLt,
                AppColors.green, 'Rahul Kumar', 'Rs 1,600', '-Rs 80',
                'Rs 1,520', AppColors.green, 'Apr 7', StatusType.active,
                'Settled'),
            _txnCard('TXN-8821040', 'Tournament', AppColors.blueLt,
                AppColors.blue, 'Sector 29 Warriors', 'Rs 529', '-Rs 26',
                'Rs 503', AppColors.green, 'Apr 5', StatusType.active,
                'Settled'),
            _txnCard('TXN-8821038', 'Refund', AppColors.redLt, AppColors.red,
                'Sahil Rawat', '-Rs 600', '-', '-Rs 600', AppColors.red,
                'Apr 6', StatusType.cancelled, 'Refunded'),
            _txnCard('TXN-8821035', 'Booking', AppColors.greenLt,
                AppColors.green, 'Arjun Kapoor', 'Rs 1,200', '-', 'Pending',
                AppColors.amber, 'Apr 7', StatusType.pending, 'Pending'),
          ]),
        ),
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
              label: 'Total Revenue',
              value: 'Rs 1.24L',
              change: '+18% vs Mar'),
          StatCard(
              label: 'Settled',
              value: 'Rs 1.16L',
              change: 'Last payout Apr 1',
              changeColor: AppColors.muted),
          StatCard(
              label: 'Pending',
              value: 'Rs 7,200',
              change: 'Processing',
              isUp: false,
              changeColor: AppColors.amber),
          StatCard(
              label: 'Platform Fee',
              value: 'Rs 6,200',
              change: 'Deducted',
              isUp: false,
              changeColor: AppColors.muted),
        ],
      );
    });
  }

  Widget _txnCard(
    String id,
    String type,
    Color typeBg,
    Color typeFg,
    String name,
    String amount,
    String fee,
    String net,
    Color netColor,
    String date,
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
          AppBadge(label: type, bg: typeBg, fg: typeFg),
          const SizedBox(width: 8),
          Expanded(
              child: Text(id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted))),
          StatusBadge(label: statusLabel, type: status),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700))),
          Text(net,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: netColor)),
        ]),
        const SizedBox(height: 4),
        Text('$date - Amount $amount - Fee $fee',
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }
}




