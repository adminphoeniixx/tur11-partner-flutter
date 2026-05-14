import 'package:flutter/material.dart';

import '../../controllers/review_controller.dart';
import '../../models/review_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TurfReviewsScreen extends StatefulWidget {
  const TurfReviewsScreen({super.key});

  @override
  State<TurfReviewsScreen> createState() => _TurfReviewsScreenState();
}

class _TurfReviewsScreenState extends State<TurfReviewsScreen> {
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
    final summary = _controller.summary;
    final reviews = _controller.turfReviews;

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Turf Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Player feedback across all your turfs',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          _summaryCard(summary),
          SizedBox(
            width: double.infinity,
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All Reviews',
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
                          'No reviews found.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      )
                    else
                      ...List.generate(reviews.length, (index) {
                        return Column(children: [
                          _reviewItem(reviews[index]),
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

  Widget _summaryCard(ReviewSummary summary) {
    final total = summary.totalReviews == 0 ? 1 : summary.totalReviews;

    return AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Text(summary.averageRating.toStringAsFixed(1),
              style:
                  const TextStyle(fontSize: 46, fontWeight: FontWeight.w800)),
          StarRating(rating: summary.averageRating, size: 16),
          const SizedBox(height: 4),
          Text('Based on ${summary.totalReviews} reviews',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final star = 5 - index;
            final count = summary.ratingCounts[star] ?? 0;
            return _ratingBar(star, count / total, count);
          }),
          if (summary.categories.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 24),
            ...summary.categories.entries
                .map((entry) => _catRow(entry.key, entry.value)),
          ],
        ]));
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
        Text(rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }

  Widget _reviewItem(ReviewItem review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppAvatar(
              initials: review.initials,
              bg: AppColors.greenLt,
              fg: AppColors.green),
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
        if (review.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: review.tags.map((tag) => AppBadge.green(tag)).toList(),
          ),
        ],
        if (review.reply != null && review.reply!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Reply: ${review.reply}',
              softWrap: true,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
        const SizedBox(height: 8),
        SmallButton.ghost(
          _controller.isSaving ? 'Saving...' : 'Reply',
          icon: Icons.chat_bubble_outline,
          onPressed:
              review.id == null || _controller.isSaving ? null : () => _reply(review),
        ),
      ]),
    );
  }

  Future<void> _reply(ReviewItem review) async {
    final textController = TextEditingController(text: review.reply ?? '');
    final reply = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to Review'),
          content: TextField(
            controller: textController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Write your reply'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
    textController.dispose();

    if (reply == null || reply.trim().isEmpty || review.id == null) return;
    final saved = await _controller.replyToReview(review.id!, reply);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved
            ? 'Reply saved.'
            : _controller.errorMessage ?? 'Unable to save reply.'),
        backgroundColor: saved ? AppColors.green : AppColors.red,
      ),
    );
  }
}
