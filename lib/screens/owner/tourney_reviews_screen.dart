import 'package:flutter/material.dart';

import '../../controllers/review_controller.dart';
import '../../models/review_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TourneyReviewsScreen extends StatefulWidget {
  const TourneyReviewsScreen({super.key});

  @override
  State<TourneyReviewsScreen> createState() => _TourneyReviewsScreenState();
}

class _TourneyReviewsScreenState extends State<TourneyReviewsScreen> {
  final ReviewController _controller = ReviewController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onReviewsChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onReviewsChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onReviewsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _controller.tournamentReviews;

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tournament Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Team feedback for your tournaments',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Team Reviews',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    if (_controller.isLoading && reviews.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No tournament reviews found.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      )
                    else
                      ...List.generate(reviews.length, (index) {
                        return Column(children: [
                          _review(reviews[index]),
                          if (index != reviews.length - 1)
                            const Divider(color: AppColors.border),
                        ]);
                      }),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _review(ReviewItem review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppAvatar(
              initials: review.initials,
              bg: AppColors.amberLt,
              fg: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(review.reviewerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                Text(review.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
              ])),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: StarRating(rating: review.rating),
          ),
        ]),
        const SizedBox(height: 8),
        Text(review.text,
            softWrap: true,
            style: const TextStyle(
                fontSize: 13, color: AppColors.dark2, height: 1.55)),
      ]),
    );
  }
}
