import 'package:flutter/material.dart';

import '../../controllers/match_controller.dart';
import '../../controllers/slot_controller.dart';
import '../../controllers/turf_controller.dart';
import '../../models/match_models.dart';
import '../../models/slot_models.dart';
import '../../models/turf_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ManageSlotsScreen extends StatefulWidget {
  const ManageSlotsScreen({super.key});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  final MatchController _matchController = MatchController();
  final SlotController _slotController = SlotController();
  final TurfController _turfController = TurfController();
  final Set<int> _selectedSlotIds = {};
  DateTime _selectedDate = DateTime.now();
  int? _selectedTurfId;

  @override
  void initState() {
    super.initState();
    _matchController.addListener(_onMatchesChanged);
    _slotController.addListener(_onSlotsChanged);
    _turfController.addListener(_onTurfsChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _matchController.removeListener(_onMatchesChanged);
    _slotController.removeListener(_onSlotsChanged);
    _turfController.removeListener(_onTurfsChanged);
    _matchController.dispose();
    _slotController.dispose();
    _turfController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _matchController.load();
    final loadedTurfs = await _turfController.load();
    if (!mounted) return;
    final availableTurfs = loadedTurfs
        ? _turfController.turfs.where((turf) => turf.id != null)
        : const Iterable<TurfItem>.empty();
    final firstTurf = availableTurfs.isEmpty ? null : availableTurfs.first;
    _selectedTurfId = firstTurf?.id ?? 1;
    await _loadSlots();
  }

  void _onMatchesChanged() {
    if (mounted) setState(() {});
  }

  void _onSlotsChanged() {
    if (mounted) setState(() {});
  }

  void _onTurfsChanged() {
    if (mounted) setState(() {});
  }

  Future<bool> _loadSlots() async {
    final turfId = _selectedTurfId;
    if (turfId == null) return false;
    _selectedSlotIds.clear();
    return _slotController.load(turfId: turfId, date: _apiDate(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _matchController.load(),
          _turfController.load(),
          _loadSlots(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manage Slots',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('${_formatDisplayDate(_selectedDate)} - ${_selectedTurfName()}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_slotController.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_slotController.errorMessage!,
                style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ],
          const SizedBox(height: 18),
          _slotsCard(),
          _matchesCard(),
          AppCard(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dynamic Pricing Rules',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _priceBox('Weekday', 'Rs 800'),
              const SizedBox(height: 10),
              _priceBox('Weekend', 'Rs 1,000'),
              const SizedBox(height: 10),
              _priceBox('Peak Hours', 'Rs 1,200'),
              const SizedBox(height: 14),
              const ToggleRow(
                  label: 'Dynamic surge pricing',
                  subtitle: 'Auto-increase price when more than 80% booked',
                  value: true),
              const Divider(color: AppColors.border),
              const ToggleRow(
                  label: 'Last-minute discount',
                  subtitle: '20% off unsold slots 1h before start time',
                  value: false),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _slotsCard() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Slot Inventory',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  _selectedSlotIds.isEmpty
                      ? 'Tap available or blocked slots to select them.'
                      : '${_selectedSlotIds.length} selected',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (_slotController.isLoading || _slotController.isSaving)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _turfPicker(),
          SmallButton.ghost(
            _formatShortDate(_selectedDate),
            icon: Icons.calendar_month_outlined,
            onPressed: _pickSlotDate,
          ),
          SmallButton.ghost(
            'Generate',
            icon: Icons.auto_awesome_outlined,
            onPressed:
                _slotController.isSaving ? null : _showGenerateSlotsDialog,
          ),
          SmallButton.red(
            'Block',
            icon: Icons.block,
            onPressed: _canMutateSelected ? _showBlockSlotsDialog : null,
          ),
          SmallButton.ghost(
            'Unblock',
            icon: Icons.lock_open_outlined,
            onPressed: _canMutateSelected ? _unblockSelectedSlots : null,
          ),
          SmallButton.ghost(
            'Price',
            icon: Icons.currency_rupee,
            onPressed: _canMutateSelected ? _showUpdatePriceDialog : null,
          ),
        ]),
        const SizedBox(height: 8),
        if (_slotController.isLoading && _slotController.slots.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_slotController.slots.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('No slots found. Generate slots for this turf/date.',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
          )
        else ...[
          if (_slotsForPeriod(0, 12).isNotEmpty) ...[
            const SectionLabel('Morning (6 AM - 12 PM)'),
            _slotGrid(_slotsForPeriod(0, 12)),
          ],
          if (_slotsForPeriod(12, 17).isNotEmpty) ...[
            const SectionLabel('Afternoon (12 PM - 5 PM)'),
            _slotGrid(_slotsForPeriod(12, 17)),
          ],
          if (_slotsForPeriod(17, 24).isNotEmpty) ...[
            const SectionLabel('Evening / Peak (5 PM - 11 PM)'),
            _slotGrid(_slotsForPeriod(17, 24)),
          ],
        ],
      ]),
    );
  }

  Widget _turfPicker() {
    final turfs = _turfController.turfs.where((turf) => turf.id != null);
    if (turfs.isEmpty) {
      return SmallButton.ghost(
        _selectedTurfId == null ? 'Turf' : 'Turf #$_selectedTurfId',
        icon: Icons.stadium_outlined,
        onPressed: _showTurfIdDialog,
      );
    }

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: turfs.any((turf) => turf.id == _selectedTurfId)
              ? _selectedTurfId
              : null,
          iconSize: 16,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
          items: turfs
              .map((turf) => DropdownMenuItem(
                    value: turf.id,
                    child: Text(turf.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (value) async {
            if (value == null) return;
            setState(() => _selectedTurfId = value);
            await _loadSlots();
          },
        ),
      ),
    );
  }

  bool get _canMutateSelected =>
      _selectedSlotIds.isNotEmpty && !_slotController.isSaving;

  List<SlotItem> _slotsForPeriod(int startHour, int endHour) {
    return _slotController.slots.where((slot) {
      final hour = int.tryParse(slot.startTime.split(':').first) ?? -1;
      return hour >= startHour && hour < endHour;
    }).toList();
  }

  Future<void> _pickSlotDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2032),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    await _loadSlots();
  }

  Future<void> _showTurfIdDialog() async {
    final turfId = TextEditingController(text: (_selectedTurfId ?? 1).toString());
    final id = await showDialog<int>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Turf ID'),
          content: _dialogField('Turf ID', turfId,
              keyboardType: TextInputType.number),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, int.tryParse(turfId.text)),
              child: const Text('Load'),
            ),
          ],
        );
      },
    );
    disposeDialogControllers([turfId]);
    if (id == null) return;
    setState(() => _selectedTurfId = id);
    await _loadSlots();
  }

  Future<void> _showGenerateSlotsDialog() async {
    final turfId = _selectedTurfId;
    if (turfId == null) return;
    final from = TextEditingController(text: _displayDate(_selectedDate));
    final to = TextEditingController(
        text: _displayDate(_selectedDate.add(const Duration(days: 6))));
    final duration = TextEditingController(text: '60');

    final request = await showDialog<GenerateSlotsRequest>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Generate Slots'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogDateField('Date From', from),
              _dialogDateField('Date To', to),
              _dialogField('Slot Duration (minutes)', duration,
                  keyboardType: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                GenerateSlotsRequest(
                  turfId: turfId,
                  dateFrom: _apiDateFromText(from.text),
                  dateTo: _apiDateFromText(to.text),
                  slotDuration: int.tryParse(duration.text) ?? 60,
                ),
              ),
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );

    disposeDialogControllers([from, to, duration]);

    if (request == null) return;
    final saved = await _slotController.generate(request);
    if (!mounted) return;
    if (saved) {
      setState(() => _selectedDate = _parseApiDate(request.dateFrom));
      _selectedSlotIds.clear();
    }
    _showSlotActionResult(saved, 'Slots generated.');
  }

  Future<void> _showBlockSlotsDialog() async {
    final reason = TextEditingController(text: 'Maintenance');
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Block Slots'),
          content: _dialogField('Reason', reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, reason.text),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );
    disposeDialogControllers([reason]);
    if (value == null) return;
    final saved = await _slotController.block(
      slotIds: _selectedSlotIds.toList(),
      reason: value.trim().isEmpty ? 'Blocked by owner' : value.trim(),
    );
    if (!mounted) return;
    if (saved) _selectedSlotIds.clear();
    _showSlotActionResult(saved, 'Slots blocked.');
  }

  Future<void> _unblockSelectedSlots() async {
    final saved = await _slotController.unblock(_selectedSlotIds.toList());
    if (!mounted) return;
    if (saved) _selectedSlotIds.clear();
    _showSlotActionResult(saved, 'Slots unblocked.');
  }

  Future<void> _showUpdatePriceDialog() async {
    final price = TextEditingController(text: '1200');
    final value = await showDialog<num>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Update Slot Price'),
          content: _dialogField('Price', price,
              keyboardType: TextInputType.number),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, num.tryParse(price.text)),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
    disposeDialogControllers([price]);
    if (value == null) return;
    final saved = await _slotController.updatePrice(
      slotIds: _selectedSlotIds.toList(),
      price: value,
    );
    if (!mounted) return;
    if (saved) _selectedSlotIds.clear();
    _showSlotActionResult(saved, 'Slot price updated.');
  }

  void _showSlotActionResult(bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? successMessage
            : _slotController.errorMessage ?? 'Unable to save slot changes.'),
        backgroundColor: success ? AppColors.green : AppColors.red,
      ),
    );
  }

  Widget _matchesCard() {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Expanded(
              child: Text('Owner Matches',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            SmallButton.ghost(
              _matchController.isSaving ? 'Saving...' : 'Create',
              icon: Icons.add,
              onPressed:
                  _matchController.isSaving ? null : _showCreateMatchDialog,
            ),
          ]),
          const SizedBox(height: 14),
          if (_matchController.isLoading && _matchController.matches.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_matchController.matches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No matches found.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            )
          else
            ..._matchController.matches.map(_matchTile),
        ]),
      ),
    );
  }

  Widget _matchTile(MatchItem match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(match.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          StatusBadge(label: _label(match.status), type: _matchStatus(match.status)),
        ]),
        const SizedBox(height: 6),
        Text('${_label(match.sport)} - ${match.turfName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Text('${match.date} ${match.time}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text('${match.players} - ${match.feePerPlayer}',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          SmallButton.ghost(
            'Stream',
            icon: Icons.live_tv_outlined,
            onPressed:
                match.id == null ? null : () => _showStreamDialog(match.id!),
          ),
          SmallButton.ghost(
            'Score',
            icon: Icons.scoreboard_outlined,
            onPressed:
                match.id == null ? null : () => _showScoreboardDialog(match),
          ),
          SmallButton.ghost(
            'Commentary',
            icon: Icons.chat_bubble_outline,
            onPressed: match.id == null
                ? null
                : () => _showCommentaryDialog(match.id!, match.sport),
          ),
          SmallButton.red(
            'Delete Note',
            icon: Icons.delete_outline,
            onPressed: match.id == null
                ? null
                : () => _showDeleteCommentaryDialog(match.id!),
          ),
        ]),
      ]),
    );
  }

  Future<void> _showStreamDialog(int matchId) async {
    final streamUrl =
        TextEditingController(text: 'https://youtube.com/live/abc123xyz');
    var streamType = 'youtube';

    final request = await showDialog<UpdateStreamRequest>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return ResponsiveAlertDialog(
            title: const Text('Live Stream'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<String>(
                  value: streamType,
                  decoration: const InputDecoration(labelText: 'Stream Type'),
                  items: const [
                    DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => streamType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _dialogField('Stream URL', streamUrl,
                    keyboardType: TextInputType.url),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _showStreamInfo(context, matchId),
                child: const Text('Info'),
              ),
              TextButton(
                onPressed: () => _createMuxStream(context, matchId),
                child: const Text('Mux'),
              ),
              TextButton(
                onPressed: () => _endStream(context, matchId),
                child: const Text('End'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  UpdateStreamRequest(
                    streamUrl: streamUrl.text,
                    streamType: streamType,
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );

    disposeDialogControllers([streamUrl]);
    if (request == null) return;
    final saved = await _matchController.updateStream(matchId, request);
    if (!mounted) return;
    _showMatchActionResult(saved, 'Stream updated.');
  }

  Future<void> _showStreamInfo(BuildContext dialogContext, int matchId) async {
    Navigator.pop(dialogContext);
    final info = await _matchController.getStreamInfo(matchId);
    if (!mounted) return;
    if (info == null) {
      _showMatchActionResult(false, '');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Stream Info'),
          content: SingleChildScrollView(
            child: Text(
              info.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createMuxStream(BuildContext dialogContext, int matchId) async {
    Navigator.pop(dialogContext);
    final saved = await _matchController.createMuxStream(matchId);
    if (!mounted) return;
    _showMatchActionResult(saved, 'Mux stream created.');
  }

  Future<void> _endStream(BuildContext dialogContext, int matchId) async {
    Navigator.pop(dialogContext);
    final saved = await _matchController.endStream(matchId);
    if (!mounted) return;
    _showMatchActionResult(saved, 'Stream ended.');
  }

  Future<void> _showScoreboardDialog(MatchItem match) async {
    final isFootball = match.sport.toLowerCase().contains('football');
    final isRacketSport =
        RegExp('badminton|tennis', caseSensitive: false).hasMatch(match.sport);
    final teamAName = TextEditingController(text: 'Bhandara XI');
    final teamBName = TextEditingController(text: 'Nagpur Tigers');
    final teamAScore = TextEditingController(text: isFootball ? '0' : '156/4');
    final teamBScore = TextEditingController(text: isFootball ? '0' : '89/2');
    final teamAOvers = TextEditingController(text: '12.3');
    final teamBOvers = TextEditingController(text: '8.1');
    final teamAWickets = TextEditingController(text: '4');
    final teamBWickets = TextEditingController(text: '2');
    final batting = TextEditingController(text: 'b');
    final currentOver = TextEditingController(text: '8.1');
    final target = TextEditingController(text: '157');
    final currentRunRate = TextEditingController(text: '10.9');
    final requiredRunRate = TextEditingController(text: '11.5');
    final period = TextEditingController(text: isFootball ? '2nd Half' : 'Set 2');
    final result = TextEditingController();
    var matchStatus = 'live';

    final request = await showDialog<UpdateScoreboardRequest>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return ResponsiveAlertDialog(
            title: const Text('Update Scoreboard'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<String>(
                  value: matchStatus,
                  decoration: const InputDecoration(labelText: 'Match Status'),
                  items: const [
                    DropdownMenuItem(value: 'live', child: Text('Live')),
                    DropdownMenuItem(
                        value: 'innings_break', child: Text('Innings Break')),
                    DropdownMenuItem(
                        value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => matchStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _dialogField('Team A Name', teamAName),
                _dialogField('Team B Name', teamBName),
                if (isFootball) ...[
                  _dialogField('Team A Goals', teamAScore,
                      keyboardType: TextInputType.number),
                  _dialogField('Team B Goals', teamBScore,
                      keyboardType: TextInputType.number),
                  _dialogField('Period', period),
                ] else if (isRacketSport) ...[
                  _dialogField('Team A Score', teamAScore),
                  _dialogField('Team B Score', teamBScore),
                  _dialogField('Period', period),
                ] else ...[
                  _dialogField('Team A Score', teamAScore),
                  _dialogField('Team A Overs', teamAOvers),
                  _dialogField('Team A Wickets', teamAWickets,
                      keyboardType: TextInputType.number),
                  _dialogField('Team B Score', teamBScore),
                  _dialogField('Team B Overs', teamBOvers),
                  _dialogField('Team B Wickets', teamBWickets,
                      keyboardType: TextInputType.number),
                  _dialogField('Batting Team (a/b)', batting),
                  _dialogField('Current Over', currentOver),
                  _dialogField('Target', target,
                      keyboardType: TextInputType.number),
                  _dialogField('Current Run Rate', currentRunRate,
                      keyboardType: TextInputType.number),
                  _dialogField('Required Run Rate', requiredRunRate,
                      keyboardType: TextInputType.number),
                ],
                _dialogField('Result', result),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  UpdateScoreboardRequest(
                    teamAName: teamAName.text,
                    teamAScore: isFootball ? '' : teamAScore.text,
                    teamAOvers: teamAOvers.text,
                    teamAWickets:
                        isFootball ? null : int.tryParse(teamAWickets.text),
                    teamAGoals:
                        isFootball ? int.tryParse(teamAScore.text) ?? 0 : null,
                    teamBName: teamBName.text,
                    teamBScore: isFootball ? '' : teamBScore.text,
                    teamBOvers: teamBOvers.text,
                    teamBWickets:
                        isFootball ? null : int.tryParse(teamBWickets.text),
                    teamBGoals:
                        isFootball ? int.tryParse(teamBScore.text) ?? 0 : null,
                    batting: isFootball || isRacketSport ? null : batting.text,
                    currentOver:
                        isFootball || isRacketSport ? null : currentOver.text,
                    target: isFootball || isRacketSport
                        ? null
                        : int.tryParse(target.text),
                    currentRunRate: isFootball || isRacketSport
                        ? null
                        : double.tryParse(currentRunRate.text),
                    requiredRunRate: isFootball || isRacketSport
                        ? null
                        : double.tryParse(requiredRunRate.text),
                    period: isFootball || isRacketSport ? period.text : null,
                    matchStatus: matchStatus,
                    result: result.text,
                  ),
                ),
                child: const Text('Update'),
              ),
            ],
          );
        });
      },
    );

    disposeDialogControllers([
      teamAName,
      teamBName,
      teamAScore,
      teamBScore,
      teamAOvers,
      teamBOvers,
      teamAWickets,
      teamBWickets,
      batting,
      currentOver,
      target,
      currentRunRate,
      requiredRunRate,
      period,
      result,
    ]);

    if (request == null || match.id == null) return;
    final saved = await _matchController.updateScoreboard(match.id!, request);
    if (!mounted) return;
    _showMatchActionResult(saved, 'Scoreboard updated.');
  }

  Future<void> _showCommentaryDialog(int matchId, String sport) async {
    final text = TextEditingController();
    final over = TextEditingController(text: '12.3');
    final minute = TextEditingController(text: '67');
    final playerName = TextEditingController();
    final isFootball = sport.toLowerCase().contains('football');
    var eventType = isFootball ? 'goal' : 'normal';

    final request = await showDialog<AddCommentaryRequest>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          final events = isFootball
              ? const ['goal', 'card', 'half_time', 'highlight', 'normal']
              : const ['normal', 'four', 'six', 'wicket', 'highlight'];

          return ResponsiveAlertDialog(
            title: const Text('Add Commentary'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<String>(
                  value: eventType,
                  decoration: const InputDecoration(labelText: 'Event Type'),
                  items: events
                      .map((event) => DropdownMenuItem(
                            value: event,
                            child: Text(_label(event)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => eventType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _dialogField(isFootball ? 'Minute' : 'Over',
                    isFootball ? minute : over),
                _dialogField('Player Name', playerName),
                _dialogField('Commentary Text', text),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  AddCommentaryRequest(
                    text: text.text,
                    over: isFootball ? null : over.text,
                    minute: isFootball ? minute.text : null,
                    eventType: eventType,
                    playerName: playerName.text,
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );

    disposeDialogControllers([text, over, minute, playerName]);

    if (request == null) return;
    final saved = await _matchController.addCommentary(matchId, request);
    if (!mounted) return;
    _showMatchActionResult(saved, 'Commentary added.');
  }

  Future<void> _showDeleteCommentaryDialog(int matchId) async {
    final commentaryId = TextEditingController();
    final id = await showDialog<int>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Delete Commentary'),
          content: _dialogField('Commentary ID', commentaryId,
              keyboardType: TextInputType.number),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, int.tryParse(commentaryId.text)),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    disposeDialogControllers([commentaryId]);
    if (id == null) return;
    final saved = await _matchController.deleteCommentary(matchId, id);
    if (!mounted) return;
    _showMatchActionResult(saved, 'Commentary deleted.');
  }

  void _showMatchActionResult(bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? successMessage
            : _matchController.errorMessage ?? 'Unable to save changes.'),
        backgroundColor: success ? AppColors.green : AppColors.red,
      ),
    );
  }

  Future<void> _showCreateMatchDialog() async {
    final title = TextEditingController(text: 'Owner Match');
    final sport = TextEditingController(text: 'cricket');
    final turfId = TextEditingController(text: '1');
    final date = TextEditingController(text: _displayDate(_selectedDate));
    final start = TextEditingController(text: '6:00 PM');
    final end = TextEditingController(text: '8:00 PM');
    final maxPlayers = TextEditingController(text: '22');
    final fee = TextEditingController(text: '200');

    final request = await showDialog<CreateMatchRequest>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Create Match'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField('Title', title),
              _dialogField('Sport', sport),
              _dialogField('Turf ID', turfId, keyboardType: TextInputType.number),
              _dialogDateField('Date', date),
              _dialogTimeField('Start Time', start),
              _dialogTimeField('End Time', end),
              _dialogField('Max Players', maxPlayers,
                  keyboardType: TextInputType.number),
              _dialogField('Fee Per Player', fee,
                  keyboardType: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  CreateMatchRequest(
                    title: title.text,
                    sport: sport.text,
                    turfId: int.tryParse(turfId.text) ?? 1,
                    date: _apiDateFromText(date.text),
                    timeStart: _apiTimeFromText(start.text),
                    timeEnd: _apiTimeFromText(end.text),
                    maxPlayers: int.tryParse(maxPlayers.text) ?? 22,
                    feePerPlayer: num.tryParse(fee.text) ?? 200,
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    disposeDialogControllers([
      title,
      sport,
      turfId,
      date,
      start,
      end,
      maxPlayers,
      fee,
    ]);

    if (request == null) return;
    final saved = await _matchController.createMatch(request);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved
            ? 'Match created.'
            : _matchController.errorMessage ?? 'Unable to create match.'),
        backgroundColor: saved ? AppColors.green : AppColors.red,
      ),
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dialogDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'DD MMM YYYY',
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        onTap: () => _pickDialogDate(controller),
      ),
    );
  }

  Widget _dialogTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'h:mm AM',
          suffixIcon: const Icon(Icons.schedule),
        ),
        onTap: () => _pickDialogTime(controller),
      ),
    );
  }

  Future<void> _pickDialogDate(TextEditingController controller) async {
    final initial = _dateFromText(controller.text) ?? _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2032),
    );
    if (picked == null) return;
    controller.text = _displayDate(picked);
  }

  Future<void> _pickDialogTime(TextEditingController controller) async {
    final normalized = _apiTimeFromText(controller.text);
    final parts = normalized.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 6,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    controller.text = _displayTime(picked);
  }

  Widget _slotGrid(List<SlotItem> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 118,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final s = slots[i];
        final slotId = s.id;
        final isSelected =
            slotId != null && _selectedSlotIds.contains(slotId);
        Color bg;
        Color border;
        Color text;
        if (s.isBooked) {
          bg = AppColors.dark;
          border = AppColors.dark;
          text = Colors.white;
        } else if (s.isBlocked) {
          bg = AppColors.redLt;
          border = AppColors.red;
          text = AppColors.red;
        } else {
          bg = AppColors.greenLt;
          border = AppColors.green;
          text = AppColors.green;
        }

        return InkWell(
          onTap: s.isBooked || slotId == null
              ? null
              : () {
                  setState(() {
                    if (isSelected) {
                      _selectedSlotIds.remove(slotId);
                    } else {
                      _selectedSlotIds.add(slotId);
                    }
                  });
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.blue : border,
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(s.timeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800, color: text)),
              const SizedBox(height: 3),
              Text(s.infoLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      color: s.isBooked ? Colors.white70 : AppColors.muted)),
            ]),
          ),
        );
      },
    );
  }

  Widget _priceBox(String label, String price) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted)),
        ),
        Text(price,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  StatusType _matchStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('cancel') || normalized.contains('closed')) {
      return StatusType.cancelled;
    }
    if (normalized.contains('pending')) return StatusType.pending;
    if (normalized.contains('complete')) return StatusType.completed;
    return StatusType.active;
  }

  String _label(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return '-';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .map((part) => part.isEmpty
            ? part
            : '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _selectedTurfName() {
    for (final turf in _turfController.turfs) {
      if (turf.id == _selectedTurfId) return turf.name;
    }
    return _selectedTurfId == null ? 'Select Turf' : 'Turf #$_selectedTurfId';
  }

  DateTime _parseApiDate(String value) {
    return DateTime.tryParse(value) ?? _selectedDate;
  }

  String _apiDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _formatShortDate(DateTime value) {
    return _displayDate(value);
  }

  String _formatDisplayDate(DateTime value) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[value.weekday - 1]}, '
        '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  String _apiDateFromText(String value) {
    final date = _dateFromText(value);
    return date == null ? value.trim() : _apiDate(date);
  }

  DateTime? _dateFromText(String value) {
    final text = value.trim();
    final direct = DateTime.tryParse(text);
    if (direct != null) return direct;
    final match = RegExp(r'^(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})$')
        .firstMatch(text);
    if (match == null) return null;
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final day = int.tryParse(match.group(1)!);
    final month = months[match.group(2)!.toLowerCase()];
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  String _displayDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
  }

  String _apiTimeFromText(String value) {
    final text = value.trim();
    final twentyFour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (twentyFour != null) {
      final hour = int.tryParse(twentyFour.group(1)!) ?? 0;
      final minute = twentyFour.group(2)!;
      return '${hour.toString().padLeft(2, '0')}:$minute';
    }
    final twelve =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
            .firstMatch(text);
    if (twelve == null) return text;
    var hour = int.tryParse(twelve.group(1)!) ?? 0;
    final minute = twelve.group(2)!;
    final period = twelve.group(3)!.toUpperCase();
    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  String _displayTime(TimeOfDay value) {
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '$hour:${value.minute.toString().padLeft(2, '0')} $period';
  }
}
