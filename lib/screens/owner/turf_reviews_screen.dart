import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TurfReviewsScreen extends StatelessWidget {
  const TurfReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Turf Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Player feedback across all your turfs',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              const Text('4.2',
                  style: TextStyle(fontSize: 46, fontWeight: FontWeight.w800)),
              const StarRating(rating: 4.2, size: 16),
              const SizedBox(height: 4),
              const Text('Based on 128 reviews',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 16),
              _ratingBar(5, 0.60, 77),
              _ratingBar(4, 0.25, 32),
              _ratingBar(3, 0.09, 12),
              _ratingBar(2, 0.04, 5),
              _ratingBar(1, 0.02, 2),
              const Divider(color: AppColors.border, height: 24),
              _catRow('Pitch Quality', 4.5),
              _catRow('Facilities', 4.1),
              _catRow('Cleanliness', 4.3),
              _catRow('Value for Money', 3.9),
            ])),
        AppCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('All Reviews',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _reviewItem(
              initials: 'MK',
              name: 'Mohit Kumar',
              meta: 'Apr 6 - DLF Arena - Cricket 8v8',
              stars: 4,
              text:
                  'Best cricket box in Gurugram. Super clean pitch and great lighting. Parking could be better but overall excellent.',
              tags: ['Great Pitch', 'Clean', 'Good Lighting'],
            ),
            const Divider(color: AppColors.border),
            _reviewItem(
              initials: 'SA',
              name: 'Sahil Arora',
              meta: 'Apr 3 - DLF Arena - Cricket T10',
              stars: 3,
              text:
                  'Good turf. Changing rooms need more space for a full team. The pitch is well maintained though.',
              tags: const [],
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _ratingBar(int star, double pct, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(children: [
        SizedBox(
            width: 18,
            child: Text('$star',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700))),
        Expanded(child: AppProgressBar(value: pct, height: 6)),
        const SizedBox(width: 8),
        SizedBox(
            width: 30,
            child: Text('$count',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 10, color: AppColors.muted))),
      ]),
    );
  }

  Widget _catRow(String name, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: Text(name, style: const TextStyle(fontSize: 12))),
        const Icon(Icons.star, size: 12, color: AppColors.green),
        const SizedBox(width: 3),
        Text(rating.toString(),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }

  Widget _reviewItem({
    required String initials,
    required String name,
    required String meta,
    required int stars,
    required String text,
    required List<String> tags,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppAvatar(
              initials: initials, bg: AppColors.greenLt, fg: AppColors.green),
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
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) => AppBadge.green(tag)).toList(),
          ),
        ],
        const SizedBox(height: 8),
        SmallButton.ghost('Reply', icon: Icons.chat_bubble_outline),
      ]),
    );
  }
}




