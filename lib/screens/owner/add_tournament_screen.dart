import 'package:flutter/material.dart';

import '../../controllers/tournament_controller.dart';
import '../../controllers/turf_controller.dart';
import '../../models/tournament_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AddTournamentScreen extends StatefulWidget {
  final ValueChanged<String>? onNavigate;
  const AddTournamentScreen({super.key, this.onNavigate});

  @override
  State<AddTournamentScreen> createState() => _AddTournamentScreenState();
}

class _AddTournamentScreenState extends State<AddTournamentScreen> {
  final TournamentController _controller = TournamentController();
  final TurfController _turfController = TurfController();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController(text: 'Gurugram');
  final _startDate = TextEditingController(text: '01 Jun 2026');
  final _endDate = TextEditingController(text: '08 Jun 2026');
  final _maxTeams = TextEditingController(text: '16');
  final _entryFee = TextEditingController(text: '500');
  final _prizeTotal = TextEditingController(text: '5000');
  final _description = TextEditingController();
  final _manualTurfId = TextEditingController(text: '1');
  String _sport = 'cricket';
  String _format = 'T10';
  String _tournamentFormat = 'group_knockout';
  int? _turfId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _turfController.addListener(_onChanged);
    _loadTurfs();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _turfController.removeListener(_onChanged);
    _controller.dispose();
    _turfController.dispose();
    for (final controller in [
      _name,
      _city,
      _startDate,
      _endDate,
      _maxTeams,
      _entryFee,
      _prizeTotal,
      _description,
      _manualTurfId,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTurfs() async {
    final loaded = await _turfController.load();
    if (!mounted || !loaded) return;
    final turfs = _turfController.turfs.where((turf) => turf.id != null);
    if (turfs.isNotEmpty) {
      setState(() => _turfId = turfs.first.id);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Add Tournament',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Create and publish a tournament on Turf11',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        if (_controller.errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(_controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12)),
        ],
        const SizedBox(height: 14),
        _section(
          icon: Icons.emoji_events_outlined,
          title: 'Tournament Details',
          children: [
            _field('Tournament Name', _name, 'e.g. Gurugram T10 Cup 2026'),
            _dropdown('Sport', _sport, const ['cricket', 'football', 'badminton'],
                (value) => setState(() => _sport = value)),
            _dropdown('Format', _format,
                const ['T10', 'T20', 'ODI', 'Box Cricket', 'Round Robin'],
                (value) => setState(() => _format = value)),
            _dropdown(
              'Tournament Format',
              _tournamentFormat,
              const ['group_knockout', 'round_robin', 'knockout'],
              (value) => setState(() => _tournamentFormat = value),
            ),
            _field('City', _city, 'Gurugram'),
            _dateField('Start Date', _startDate),
            _dateField('End Date', _endDate),
            _turfDropdown(),
            _field('Max Teams', _maxTeams, '16',
                keyboardType: TextInputType.number),
            const FieldLabel('Tournament Description'),
            TextFormField(
              controller: _description,
              maxLines: 4,
              validator: _required,
              decoration: const InputDecoration(
                  hintText:
                      'Describe format, rules overview and special features.'),
            ),
          ],
        ),
        _section(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Entry & Prize',
          children: [
            _price('Entry Fee / Team', _entryFee, '500'),
            _price('Total Prize', _prizeTotal, '5000'),
          ],
        ),
        PrimaryButton(
            label: _controller.isSaving ? 'Publishing...' : 'Publish Tournament',
            bgColor: AppColors.green,
            compact: true,
            onPressed: _controller.isSaving ? null : _submit),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final turfId = _turfId;
    final fallbackTurfId = int.tryParse(_manualTurfId.text);
    if (turfId == null && fallbackTurfId == null) {
      _toast(false, 'Please select a turf.');
      return;
    }

    final saved = await _controller.create(
      CreateTournamentRequest(
        name: _name.text.trim(),
        sport: _sport,
        format: _format,
        tournamentFormat: _tournamentFormat,
        turfId: turfId ?? fallbackTurfId!,
        city: _city.text.trim(),
        startDate: _apiDateFromText(_startDate.text),
        endDate: _apiDateFromText(_endDate.text),
        maxTeams: int.tryParse(_maxTeams.text) ?? 0,
        entryFee: num.tryParse(_entryFee.text) ?? 0,
        prizeTotal: num.tryParse(_prizeTotal.text) ?? 0,
        description: _description.text.trim(),
      ),
    );
    if (!mounted) return;
    _toast(saved, saved
        ? 'Tournament created.'
        : _controller.errorMessage ?? 'Unable to create tournament.');
    if (saved) widget.onNavigate?.call('tournaments');
  }

  void _toast(bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.green : AppColors.red,
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 17, color: AppColors.dark),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 16),
        ..._spaced(children),
      ]),
    );
  }

  List<Widget> _spaced(List<Widget> children) {
    return [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i != children.length - 1) const SizedBox(height: 16),
      ]
    ];
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: _required,
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      TextFormField(
        controller: controller,
        readOnly: true,
        keyboardType: TextInputType.datetime,
        validator: _required,
        decoration: const InputDecoration(
          hintText: 'DD MMM YYYY',
          suffixIcon: Icon(Icons.calendar_month_outlined),
        ),
        onTap: () => _pickDate(controller),
      ),
    ]);
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = _dateFromText(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2032),
    );
    if (picked == null) return;
    controller.text = _displayDate(picked);
  }

  Widget _price(String label, TextEditingController controller, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      TextFormField(
        keyboardType: TextInputType.number,
        controller: controller,
        validator: _required,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: 'Rs ',
        ),
      ),
    ]);
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(),
        value: value,
        validator: (value) => value == null ? 'Required' : null,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(_label(e))))
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ]);
  }

  Widget _turfDropdown() {
    final turfs = _turfController.turfs.where((turf) => turf.id != null);
    if (turfs.isEmpty) {
      return _field('Turf ID', _manualTurfId, '1',
          keyboardType: TextInputType.number);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FieldLabel('Venue / Turf'),
      DropdownButtonFormField<int>(
        decoration: const InputDecoration(),
        value: turfs.any((turf) => turf.id == _turfId) ? _turfId : null,
        validator: (value) => value == null ? 'Required' : null,
        items: turfs
            .map((turf) =>
                DropdownMenuItem(value: turf.id, child: Text(turf.name)))
            .toList(),
        onChanged: (value) => setState(() => _turfId = value),
      ),
    ]);
  }

  String _label(String value) {
    return value
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) =>
            '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _apiDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
}
