import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TournamentsScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  const TournamentsScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      Text('Tournaments',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('2 active - 1 upcoming - 5 completed',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
                    ]),
              ),
              PillButton.green('Add Tournament',
                  icon: Icons.add, onPressed: () => onNavigate('add_tournament')),
            ],
          ),
          const SizedBox(height: 14),
          _tournamentCard(
            title: 'Gurugram T10 Cup',
            venue: 'DLF Arena Cricket',
            dates: 'Apr 12-20',
            duration: '9 days',
            teams: '8/16',
            prize: 'Rs 5,000',
            revenue: 'Rs 4,232',
            status: const StatusBadge(
                label: 'Reg. Open', type: StatusType.pending),
            primaryAction: SmallButton.ghost('Teams',
                onPressed: () => onNavigate('tourney_registrations')),
            secondaryAction: SmallButton.ghost('Edit'),
          ),
          _tournamentCard(
            title: 'Sector 56 Blasters',
            venue: 'Sector 56 Box',
            dates: 'Apr 19-26',
            duration: '8 days',
            teams: '0/8',
            prize: 'Rs 3,000',
            revenue: 'Rs 0',
            status: AppBadge(
                label: 'Upcoming', bg: AppColors.border, fg: AppColors.muted),
            primaryAction: SmallButton.ghost('Edit'),
            secondaryAction: SmallButton.red('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _tournamentCard({
    required String title,
    required String venue,
    required String dates,
    required String duration,
    required String teams,
    required String prize,
    required String revenue,
    required Widget status,
    required Widget primaryAction,
    required Widget secondaryAction,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(venue,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
          ),
          status,
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _mini('Dates', '$dates\n$duration')),
          Expanded(child: _mini('Teams', teams)),
          Expanded(child: _mini('Prize', prize, color: AppColors.green)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text('Revenue $revenue',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700))),
          primaryAction,
          const SizedBox(width: 8),
          secondaryAction,
        ]),
      ]),
    );
  }

  Widget _mini(String label, String value, {Color? color}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: AppColors.muted)),
      const SizedBox(height: 3),
      Text(value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    ]);
  }
}




