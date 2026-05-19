import 'package:flutter/material.dart';

import '../../controllers/tournament_controller.dart';
import '../../models/review_models.dart';
import '../../models/tournament_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TourneyReviewsScreen extends StatefulWidget {
  const TourneyReviewsScreen({super.key});

  @override
  State<TourneyReviewsScreen> createState() => _TourneyReviewsScreenState();
}

class _TourneyReviewsScreenState extends State<TourneyReviewsScreen> {
  final TournamentController _tournamentController = TournamentController();
  final TournamentReviewsController _reviewsController =
      TournamentReviewsController();
  int? _selectedTournamentId;

  @override
  void initState() {
    super.initState();
    _tournamentController.addListener(_onChanged);
    _reviewsController.addListener(_onChanged);
    _loadInitial();
  }

  @override
  void dispose() {
    _tournamentController.removeListener(_onChanged);
    _reviewsController.removeListener(_onChanged);
    _tournamentController.dispose();
    _reviewsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final loaded = await _tournamentController.load();
    if (!mounted || !loaded) return;
    final tournaments =
        _tournamentController.tournaments.where((item) => item.id != null);
    if (tournaments.isEmpty) return;
    _selectedTournamentId = tournaments.first.id;
    await _loadReviews();
  }

  Future<bool> _loadReviews() async {
    final id = _selectedTournamentId;
    if (id == null) return false;
    return _reviewsController.load(id);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviewsController.reviews;

    return RefreshIndicator(
      onRefresh: () async {
        await _tournamentController.load();
        await _loadReviews();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tournament Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(_selectedTournament()?.name ?? 'Team feedback for your tournaments',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_tournamentController.errorMessage != null ||
              _reviewsController.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _reviewsController.errorMessage ??
                  _tournamentController.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          _tournamentPicker(),
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
                    if (_reviewsController.isLoading && reviews.isEmpty)
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

  Widget _tournamentPicker() {
    final tournaments =
        _tournamentController.tournaments.where((item) => item.id != null);
    if (tournaments.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(labelText: 'Tournament'),
        value: tournaments.any((item) => item.id == _selectedTournamentId)
            ? _selectedTournamentId
            : null,
        items: tournaments
            .map((item) =>
                DropdownMenuItem(
                    value: item.id,
                    child: Text(item.name, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (value) async {
          if (value == null) return;
          setState(() => _selectedTournamentId = value);
          await _loadReviews();
        },
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

  TournamentItem? _selectedTournament() {
    for (final tournament in _tournamentController.tournaments) {
      if (tournament.id == _selectedTournamentId) return tournament;
    }
    return null;
  }
}
