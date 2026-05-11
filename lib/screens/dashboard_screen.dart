import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12, 12, 12, isPhone ? 78 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isPhone ? double.infinity : 280,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Vikram!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Monday, Apr 7 - 3 active turfs - Gurugram',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              PillButton.green(
                'Add Turf',
                icon: Icons.add,
                onPressed: () => onNavigate('add_turf'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, constraints) {
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
                  value: 'Rs 12,400',
                  change: '18% vs yesterday',
                  icon: _statIcon(
                    Icons.account_balance_wallet,
                    AppColors.greenLt,
                    AppColors.green,
                  ),
                ),
                StatCard(
                  label: 'Bookings Today',
                  value: '24',
                  change: '4 more than yesterday',
                  icon: _statIcon(
                    Icons.description_outlined,
                    AppColors.blueLt,
                    AppColors.blue,
                  ),
                ),
                StatCard(
                  label: 'Active Slots',
                  value: '18/36',
                  change: '50% occupancy',
                  isUp: false,
                  icon: _statIcon(
                    Icons.people_outline,
                    AppColors.amberLt,
                    AppColors.amber,
                  ),
                ),
                StatCard(
                  label: 'Pending Payouts',
                  value: 'Rs 3,200',
                  change: 'Processing',
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
          }),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Bookings',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    PillButton.ghost(
                      'View all',
                      onPressed: () => onNavigate('bookings'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _bookingCard(
                  'Rahul Kumar',
                  '+91 9876543210',
                  'DLF Arena Cricket',
                  'Apr 7',
                  '7:00-9:00 PM',
                  'Rs 1,600',
                  StatusType.active,
                  'Confirmed',
                  'RK',
                ),
                _bookingCard(
                  'Arjun Kapoor',
                  '+91 9812345678',
                  'Sector 56 Box',
                  'Apr 7',
                  '5:00-7:00 PM',
                  'Rs 1,200',
                  StatusType.pending,
                  'Pending Pay',
                  'AK',
                ),
                _bookingCard(
                  'Priya Verma',
                  '+91 9876000111',
                  'DLF Arena Cricket',
                  'Apr 8',
                  '6:00-8:00 AM',
                  'Rs 800',
                  StatusType.active,
                  'Confirmed',
                  'PV',
                ),
              ],
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _quickActions()),
                  const SizedBox(width: 16),
                  Expanded(child: _occupancy()),
                ],
              );
            }
            return Column(children: [_quickActions(), _occupancy()]);
          }),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(initials: initials, size: 34, bg: AppColors.dark),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      phone,
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: statusLabel, type: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  turf,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$date, $time',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _actionBtn('Add New Turf', Icons.add, AppColors.green, Colors.white,
              () => onNavigate('add_turf')),
          const SizedBox(height: 8),
          _actionBtn('Manage Slots', Icons.calendar_month, AppColors.white,
              AppColors.dark, () => onNavigate('manage_slots'),
              outlined: true),
          const SizedBox(height: 8),
          _actionBtn('Create Tournament', Icons.emoji_events_outlined,
              AppColors.white, AppColors.dark, () => onNavigate('add_tournament'),
              outlined: true),
          const SizedBox(height: 8),
          _actionBtn('View Payments', Icons.account_balance_wallet_outlined,
              AppColors.white, AppColors.dark, () => onNavigate('payments'),
              outlined: true),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color bg, Color fg,
      VoidCallback onTap,
      {bool outlined = false}) {
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
          child: Row(
            children: [
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _occupancy() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Occupancy",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _occRow('DLF Arena Cricket', 0.75, '75%', AppColors.green),
          const SizedBox(height: 10),
          _occRow('Sector 56 Box', 0.50, '50%', AppColors.amber),
          const SizedBox(height: 10),
          _occRow('CyberHub Arena', 0.25, '25%', AppColors.red),
        ],
      ),
    );
  }

  Widget _occRow(String name, double value, String pct, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              pct,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppProgressBar(value: value, color: color),
      ],
    );
  }
}




