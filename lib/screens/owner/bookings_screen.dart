import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/booking_controller.dart';
import '../../controllers/slot_controller.dart';
import '../../controllers/turf_controller.dart';
import '../../models/booking_models.dart';
import '../../models/slot_models.dart';
import '../../models/turf_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/input_validators.dart';
import '../../widgets/shared_widgets.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingController _controller = BookingController();
  final SlotController _slotController = SlotController();
  final TurfController _turfController = TurfController();
  final Set<int> _selectedCreateBookingSlotIds = {};
  DateTime _createBookingDate = DateTime.now();
  int? _createBookingTurfId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onBookingsChanged);
    _slotController.addListener(_onBookingsChanged);
    _turfController.addListener(_onBookingsChanged);
    _controller.load();
    _loadTurfsForCreateBooking();
  }

  @override
  void dispose() {
    _controller.removeListener(_onBookingsChanged);
    _slotController.removeListener(_onBookingsChanged);
    _turfController.removeListener(_onBookingsChanged);
    _controller.dispose();
    _slotController.dispose();
    _turfController.dispose();
    super.dispose();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadTurfsForCreateBooking() async {
    final loaded = await _turfController.load();
    if (!mounted || !loaded) return;
    _syncCreateBookingTurf();
    await _loadCreateBookingSlots();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bookings',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text('All bookings across your turfs',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            PillButton.green(
              _controller.isSaving ? 'Saving...' : 'Create Booking',
              icon: Icons.add,
              onPressed:
                  _controller.isSaving ? null : _showCreateBookingDialog,
            ),
          ]),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          _stats(_controller.stats),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Bookings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    if (_controller.isLoading && _controller.bookings.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_controller.bookings.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No bookings found.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      )
                    else
                      ..._controller.bookings.map(_bookingFromApi),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stats(BookingStats stats) {
    return LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth < 360 ? 1 : 2;
      return GridView.count(
        crossAxisCount: constraints.maxWidth > 700 ? 4 : count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth < 360 ? 2.4 : 1.75,
        children: [
          StatCard(
              label: 'Total Bookings',
              value: stats.total,
              change: 'All bookings'),
          StatCard(
              label: 'Confirmed',
              value: stats.confirmed,
              change: 'Confirmed',
              changeColor: AppColors.green),
          StatCard(
              label: 'Cancelled',
              value: stats.cancelled,
              change: 'Cancelled',
              isUp: false),
          StatCard(
              label: 'Pending Pay',
              value: stats.pendingPay,
              change: 'Action needed',
              isUp: false,
              changeColor: AppColors.amber),
        ],
      );
    });
  }

  Widget _bookingFromApi(BookingItem booking) {
    final status = _statusType(booking.status);
    return _bookingCard(
      booking.id.startsWith('#') ? booking.id : '#${booking.id}',
      booking.customerName,
      booking.phone,
      booking.turfName,
      booking.dateTime,
      booking.players,
      booking.amount,
      _amountColor(status),
      status,
      _statusLabel(booking.status),
    );
  }

  Widget _bookingCard(
    String id,
    String name,
    String phone,
    String turf,
    String dateTime,
    String players,
    String amount,
    Color amountColor,
    StatusType status,
    String statusLabel,
  ) {
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
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('$id - $phone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: StatusBadge(label: statusLabel, type: status),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text(turf,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: Text(amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: amountColor)),
          ),
        ]),
        const SizedBox(height: 4),
        Text('$dateTime - $players players',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }

  Future<void> _showCreateBookingDialog() async {
    if (_turfController.turfs.isEmpty && !_turfController.isLoading) {
      await _loadTurfsForCreateBooking();
    }
    if (!mounted) return;

    _syncCreateBookingTurf();
    await _loadCreateBookingSlots();
    if (!mounted) return;

    final customerName = TextEditingController();
    final customerPhone = TextEditingController();
    final playersCount = TextEditingController(text: '10');
    final amountCollected = TextEditingController();
    final notes = TextEditingController(text: 'Created by owner');
    final formKey = GlobalKey<FormState>();
    String? slotError;
    var sportType = _selectedCreateBookingTurf()?.sportType ?? 'cricket';
    var paymentMode = 'cash';

    final request = await showDialog<CreateOwnerBookingRequest>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          final turfs = _turfController.turfs.where((turf) => turf.id != null);
          final availableSlots =
              _slotController.slots.where((slot) => slot.id != null).toList();
          final isBusy = _controller.isSaving ||
              _turfController.isLoading ||
              _slotController.isLoading;

          return ResponsiveAlertDialog(
            title: const Text('Create Booking'),
            content: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<int>(
                value: turfs.any((turf) => turf.id == _createBookingTurfId)
                    ? _createBookingTurfId
                    : null,
                decoration: const InputDecoration(labelText: 'Turf'),
                validator: (value) =>
                    value == null ? 'Turf is required.' : null,
                items: turfs
                    .map((turf) => DropdownMenuItem(
                          value: turf.id,
                          child: Text(turf.name),
                        ))
                    .toList(),
                onChanged: isBusy
                    ? null
                    : (value) async {
                        if (value == null) return;
                        setDialogState(() {
                          _createBookingTurfId = value;
                          _selectedCreateBookingSlotIds.clear();
                          slotError = null;
                          sportType = _selectedCreateBookingTurf()?.sportType ??
                              sportType;
                        });
                        await _loadCreateBookingSlots();
                        if (mounted) setDialogState(() {});
                      },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: isBusy
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _createBookingDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2032),
                        );
                        if (picked == null) return;
                        setDialogState(() {
                          _createBookingDate = picked;
                          _selectedCreateBookingSlotIds.clear();
                          slotError = null;
                        });
                        await _loadCreateBookingSlots();
                        if (mounted) setDialogState(() {});
                      },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  child: Text(_displayDate(_createBookingDate)),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedCreateBookingSlotIds.isEmpty
                      ? 'Select slot'
                      : '${_selectedCreateBookingSlotIds.length} slots selected',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_slotController.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else if (_createBookingTurfId == null)
                const Text('Create a turf first.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted))
              else if (availableSlots.isEmpty)
                const Text('No slots found for this date.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted))
              else
                _slotPicker(availableSlots, setDialogState),
              if (slotError != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    slotError!,
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _dialogField(
                'Customer Name',
                customerName,
                validator: (value) => InputValidators.requiredField(
                  value,
                  label: 'Customer name',
                ),
              ),
              _dialogField('Customer Phone', customerPhone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => InputValidators.phone(
                        value,
                        label: 'Customer phone',
                      )),
              _dialogField(
                'Players Count',
                playersCount,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final required = InputValidators.requiredField(
                    value,
                    label: 'Players count',
                  );
                  if (required != null) return required;
                  return int.tryParse(value!.trim()) == null
                      ? 'Players count must be a number.'
                      : null;
                },
              ),
              DropdownButtonFormField<String>(
                value: sportType,
                decoration: const InputDecoration(labelText: 'Sport Type'),
                validator: (value) =>
                    value == null ? 'Sport type is required.' : null,
                items: const ['cricket', 'football', 'badminton', 'tennis']
                    .map((sport) => DropdownMenuItem(
                          value: sport,
                          child: Text(_labelStatic(sport)),
                        ))
                    .toList(),
                onChanged:
                    isBusy ? null : (value) => sportType = value ?? sportType,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: paymentMode,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                validator: (value) =>
                    value == null ? 'Payment mode is required.' : null,
                items: const ['cash', 'upi', 'card', 'online']
                    .map((mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(_labelStatic(mode)),
                        ))
                    .toList(),
                onChanged: isBusy
                    ? null
                    : (value) => paymentMode = value ?? paymentMode,
              ),
              const SizedBox(height: 12),
              _dialogField(
                'Amount Collected',
                amountCollected,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final required = InputValidators.requiredField(
                    value,
                    label: 'Amount collected',
                  );
                  if (required != null) return required;
                  return num.tryParse(value!.trim()) == null
                      ? 'Amount collected must be a number.'
                      : null;
                },
              ),
              _dialogField('Notes', notes),
              if (_slotController.errorMessage != null) ...[
                const SizedBox(height: 4),
                Text(_slotController.errorMessage!,
                    style: const TextStyle(color: AppColors.red, fontSize: 12)),
              ],
            ]),
            ),
            actions: [
              TextButton(
                onPressed: isBusy ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isBusy
                    ? null
                    : () {
                        setDialogState(() {
                          slotError = _selectedCreateBookingSlotIds.isEmpty
                              ? 'Select at least one slot.'
                              : null;
                        });
                        if (!formKey.currentState!.validate() ||
                            slotError != null) {
                          return;
                        }
                        final turfId = _createBookingTurfId!;
                        final amount = num.parse(amountCollected.text.trim());
                        final players = int.parse(playersCount.text.trim());
                        Navigator.pop(
                          context,
                          CreateOwnerBookingRequest(
                            turfId: turfId,
                            slotIds: _selectedCreateBookingSlotIds.toList(),
                            customerName: customerName.text,
                            customerPhone: customerPhone.text,
                            playersCount: players,
                            sportType: sportType,
                            paymentMode: paymentMode,
                            amountCollected: amount,
                            notes: notes.text,
                          ),
                        );
                      },
                child: const Text('Create'),
              ),
            ],
          );
        });
      },
    );

    disposeDialogControllers([
      customerName,
      customerPhone,
      playersCount,
      amountCollected,
      notes,
    ]);

    if (request == null) return;
    final saved = await _controller.createOwnerBooking(request);
    if (!mounted) return;
    if (saved) {
      _selectedCreateBookingSlotIds.clear();
      await _loadCreateBookingSlots();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved
            ? 'Booking created.'
            : _controller.errorMessage ?? 'Unable to create booking.'),
        backgroundColor: saved ? AppColors.green : AppColors.red,
      ),
    );
  }

  Widget _slotPicker(
    List<SlotItem> slots,
    void Function(void Function()) setDialogState,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final slotId = slot.id!;
        final isSelected = _selectedCreateBookingSlotIds.contains(slotId);
        final canSelect = slot.isAvailable;
        return FilterChip(
          label: Text(slot.timeLabel),
          selected: isSelected,
          onSelected: canSelect
              ? (selected) {
                  setDialogState(() {
                    if (selected) {
                      _selectedCreateBookingSlotIds.add(slotId);
                    } else {
                      _selectedCreateBookingSlotIds.remove(slotId);
                    }
                  });
                }
              : null,
          selectedColor: AppColors.greenLt,
          disabledColor: slot.isBooked ? AppColors.dark : AppColors.redLt,
          labelStyle: TextStyle(
            fontSize: 11,
            color: canSelect
                ? (isSelected ? AppColors.green : AppColors.dark)
                : (slot.isBooked ? Colors.white : AppColors.red),
            fontWeight: FontWeight.w700,
          ),
        );
      }).toList(),
    );
  }

  Future<bool> _loadCreateBookingSlots() async {
    final turfId = _createBookingTurfId;
    if (turfId == null) {
      _slotController.clear();
      return false;
    }
    return _slotController.load(
      turfId: turfId,
      date: _apiDate(_createBookingDate),
    );
  }

  void _syncCreateBookingTurf() {
    final turfs = _turfController.turfs.where((turf) => turf.id != null);
    if (!turfs.any((turf) => turf.id == _createBookingTurfId)) {
      _createBookingTurfId = turfs.isEmpty ? null : turfs.first.id;
      _selectedCreateBookingSlotIds.clear();
    }
  }

  TurfItem? _selectedCreateBookingTurf() {
    for (final turf in _turfController.turfs) {
      if (turf.id == _createBookingTurfId) return turf;
    }
    return null;
  }

  Widget _dialogField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: keyboardType == TextInputType.phone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  StatusType _statusType(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('cancel')) return StatusType.cancelled;
    if (normalized.contains('pending')) return StatusType.pending;
    if (normalized.contains('complete')) return StatusType.completed;
    return StatusType.active;
  }

  Color _amountColor(StatusType status) {
    if (status == StatusType.cancelled) return AppColors.red;
    if (status == StatusType.pending) return AppColors.amber;
    return AppColors.green;
  }

  String _statusLabel(String status) {
    final cleaned = status.trim();
    if (cleaned.isEmpty) return 'Confirmed';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .map((part) => part.isEmpty
            ? part
            : '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String _labelStatic(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return '-';
    return cleaned
        .split(RegExp(r'[_\s-]+'))
        .map((part) => part.isEmpty
            ? part
            : '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _apiDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
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
}
