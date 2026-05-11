import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TourneyRegistrationsScreen extends StatelessWidget {
  const TourneyRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Team Registrations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Gurugram T10 Cup - 8/16 teams registered',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 14),
          AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Registration Progress',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const Text('8 / 16 Teams',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green)),
                    ]),
                const SizedBox(height: 8),
                const AppProgressBar(value: 0.5, height: 10),
                const SizedBox(height: 6),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('8 slots remaining',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.muted)),
                      Text('Closes Apr 10',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.muted)),
                    ]),
              ])),
          AppCard(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Teams',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _teamCard('1', 'Sector 29 Warriors', 'Rahul Kumar', '9876543210',
                  '12', 'Rs 529', StatusType.active, 'Paid'),
              _teamCard('2', 'Galaxy XI', 'Arjun Mehta', '9812345678', '11',
                  'Rs 529', StatusType.active, 'Paid'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _teamCard(String num, String team, String captain, String phone,
      String players, String fee, StatusType status, String statusLabel) {
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
          AppAvatar(initials: num, size: 34, bg: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text('$captain - $phone',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
              ])),
          StatusBadge(label: statusLabel, type: status),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text('$players players',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600))),
          Text(fee,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green)),
          const SizedBox(width: 10),
          SmallButton.ghost('View'),
        ]),
      ]),
    );
  }
}




