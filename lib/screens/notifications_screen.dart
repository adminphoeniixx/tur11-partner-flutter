import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
              width: 220,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('8 unread notifications',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  ]),
            ),
            PillButton.ghost('Mark all read', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            _notifItem(Icons.description_outlined, AppColors.greenLt,
                AppColors.green, 'New Booking - DLF Arena Cricket',
                'Rahul Kumar booked Apr 7, 7:00-9:00 PM. Rs 1,600 collected.',
                '5 min ago', true),
            _divider(),
            _notifItem(Icons.account_balance_wallet, AppColors.amberLt,
                AppColors.amber, 'Payment Pending - Arjun Kapoor',
                'Rs 1,200 for Sector 56 Box is still pending. Reminder sent.',
                '30 min ago', true),
            _divider(),
            _notifItem(Icons.cancel_outlined, AppColors.redLt, AppColors.red,
                'Booking Cancelled - Sahil Rawat',
                'CyberHub Arena booking cancelled within 2h. No refund issued.',
                '2h ago', true),
            _divider(),
            _notifItem(Icons.star_outline, AppColors.blueLt, AppColors.blue,
                'New Review - 4.5 DLF Arena',
                'Great pitch and well maintained. Parking could improve.',
                'Yesterday 3 PM', false),
            _divider(),
            _notifItem(Icons.emoji_events_outlined, AppColors.greenLt,
                AppColors.green, 'Tournament Registration',
                'Sector 29 Warriors registered for Gurugram T10 Cup.',
                'Yesterday 11 AM', false),
          ]),
        ),
      ]),
    );
  }

  Widget _notifItem(IconData icon, Color iconBg, Color iconColor, String title,
      String body, String time, bool unread) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (unread)
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration:
                const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
          )
        else
          const SizedBox(width: 15),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(body,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.muted, height: 1.45)),
            const SizedBox(height: 5),
            Text(time,
                style: const TextStyle(fontSize: 11, color: AppColors.muted2)),
          ]),
        ),
      ]),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.border);
}





