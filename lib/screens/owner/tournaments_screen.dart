import 'package:flutter/material.dart';

import '../../controllers/tournament_controller.dart';
import '../../models/tournament_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TournamentsScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;
  const TournamentsScreen({super.key, required this.onNavigate});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  final TournamentController _controller = TournamentController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = _controller.tournaments;

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: compact ? constraints.maxWidth : constraints.maxWidth - 150,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tournaments',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text(_summaryText(tournaments),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ]),
                  ),
                  PillButton.green('Add Tournament',
                      icon: Icons.add,
                      onPressed: () => widget.onNavigate('add_tournament')),
                ],
              );
            }),
            if (_controller.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(_controller.errorMessage!,
                  style: const TextStyle(color: AppColors.red, fontSize: 12)),
            ],
            const SizedBox(height: 14),
            if (_controller.isLoading && tournaments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (tournaments.isEmpty)
              const SizedBox(
                width: double.infinity,
                child: AppCard(
                  padding: EdgeInsets.all(12),
                  child: Text('No tournaments found.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ),
              )
            else
              ...tournaments.map(_tournamentCard),
          ],
        ),
      ),
    );
  }

  Widget _tournamentCard(TournamentItem tournament) {
    final id = tournament.id;
    return SizedBox(
      width: double.infinity,
      child: AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tournament.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(tournament.turfName,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
          ),
          _status(tournament.status),
        ]),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final itemWidth = constraints.maxWidth < 330
              ? constraints.maxWidth
              : (constraints.maxWidth - 16) / 3;
          return Wrap(spacing: 8, runSpacing: 10, children: [
            SizedBox(width: itemWidth, child: _mini('Dates', tournament.datesLabel)),
            SizedBox(width: itemWidth, child: _mini('Teams', tournament.teamsLabel)),
            SizedBox(
                width: itemWidth,
                child: _mini('Prize', tournament.prizeTotal,
                    color: AppColors.green)),
          ]);
        }),
        const SizedBox(height: 12),
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 8, children: [
          Text('Revenue ${tournament.revenue}',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          SmallButton.ghost('Teams',
              onPressed: () => widget.onNavigate('tourney_registrations')),
          SmallButton.ghost('Actions',
              onPressed:
                  id == null || _controller.isSaving ? null : () => _showActions(tournament)),
        ]),
      ]),
      ),
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

  Widget _status(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('complete')) {
      return const StatusBadge(label: 'Completed', type: StatusType.completed);
    }
    if (normalized.contains('open') || normalized.contains('registration')) {
      return const StatusBadge(label: 'Reg. Open', type: StatusType.pending);
    }
    if (normalized.contains('cancel')) {
      return const StatusBadge(label: 'Cancelled', type: StatusType.cancelled);
    }
    return AppBadge(label: _label(value), bg: AppColors.border, fg: AppColors.muted);
  }

  Future<void> _showActions(TournamentItem tournament) async {
    final id = tournament.id;
    if (id == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              12 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Wrap(runSpacing: 8, children: [
              ListTile(
                leading: const Icon(Icons.how_to_reg_outlined),
                title: const Text('Open Registration'),
                onTap: () {
                  Navigator.pop(context);
                  _runAction(_controller.openRegistration(id),
                      'Registration opened.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: const Text('Generate Fixtures'),
                onTap: () {
                  Navigator.pop(context);
                  _runAction(_controller.generateFixtures(id),
                      'Fixtures generated.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.scoreboard_outlined),
                title: const Text('Record Match Result'),
                onTap: () {
                  Navigator.pop(context);
                  _showRecordResultDialog(id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events_outlined),
                title: const Text('Complete Tournament'),
                onTap: () {
                  Navigator.pop(context);
                  _showCompleteDialog(id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.rate_review_outlined),
                title: const Text('Reviews'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate('tourney_reviews');
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _showRecordResultDialog(int tournamentId) async {
    final matchNo = TextEditingController(text: '1');
    final scoreA = TextEditingController(text: '156/4');
    final oversA = TextEditingController(text: '10.0');
    final scoreB = TextEditingController(text: '132/8');
    final oversB = TextEditingController(text: '10.0');
    final winnerId = TextEditingController(text: '3');
    final winnerName = TextEditingController();
    final resultText = TextEditingController();

    final request = await showDialog<RecordTournamentResultRequest>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Record Result'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field('Match No', matchNo, TextInputType.number),
              _field('Score A', scoreA),
              _field('Overs A', oversA),
              _field('Score B', scoreB),
              _field('Overs B', oversB),
              _field('Winner Team ID', winnerId, TextInputType.number),
              _field('Winner Name', winnerName),
              _field('Result Text', resultText),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                RecordTournamentResultRequest(
                  matchNo: int.tryParse(matchNo.text) ?? 1,
                  scoreA: scoreA.text,
                  oversA: oversA.text,
                  scoreB: scoreB.text,
                  oversB: oversB.text,
                  winnerId: int.tryParse(winnerId.text) ?? 0,
                  winnerName: winnerName.text,
                  resultText: resultText.text,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    disposeDialogControllers([
      matchNo,
      scoreA,
      oversA,
      scoreB,
      oversB,
      winnerId,
      winnerName,
      resultText,
    ]);

    if (request == null) return;
    _runAction(
      _controller.recordResult(tournamentId, request),
      'Match result recorded.',
    );
  }

  Future<void> _showCompleteDialog(int tournamentId) async {
    final winnerTeamId = TextEditingController(text: '3');
    final winnerName = TextEditingController();
    final runnerTeamId = TextEditingController(text: '5');
    final runnerName = TextEditingController();

    final request = await showDialog<CompleteTournamentRequest>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Complete Tournament'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field('Winner Team ID', winnerTeamId, TextInputType.number),
              _field('Winner Name', winnerName),
              _field('Runner Team ID', runnerTeamId, TextInputType.number),
              _field('Runner Name', runnerName),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                CompleteTournamentRequest(
                  winnerTeamId: int.tryParse(winnerTeamId.text) ?? 0,
                  winnerName: winnerName.text,
                  runnerTeamId: int.tryParse(runnerTeamId.text) ?? 0,
                  runnerName: runnerName.text,
                ),
              ),
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    disposeDialogControllers([
      winnerTeamId,
      winnerName,
      runnerTeamId,
      runnerName,
    ]);

    if (request == null) return;
    _runAction(_controller.complete(tournamentId, request), 'Tournament completed.');
  }

  Widget _field(String label, TextEditingController controller,
      [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _runAction(Future<bool> action, String successMessage) async {
    final saved = await action;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved
            ? successMessage
            : _controller.errorMessage ?? 'Unable to save tournament changes.'),
        backgroundColor: saved ? AppColors.green : AppColors.red,
      ),
    );
  }

  String _summaryText(List<TournamentItem> tournaments) {
    final active = tournaments
        .where((item) => item.status.toLowerCase().contains('active'))
        .length;
    final completed = tournaments
        .where((item) => item.status.toLowerCase().contains('complete'))
        .length;
    final upcoming = tournaments.length - active - completed;
    return '$active active - $upcoming upcoming - $completed completed';
  }

  String _label(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return 'Upcoming';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) =>
            '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
