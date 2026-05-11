import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class MyTurfsScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  const MyTurfsScreen({super.key, required this.onNavigate});

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
                    Text('My Turfs',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('3 turfs - 2 active - 1 pending',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  ]),
            ),
            PillButton.green('Add Turf',
                icon: Icons.add, onPressed: () => onNavigate('add_turf')),
          ],
        ),
        const SizedBox(height: 14),
        _turfCard('DLF Arena Cricket', 'Sector 29, Gurugram', 'Rs 800', '4.2',
            '128', '75%', true, false),
        _turfCard('Sector 56 Cricket Box', 'Sector 56, Gurugram', 'Rs 600',
            '4.7', '89', '50%', true, false),
        _turfCard('CyberHub Cricket Arena', 'CyberHub, Gurugram', '-', '-', '-',
            '-', false, true),
      ]),
    );
  }

  Widget _turfCard(String name, String location, String price, String rating,
      String reviews, String occupancy, bool active, bool pending) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Opacity(
        opacity: pending ? 0.75 : 1,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? AppColors.dark : AppColors.dark2,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 5),
                      Row(children: [
                        Icon(Icons.location_on,
                            size: 13, color: Colors.white.withOpacity(0.65)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.65))),
                        ),
                      ]),
                    ]),
              ),
              const SizedBox(width: 10),
              StatusBadge(
                  label: active ? 'Active' : 'Pending',
                  type: active ? StatusType.active : StatusType.pending),
            ]),
          ),
          if (!pending) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                _stat(price, 'per hour'),
                _stat(rating, 'rating', color: AppColors.green),
                _stat(reviews, 'reviews'),
                _stat(occupancy, 'filled'),
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                SmallButton.ghost('Slots',
                    icon: Icons.calendar_month,
                    onPressed: () => onNavigate('manage_slots')),
                SmallButton.ghost('Edit',
                    icon: Icons.edit_outlined,
                    onPressed: () => onNavigate('add_turf')),
                SmallButton.ghost('Reviews',
                    icon: Icons.star_outline,
                    onPressed: () => onNavigate('turf_reviews')),
                SmallButton.red('Deactivate', icon: Icons.block),
              ]),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(14),
              child: Row(children: [
                Icon(Icons.access_time, size: 16, color: AppColors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Under review by Turf11 team. Typically takes 24-48 hours.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _stat(String value, String label, {Color? color}) {
    return Expanded(
      child: Column(children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.dark)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 9, color: AppColors.muted)),
      ]),
    );
  }
}




