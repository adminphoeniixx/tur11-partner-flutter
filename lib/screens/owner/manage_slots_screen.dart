import 'package:flutter/material.dart';

import '../../controllers/match_controller.dart';
import '../../models/match_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ManageSlotsScreen extends StatefulWidget {
  const ManageSlotsScreen({super.key});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  final MatchController _matchController = MatchController();

  @override
  void initState() {
    super.initState();
    _matchController.addListener(_onMatchesChanged);
    _matchController.load();
  }

  @override
  void dispose() {
    _matchController.removeListener(_onMatchesChanged);
    _matchController.dispose();
    super.dispose();
  }

  void _onMatchesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _matchController.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manage Slots',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Monday, April 7 - DLF Arena Cricket',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_matchController.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_matchController.errorMessage!,
                style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ],
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                SmallButton.ghost(
                  _matchController.isSaving ? 'Saving...' : 'Create Match',
                  icon: Icons.add,
                  onPressed:
                      _matchController.isSaving ? null : _showCreateMatchDialog,
                ),
                SmallButton.red('Block All', icon: Icons.close),
              ]),
              const SectionLabel('Morning (6 AM - 12 PM)'),
              _slotGrid([
                _Slot('6:00 AM', 'Rahul K. - Rs 800', SlotState.booked),
                _Slot('7:00 AM', 'Arjun K. - Rs 800', SlotState.booked),
                _Slot('8:00 AM', 'Available', SlotState.available),
                _Slot('9:00 AM', 'Available', SlotState.available),
                _Slot('10:00 AM', 'Available', SlotState.available),
                _Slot('11:00 AM', 'Blocked', SlotState.blocked),
              ]),
              const SectionLabel('Afternoon (12 PM - 5 PM)'),
              _slotGrid([
                _Slot('12:00 PM', 'Available', SlotState.available),
                _Slot('1:00 PM', 'Available', SlotState.available),
                _Slot('2:00 PM', 'Available', SlotState.available),
                _Slot('3:00 PM', 'Available', SlotState.available),
                _Slot('4:00 PM', 'Available', SlotState.available),
              ]),
              const SectionLabel('Evening / Peak (5 PM - 11 PM)'),
              _slotGrid([
                _Slot('5:00 PM', 'Priya V. - Rs 1,200', SlotState.booked),
                _Slot('6:00 PM', 'Sahil R. - Rs 1,200', SlotState.booked),
                _Slot('7:00 PM', 'Rahul K. - Rs 1,600', SlotState.booked),
                _Slot('8:00 PM', 'Match - Rs 1,200', SlotState.booked),
                _Slot('9:00 PM', 'Available', SlotState.available),
                _Slot('10:00 PM', 'Available', SlotState.available),
              ]),
            ]),
          ),
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

  Widget _matchesCard() {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Owner Matches',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
              child: Text('No open matches found.',
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
      ]),
    );
  }

  Future<void> _showCreateMatchDialog() async {
    final title = TextEditingController(text: 'Owner Match');
    final sport = TextEditingController(text: 'cricket');
    final turfId = TextEditingController(text: '1');
    final date = TextEditingController(text: '2026-05-20');
    final start = TextEditingController(text: '18:00');
    final end = TextEditingController(text: '20:00');
    final maxPlayers = TextEditingController(text: '22');
    final fee = TextEditingController(text: '200');

    final request = await showDialog<CreateMatchRequest>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Match'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField('Title', title),
              _dialogField('Sport', sport),
              _dialogField('Turf ID', turfId, keyboardType: TextInputType.number),
              _dialogField('Date', date),
              _dialogField('Start Time', start),
              _dialogField('End Time', end),
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
                    date: date.text,
                    timeStart: start.text,
                    timeEnd: end.text,
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

    title.dispose();
    sport.dispose();
    turfId.dispose();
    date.dispose();
    start.dispose();
    end.dispose();
    maxPlayers.dispose();
    fee.dispose();

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

  Widget _slotGrid(List<_Slot> slots) {
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
        Color bg;
        Color border;
        Color text;
        switch (s.state) {
          case SlotState.booked:
            bg = AppColors.dark;
            border = AppColors.dark;
            text = Colors.white;
          case SlotState.available:
            bg = AppColors.greenLt;
            border = AppColors.green;
            text = AppColors.green;
          case SlotState.blocked:
            bg = AppColors.redLt;
            border = AppColors.red;
            text = AppColors.red;
        }

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.5),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(s.time,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800, color: text)),
            const SizedBox(height: 3),
            Text(s.info,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    color: s.state == SlotState.booked
                        ? Colors.white70
                        : AppColors.muted)),
          ]),
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
}

class _Slot {
  final String time, info;
  final SlotState state;
  _Slot(this.time, this.info, this.state);
}

enum SlotState { booked, available, blocked }
