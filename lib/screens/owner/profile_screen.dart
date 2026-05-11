import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    Text('Business Profile',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Manage your owner account details',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  ]),
            ),
            PillButton.green('Edit Profile', icon: Icons.edit),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              AppAvatar(initials: 'VS', size: 60, bg: AppColors.dark),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vikram Singh',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Turf Owner - Gurugram',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
                    ]),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              const StatusBadge(label: 'Verified', type: StatusType.active),
              AppBadge.amber('Pro Owner'),
            ]),
            const Divider(color: AppColors.border, height: 26),
            _infoRow(Icons.smartphone, '+91 9876543210'),
            _infoRow(Icons.email_outlined, 'vikram@dlfarena.com'),
            _infoRow(Icons.location_on_outlined, 'Gurugram, Haryana'),
            _infoRow(Icons.business, 'DLF Sports Arena Pvt. Ltd.'),
          ]),
        ),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Notification Preferences',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            ToggleRow(label: 'New booking alerts', value: true),
            Divider(color: AppColors.border),
            ToggleRow(label: 'Payment received', value: true),
            Divider(color: AppColors.border),
            ToggleRow(label: 'Cancellation alerts', value: true),
            Divider(color: AppColors.border),
            ToggleRow(label: 'New reviews', value: true),
          ]),
        ),
        AppCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Business Stats',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.85,
              children: [
                _miniStat('Total Turfs', '3'),
                _miniStat('Bookings', '486'),
                _miniStat('Revenue', 'Rs 1.24L', color: AppColors.green),
                _miniStat('Rating', '4.2', color: AppColors.green),
              ],
            ),
          ]),
        ),
        AppCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bank & Payment Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _bankRow('UPI ID', 'vikram@paytm'),
            _bankRow('Bank', 'HDFC Bank ****4521'),
            _bankRow('GST', '29AAAAA0000A1Z5'),
            _bankRow('PAN', 'ABCDE1234F'),
            const SizedBox(height: 12),
            PillButton.ghost('Update Banking Details', icon: Icons.edit),
          ]),
        ),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        const Spacer(),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.dark)),
      ]),
    );
  }

  Widget _bankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}




