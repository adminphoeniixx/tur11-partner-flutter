import 'package:flutter/material.dart';

import '../../controllers/tournament_controller.dart';
import '../../models/tournament_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TourneyRegistrationsScreen extends StatefulWidget {
  const TourneyRegistrationsScreen({super.key});

  @override
  State<TourneyRegistrationsScreen> createState() =>
      _TourneyRegistrationsScreenState();
}

class _TourneyRegistrationsScreenState
    extends State<TourneyRegistrationsScreen> {
  final TournamentController _tournamentController = TournamentController();
  final TournamentTeamsController _teamsController = TournamentTeamsController();
  int? _selectedTournamentId;

  @override
  void initState() {
    super.initState();
    _tournamentController.addListener(_onChanged);
    _teamsController.addListener(_onChanged);
    _loadInitial();
  }

  @override
  void dispose() {
    _tournamentController.removeListener(_onChanged);
    _teamsController.removeListener(_onChanged);
    _tournamentController.dispose();
    _teamsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final loaded = await _tournamentController.load();
    if (!mounted || !loaded) return;
    final tournaments =
        _tournamentController.tournaments.where((item) => item.id != null);
    if (tournaments.isEmpty) return;
    _selectedTournamentId = tournaments.first.id;
    await _loadTeams();
  }

  Future<bool> _loadTeams() async {
    final id = _selectedTournamentId;
    if (id == null) return false;
    return _teamsController.load(id);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tournament = _selectedTournament();
    final teams = _teamsController.teams;
    final progress = tournament?.registrationProgress ?? 0;
    final maxTeams = tournament?.maxTeams ?? 0;
    final registered = tournament?.registeredTeams ?? teams.length;

    return RefreshIndicator(
      onRefresh: () async {
        await _tournamentController.load();
        await _loadTeams();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Team Registrations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(
              tournament == null
                  ? 'Select a tournament'
                  : '${tournament.name} - $registered/$maxTeams teams registered',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            if (_tournamentController.errorMessage != null ||
                _teamsController.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _teamsController.errorMessage ??
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
                child: Column(children: [
                  Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        const Text('Registration Progress',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('$registered / $maxTeams Teams',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green)),
                      ]),
                  const SizedBox(height: 8),
                  AppProgressBar(value: progress, height: 10),
                  const SizedBox(height: 6),
                  Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text('${(maxTeams - registered).clamp(0, maxTeams)} slots remaining',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                        Text(tournament?.startDateLabel ?? '-',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ]),
                ]),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Teams',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    if (_teamsController.isLoading && teams.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (teams.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No teams registered yet.',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.muted)),
                      )
                    else
                      ...List.generate(
                          teams.length,
                          (index) =>
                              _teamCard((index + 1).toString(), teams[index])),
                  ]),
              ),
            ),
          ],
        ),
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
          await _loadTeams();
        },
      ),
    );
  }

  Widget _teamCard(String number, TournamentTeamItem team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppAvatar(initials: number, size: 34, bg: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(team.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text('${team.captainName} - ${team.phone}',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
              ])),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child:
                StatusBadge(label: _label(team.status), type: _status(team.status)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text('${team.players} players',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600))),
          Text(team.fee,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green)),
        ]),
      ]),
    );
  }

  TournamentItem? _selectedTournament() {
    for (final tournament in _tournamentController.tournaments) {
      if (tournament.id == _selectedTournamentId) return tournament;
    }
    return null;
  }

  StatusType _status(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('pending')) return StatusType.pending;
    if (normalized.contains('cancel') || normalized.contains('fail')) {
      return StatusType.cancelled;
    }
    if (normalized.contains('complete')) return StatusType.completed;
    return StatusType.active;
  }

  String _label(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return '-';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) =>
            '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
