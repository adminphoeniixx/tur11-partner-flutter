import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                const Text('8 unread notifications', style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
              PillButton.ghost('Mark all read', onPressed: () {}),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                _notifItem(Icons.description_outlined, AppColors.greenLt, AppColors.green, 'New Booking — DLF Arena Cricket',
                    'Rahul Kumar booked Apr 7, 7:00–9:00 PM (16 players). ₹1,600 collected.', '5 min ago', true),
                _divider(),
                _notifItem(Icons.account_balance_wallet, AppColors.amberLt, AppColors.amber, 'Payment Pending — Arjun Kapoor',
                    '₹1,200 for Sector 56 Box (Apr 7, 5 PM) is still pending. Auto-reminder sent.', '30 min ago', true),
                _divider(),
                _notifItem(Icons.cancel_outlined, AppColors.redLt, AppColors.red, 'Booking Cancelled — Sahil Rawat',
                    'Apr 6, 8–10 PM (CyberHub Arena). Cancellation within 2h — no refund issued.', '2h ago', true),
                _divider(),
                _notifItem(Icons.star_outline, AppColors.blueLt, AppColors.blue, 'New Review — 4.5 ★ DLF Arena',
                    '"Great pitch, well maintained. Parking could be improved." — Mohit Kumar', 'Yesterday 3 PM', false),
                _divider(),
                _notifItem(Icons.emoji_events_outlined, AppColors.greenLt, AppColors.green, 'Tournament Registration — Sector 29 Warriors',
                    'Team registered for Gurugram T10 Cup. ₹529 entry fee received.', 'Yesterday 11 AM', false),
                _divider(),
                _notifItem(Icons.check_circle_outline, AppColors.greenLt, AppColors.green, 'Verification Complete',
                    'DLF Arena Cricket has been verified and is live on Turf11. Start accepting bookings!', '2 days ago', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifItem(IconData icon, Color iconBg, Color iconColor, String title, String body, String time, bool unread) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unread)
            Container(width: 7, height: 7, margin: const EdgeInsets.only(top: 5, right: 8), decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle))
          else
            const SizedBox(width: 15),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5)),
                const SizedBox(height: 5),
                Text(time, style: const TextStyle(fontSize: 11, color: AppColors.muted2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 0, color: AppColors.border);
}
