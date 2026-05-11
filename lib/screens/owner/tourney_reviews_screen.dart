import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TourneyReviewsScreen extends StatelessWidget {
  const TourneyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tournament Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Team feedback for your tournaments',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Team Reviews',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _review(
              initials: 'GX',
              avBg: AppColors.amberLt,
              avFg: AppColors.amber,
              name: 'Galaxy XI',
              meta: 'Apr 22 - Finished 3rd',
              stars: 5,
              text:
                  'Fantastic event. Well organised with fair umpiring throughout. Will definitely join next season.',
            ),
            const Divider(color: AppColors.border),
            _review(
              initials: 'S9',
              avBg: AppColors.greenLt,
              avFg: AppColors.green,
              name: 'Sector 9 Strikers',
              meta: 'Apr 21 - Runners-up',
              stars: 4,
              text:
                  'Good event but scheduling was chaotic on day 3. Prize money was paid within 2 days though.',
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _review({
    required String initials,
    required Color avBg,
    required Color avFg,
    required String name,
    required String meta,
    required int stars,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppAvatar(initials: initials, bg: avBg, fg: avFg),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                Text(meta,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
              ])),
          StarRating(rating: stars.toDouble()),
        ]),
        const SizedBox(height: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.dark2, height: 1.55)),
      ]),
    );
  }
}




