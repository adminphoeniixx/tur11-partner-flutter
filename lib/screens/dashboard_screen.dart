import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Good morning, Vikram!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.3)),
                const SizedBox(height: 3),
                const Text('Monday, Apr 7 · 3 active turfs · Gurugram', style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
              PillButton.green('Add Turf', icon: Icons.add, onPressed: () => onNavigate('add_turf')),
            ],
          ),
          const SizedBox(height: 20),

          // Stat Grid
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  label: 'Revenue Today',
                  value: '₹12,400',
                  change: '18% vs yesterday',
                  isUp: true,
                  icon: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.greenLt, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.account_balance_wallet, color: AppColors.green, size: 20),
                  ),
                ),
                StatCard(
                  label: 'Bookings Today',
                  value: '24',
                  change: '4 more than yesterday',
                  isUp: true,
                  icon: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.blueLt, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.description_outlined, color: AppColors.blue, size: 20),
                  ),
                ),
                StatCard(
                  label: 'Active Slots',
                  value: '18/36',
                  change: '50% occupancy',
                  isUp: false,
                  icon: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.amberLt, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.people_outline, color: AppColors.amber, size: 20),
                  ),
                ),
                StatCard(
                  label: 'Pending Payouts',
                  value: '₹3,200',
                  change: 'Processing',
                  isUp: false,
                  changeColor: AppColors.muted,
                  icon: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.redLt, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.emoji_events_outlined, color: AppColors.red, size: 20),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),

          // Recent Bookings Table
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Bookings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    PillButton.ghost('View all', onPressed: () => onNavigate('bookings')),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.bg2),
                    headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.6),
                    dataTextStyle: const TextStyle(fontSize: 13, color: AppColors.dark),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('PLAYER')),
                      DataColumn(label: Text('TURF')),
                      DataColumn(label: Text('DATE & TIME')),
                      DataColumn(label: Text('AMOUNT')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('ACTION')),
                    ],
                    rows: [
                      _bookingRow('Rahul Kumar', '+91 9876543210', 'DLF Arena Cricket', 'Apr 7', '7:00–9:00 PM', '₹1,600', StatusType.active, 'Confirmed'),
                      _bookingRow('Arjun Kapoor', '+91 9812345678', 'Sector 56 Box', 'Apr 7', '5:00–7:00 PM', '₹1,200', StatusType.pending, 'Pending Pay'),
                      _bookingRow('Priya Verma', '+91 9876000111', 'DLF Arena Cricket', 'Apr 8', '6:00–8:00 AM', '₹800', StatusType.active, 'Confirmed'),
                      _bookingRow('Sahil Rawat', '+91 9900112233', 'CyberHub Arena', 'Apr 6', '8:00–10:00 PM', '₹0', StatusType.cancelled, 'Cancelled'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions + Occupancy
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

  DataRow _bookingRow(String name, String phone, String turf, String date, String time, String amount, StatusType status, String statusLabel) {
    final amountColor = status == StatusType.cancelled ? AppColors.red : (status == StatusType.pending ? AppColors.amber : AppColors.green);
    return DataRow(cells: [
      DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ])),
      DataCell(Text(turf)),
      DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(time, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ])),
      DataCell(Text(amount, style: TextStyle(fontWeight: FontWeight.w700, color: amountColor))),
      DataCell(StatusBadge(label: statusLabel, type: status)),
      DataCell(SmallButton.ghost('View', onPressed: () => onNavigate('bookings'))),
    ]);
  }

  Widget _quickActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _actionBtn('Add New Turf', Icons.add, AppColors.green, Colors.white, () => onNavigate('add_turf')),
          const SizedBox(height: 8),
          _actionBtn('Manage Slots', Icons.calendar_month, AppColors.white, AppColors.dark, () => onNavigate('manage_slots'), outlined: true),
          const SizedBox(height: 8),
          _actionBtn('Create Tournament', Icons.emoji_events_outlined, AppColors.white, AppColors.dark, () => onNavigate('add_tournament'), outlined: true),
          const SizedBox(height: 8),
          _actionBtn('View Payments', Icons.account_balance_wallet_outlined, AppColors.white, AppColors.dark, () => onNavigate('payments'), outlined: true),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color bg, Color fg, VoidCallback onTap, {bool outlined = false}) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: outlined ? BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1.5)) : null,
          child: Row(
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _occupancy() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Occupancy", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(pct, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        AppProgressBar(value: value, color: color),
      ],
    );
  }
}
