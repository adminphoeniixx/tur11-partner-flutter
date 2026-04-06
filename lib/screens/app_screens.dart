import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// ═══════════════════ MY TURFS ═══════════════════
class MyTurfsScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  const MyTurfsScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('My Turfs',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              const Text('3 turfs · 2 active · 1 pending review',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
            PillButton.green('Add Turf',
                icon: Icons.add, onPressed: () => onNavigate('add_turf')),
          ]),
          const SizedBox(height: 20),
          _turfCard('DLF Arena Cricket', 'Sector 29, Gurugram', '₹800', '4.2',
              '128', '75%', true, false),
          _turfCard('Sector 56 Cricket Box', 'Sector 56, Gurugram', '₹600',
              '4.7', '89', '50%', true, false),
          _turfCard('CyberHub Cricket Arena', 'CyberHub, Gurugram', '-', '-',
              '-', '-', false, true),
        ],
      ),
    );
  }

  Widget _turfCard(String name, String location, String price, String rating,
      String reviews, String occupancy, bool active, bool pending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 2))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: pending ? 0.75 : 1,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: active
                      ? [const Color(0xFF1A3A0A), const Color(0xFF2D5A1B)]
                      : [const Color(0xFF1A1A10), const Color(0xFF2A2A18)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 3),
                        Row(children: [
                          Icon(Icons.location_on,
                              size: 10, color: Colors.white.withOpacity(0.65)),
                          const SizedBox(width: 4),
                          Text(location,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.65))),
                        ]),
                      ]),
                  StatusBadge(
                      label: active ? 'Active' : 'Pending Review',
                      type: active ? StatusType.active : StatusType.pending),
                ],
              ),
            ),
            if (!pending)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(
                  children: [
                    _stat(price, 'per hour'),
                    _stat(rating, 'Rating', color: AppColors.green),
                    _stat(reviews, 'Reviews'),
                    _stat(occupancy, 'Occupancy'),
                  ],
                ),
              ),
            if (!pending)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SmallButton.ghost('Slots',
                        icon: Icons.calendar_month,
                        onPressed: () => onNavigate('manage_slots')),
                    SmallButton.ghost('Edit',
                        icon: Icons.edit_outlined,
                        onPressed: () => onNavigate('add_turf')),
                    SmallButton.ghost('Reviews',
                        icon: Icons.star_outline,
                        onPressed: () => onNavigate('turf_reviews')),
                    SmallButton.red('Deactivate', icon: Icons.block),
                  ],
                ),
              ),
            if (pending)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.access_time,
                      size: 16, color: AppColors.amber),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text(
                          'Under review by Turf11 team. Typically takes 24–48 hours.',
                          style:
                              TextStyle(fontSize: 13, color: AppColors.muted))),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color ?? AppColors.dark)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 9, color: AppColors.muted)),
        ],
      ),
    );
  }
}

// ═══════════════════ ADD TURF ═══════════════════
class AddTurfScreen extends StatefulWidget {
  const AddTurfScreen({super.key});
  @override
  State<AddTurfScreen> createState() => _AddTurfScreenState();
}

class _AddTurfScreenState extends State<AddTurfScreen> {
  final Set<String> _amenities = {
    'LED Floodlights',
    'Changing Rooms',
    'Free Parking',
    'Water & Drinking'
  };
  bool openSundays = true, openHolidays = true, autoPayout = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New Turf',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Fill details to go live on Turf11',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 20),

          // Basic Info
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.grid_view, size: 16, color: AppColors.dark),
                  const SizedBox(width: 8),
                  const Text('Basic Information',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                const FieldLabel('Turf Name'),
                TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'e.g. DLF Arena Cricket Box')),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Sport Type'),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(),
                          items: [
                            'Cricket',
                            'Football',
                            'Badminton',
                            'Basketball',
                            'Multi-sport'
                          ]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (_) {},
                          value: 'Cricket',
                        ),
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Format'),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(),
                          items: ['6v6', '8v8', '11v11', 'Box Cricket', 'T10']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (_) {},
                          value: '6v6',
                        ),
                      ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Weekday Price / Hour'),
                        const PrefixInput(
                            prefix: '₹',
                            hint: '800',
                            keyboardType: TextInputType.number),
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Weekend Price / Hour'),
                        const PrefixInput(
                            prefix: '₹',
                            hint: '1000',
                            keyboardType: TextInputType.number),
                      ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Peak Hours Price'),
                        const PrefixInput(
                            prefix: '₹',
                            hint: '1200',
                            keyboardType: TextInputType.number),
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Max Capacity (players)'),
                        TextFormField(
                            decoration: const InputDecoration(hintText: '22'),
                            keyboardType: TextInputType.number),
                      ])),
                ]),
                const SizedBox(height: 16),
                const FieldLabel('Description'),
                TextFormField(
                  maxLines: 4,
                  decoration: const InputDecoration(
                      hintText:
                          'Describe your turf — pitch quality, facilities, unique features...'),
                ),
              ])),

          // Location
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: 8),
                  const Text('Location',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                const FieldLabel('Full Address'),
                TextFormField(
                    decoration: const InputDecoration(
                        hintText:
                            'Plot 12, Sector 29, Gurugram, Haryana 122002')),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('City'),
                        TextFormField(
                            decoration:
                                const InputDecoration(hintText: 'Gurugram'))
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('State'),
                        TextFormField(
                            decoration:
                                const InputDecoration(hintText: 'Haryana'))
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('PIN Code'),
                        TextFormField(
                            decoration:
                                const InputDecoration(hintText: '122002'),
                            keyboardType: TextInputType.number)
                      ])),
                ]),
                const SizedBox(height: 16),
                // Map placeholder
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignCenter),
                  ),
                  child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.location_on_outlined,
                        size: 32, color: AppColors.muted2),
                    const SizedBox(height: 8),
                    const Text('Click to pin location on map',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted)),
                    const SizedBox(height: 4),
                    const Text('Or enter coordinates manually below',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.muted2)),
                  ])),
                ),
              ])),

          // Photos
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.photo_library_outlined, size: 16),
                  const SizedBox(width: 8),
                  const Text('Photos & Videos',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 4),
                const Text(
                    'Upload high quality images of pitch, facilities, lights, changing rooms etc.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 16),
                const UploadZone(
                    label: 'Drag & drop or click to upload photos',
                    subtitle: 'JPG, PNG · Max 8MB per image · Up to 12 photos'),
              ])),

          // Amenities
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  const Text('Amenities & Facilities',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'LED Floodlights',
                    'Changing Rooms',
                    'Free Parking',
                    'Food & Snacks',
                    'Café / Canteen',
                    'Water & Drinking',
                    'CCTV Security',
                    'Free Wi-Fi',
                    'First Aid Kit',
                    'Air Conditioning',
                    'Spectator Seating',
                    'Locker Facility',
                  ].map((a) => _amenityChip(a)).toList(),
                ),
              ])),

          // Submit
          PrimaryButton(
              label: 'Submit for Review',
              bgColor: AppColors.green,
              onPressed: () {}),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.dark, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save as Draft',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.dark)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _amenityChip(String name) {
    final isOn = _amenities.contains(name);
    return GestureDetector(
      onTap: () =>
          setState(() => isOn ? _amenities.remove(name) : _amenities.add(name)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isOn ? AppColors.greenLt : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isOn ? AppColors.green : AppColors.border, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_box_outlined,
              size: 14, color: isOn ? AppColors.green : AppColors.muted),
          const SizedBox(width: 6),
          Text(name,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isOn ? AppColors.green : AppColors.muted)),
        ]),
      ),
    );
  }
}

// ═══════════════════ MANAGE SLOTS ═══════════════════
class ManageSlotsScreen extends StatelessWidget {
  const ManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Slots',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Monday, April 7 — DLF Arena Cricket',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 20),

          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monday, April 7 — DLF Arena Cricket',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Wrap(spacing: 6, children: [
                        SmallButton.ghost('Add Slot', icon: Icons.add),
                        SmallButton.red('Block All', icon: Icons.close),
                      ]),
                    ]),
                const SectionLabel('Morning (6 AM – 12 PM)'),
                _slotGrid([
                  _Slot('6:00 AM', 'Rahul K. · ₹800', SlotState.booked),
                  _Slot('7:00 AM', 'Arjun K. · ₹800', SlotState.booked),
                  _Slot('8:00 AM', 'Available', SlotState.available),
                  _Slot('9:00 AM', 'Available', SlotState.available),
                  _Slot('10:00 AM', 'Available', SlotState.available),
                  _Slot('11:00 AM', 'Blocked', SlotState.blocked),
                ]),
                const SectionLabel('Afternoon (12 PM – 5 PM)'),
                _slotGrid([
                  _Slot('12:00 PM', 'Available', SlotState.available),
                  _Slot('1:00 PM', 'Available', SlotState.available),
                  _Slot('2:00 PM', 'Available', SlotState.available),
                  _Slot('3:00 PM', 'Available', SlotState.available),
                  _Slot('4:00 PM', 'Available', SlotState.available),
                ]),
                const SectionLabel('Evening / Peak (5 PM – 11 PM) · ₹1,200/hr'),
                _slotGrid([
                  _Slot('5:00 PM', 'Priya V. · ₹1,200', SlotState.booked),
                  _Slot('6:00 PM', 'Sahil R. · ₹1,200', SlotState.booked),
                  _Slot('7:00 PM', 'Rahul K. · ₹1,600', SlotState.booked),
                  _Slot('8:00 PM', 'Match · ₹1,200', SlotState.booked),
                  _Slot('9:00 PM', 'Available', SlotState.available),
                  _Slot('10:00 PM', 'Available', SlotState.available),
                ]),
              ])),

          // Dynamic Pricing
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Dynamic Pricing Rules',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Row(
                    children: [
                  _priceBox('Weekday', '₹800'),
                  const SizedBox(width: 12),
                  _priceBox('Weekend', '₹1,000'),
                  const SizedBox(width: 12),
                  _priceBox('Peak Hours (5–10 PM)', '₹1,200'),
                ].map((e) => Expanded(child: e)).toList()),
                const SizedBox(height: 14),
                const ToggleRow(
                    label: 'Dynamic surge pricing',
                    subtitle: 'Auto-increase price when >80% booked',
                    value: true),
                const Divider(color: AppColors.border),
                const ToggleRow(
                    label: 'Last-minute discount (1h before)',
                    subtitle: '20% off unsold slots',
                    value: false),
              ])),
        ],
      ),
    );
  }

  Widget _slotGrid(List<_Slot> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 110,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final s = slots[i];
        Color bg, borderColor, textColor;
        switch (s.state) {
          case SlotState.booked:
            bg = AppColors.dark;
            borderColor = AppColors.dark;
            textColor = Colors.white;
          case SlotState.available:
            bg = AppColors.greenLt;
            borderColor = AppColors.green;
            textColor = AppColors.green;
          case SlotState.blocked:
            bg = AppColors.redLt;
            borderColor = AppColors.red;
            textColor = AppColors.red;
        }
        return Container(
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5)),
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(s.time,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            const SizedBox(height: 2),
            Text(s.info,
                style: TextStyle(
                    fontSize: 9,
                    color: s.state == SlotState.booked
                        ? Colors.white.withOpacity(0.6)
                        : AppColors.muted),
                textAlign: TextAlign.center),
          ]),
        );
      },
    );
  }

  Widget _priceBox(String label, String price) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(price,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const Text('per hour',
            style: TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }
}

class _Slot {
  final String time, info;
  final SlotState state;
  _Slot(this.time, this.info, this.state);
}

enum SlotState { booked, available, blocked }

// ═══════════════════ BOOKINGS ═══════════════════
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bookings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('All bookings across your turfs',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final count = constraints.maxWidth > 700 ? 4 : 2;
            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.8,
              children: [
                StatCard(
                    label: 'Total Bookings',
                    value: '486',
                    change: 'This month',
                    isUp: true),
                StatCard(
                    label: 'Confirmed',
                    value: '442',
                    change: '91%',
                    isUp: true,
                    changeColor: AppColors.green),
                StatCard(
                    label: 'Cancelled',
                    value: '32',
                    change: '6.6%',
                    isUp: false),
                StatCard(
                    label: 'Pending Pay',
                    value: '12',
                    change: 'Action needed',
                    isUp: false,
                    changeColor: AppColors.amber),
              ],
            );
          }),
          const SizedBox(height: 16),
          AppCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bg2),
                headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    letterSpacing: 0.6),
                dataTextStyle:
                    const TextStyle(fontSize: 13, color: AppColors.dark),
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('BOOKING ID')),
                  DataColumn(label: Text('PLAYER')),
                  DataColumn(label: Text('TURF')),
                  DataColumn(label: Text('DATE & TIME')),
                  DataColumn(label: Text('PLAYERS')),
                  DataColumn(label: Text('AMOUNT')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: [
                  _row(
                      '#T11-4821',
                      'Rahul Kumar',
                      '9876543210',
                      'DLF Arena',
                      'Apr 7',
                      '7:00–9:00 PM',
                      '16',
                      '₹1,600',
                      AppColors.green,
                      StatusType.active,
                      'Confirmed'),
                  _row(
                      '#T11-4820',
                      'Arjun Kapoor',
                      '9812345678',
                      'Sector 56',
                      'Apr 7',
                      '5:00–7:00 PM',
                      '12',
                      '₹1,200',
                      AppColors.amber,
                      StatusType.pending,
                      'Pending Pay'),
                  _row(
                      '#T11-4819',
                      'Priya Verma',
                      '9876000111',
                      'DLF Arena',
                      'Apr 8',
                      '6:00–8:00 AM',
                      '8',
                      '₹800',
                      AppColors.green,
                      StatusType.active,
                      'Confirmed'),
                  _row(
                      '#T11-4818',
                      'Sahil Rawat',
                      '9900112233',
                      'CyberHub',
                      'Apr 6',
                      '8:00–10:00 PM',
                      '10',
                      '₹0',
                      AppColors.red,
                      StatusType.cancelled,
                      'Cancelled'),
                  _row(
                      '#T11-4817',
                      'Mohit Kumar',
                      '9988776655',
                      'DLF Arena',
                      'Apr 6',
                      '7:00–9:00 PM',
                      '16',
                      '₹1,600',
                      AppColors.green,
                      StatusType.completed,
                      'Completed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _row(
      String id,
      String name,
      String phone,
      String turf,
      String date,
      String time,
      String players,
      String amount,
      Color amtColor,
      StatusType status,
      String statusLabel) {
    return DataRow(cells: [
      DataCell(Text(id,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.muted))),
      DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(phone,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ])),
      DataCell(Text(turf)),
      DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(time,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ])),
      DataCell(Text(players)),
      DataCell(Text(amount,
          style: TextStyle(fontWeight: FontWeight.w700, color: amtColor))),
      DataCell(StatusBadge(label: statusLabel, type: status)),
      DataCell(SmallButton.ghost('View')),
    ]);
  }
}

// ═══════════════════ TURF REVIEWS ═══════════════════
class TurfReviewsScreen extends StatelessWidget {
  const TurfReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Turf Reviews',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Player feedback across all your turfs',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 20),
          // Rating Summary
          AppCard(
              child: Column(children: [
            const Text('4.2',
                style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800)),
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
          // Individual Reviews
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('All Reviews (128)',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _reviewItem(
                    'MK',
                    'Mohit Kumar',
                    'Apr 6 · DLF Arena · Cricket 8v8',
                    4,
                    '"Best cricket box in Gurugram. Super clean pitch and great lighting. Parking could be better but overall excellent."',
                    ['Great Pitch', 'Clean', 'Good Lighting']),
                const Divider(color: AppColors.border),
                _reviewItem(
                    'SA',
                    'Sahil Arora',
                    'Apr 3 · DLF Arena · Cricket T10',
                    3,
                    '"Good turf. Changing rooms need more space for a full team. The pitch is well maintained though."',
                    []),
              ])),
        ],
      ),
    );
  }

  Widget _ratingBar(int star, double pct, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
            width: 10,
            child: Text('$star',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(child: AppProgressBar(value: pct, height: 6)),
        const SizedBox(width: 8),
        SizedBox(
            width: 30,
            child: Text('$count',
                style: const TextStyle(fontSize: 10, color: AppColors.muted))),
      ]),
    );
  }

  Widget _catRow(String name, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name, style: const TextStyle(fontSize: 12)),
        Row(children: [
          const Icon(Icons.star, size: 11, color: AppColors.green),
          const SizedBox(width: 3),
          Text(rating.toString(),
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _reviewItem(String initials, String name, String meta, int stars,
      String text, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            AppAvatar(
                initials: initials, bg: AppColors.greenLt, fg: AppColors.green),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              Text(meta,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ]),
          StarRating(rating: stars.toDouble()),
        ]),
        const SizedBox(height: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.dark2, height: 1.6)),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
              spacing: 6,
              children: tags.map((t) => AppBadge.green(t)).toList()),
        ],
        const SizedBox(height: 8),
        SmallButton.ghost('Reply', icon: Icons.chat_bubble_outline),
      ]),
    );
  }
}

// ═══════════════════ TOURNAMENTS ═══════════════════
class TournamentsScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  const TournamentsScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tournaments',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              const Text('2 active · 1 upcoming · 5 completed',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
            PillButton.green('Add Tournament',
                icon: Icons.add, onPressed: () => onNavigate('add_tournament')),
          ]),
          const SizedBox(height: 20),
          AppCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bg2),
                headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    letterSpacing: 0.6),
                dataTextStyle:
                    const TextStyle(fontSize: 13, color: AppColors.dark),
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('TOURNAMENT')),
                  DataColumn(label: Text('SPORT')),
                  DataColumn(label: Text('DATES')),
                  DataColumn(label: Text('TEAMS')),
                  DataColumn(label: Text('PRIZE POOL')),
                  DataColumn(label: Text('REVENUE')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Gurugram T10 Cup',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Text('DLF Arena Cricket',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ])),
                    const DataCell(Text('Cricket')),
                    DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Apr 12–20',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Text('9 days',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ])),
                    DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('8/16',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Text('8 registered',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ])),
                    const DataCell(Text('₹5,000',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.green))),
                    const DataCell(Text('₹4,232',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                    const DataCell(StatusBadge(
                        label: 'Reg. Open', type: StatusType.pending)),
                    DataCell(Row(children: [
                      SmallButton.ghost('Teams',
                          onPressed: () => onNavigate('tourney_registrations')),
                      const SizedBox(width: 4),
                      SmallButton.ghost('Edit'),
                    ])),
                  ]),
                  DataRow(cells: [
                    DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sector 56 Blasters',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Text('Sector 56 Box',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ])),
                    const DataCell(Text('Cricket')),
                    DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Apr 19–26',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Text('8 days',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ])),
                    DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('0/8',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Text('Opens Apr 5',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ])),
                    const DataCell(Text('₹3,000',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.green))),
                    const DataCell(Text('₹0',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                    DataCell(AppBadge(
                        label: 'Upcoming',
                        bg: AppColors.border,
                        fg: AppColors.muted)),
                    DataCell(Row(children: [
                      SmallButton.ghost('Edit'),
                      const SizedBox(width: 4),
                      SmallButton.red('Cancel'),
                    ])),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════ ADD TOURNAMENT ═══════════════════
class AddTournamentScreen extends StatelessWidget {
  const AddTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Tournament',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Create and publish a tournament on Turf11',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 20),
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.emoji_events_outlined, size: 15),
                  const SizedBox(width: 8),
                  const Text('Tournament Details',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700))
                ]),
                const SizedBox(height: 16),
                const FieldLabel('Tournament Name'),
                TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'e.g. Gurugram T10 Cup 2025')),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Sport'),
                        DropdownButtonFormField<String>(
                            decoration: const InputDecoration(),
                            items: ['Cricket', 'Football', 'Badminton']
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (_) {},
                            value: 'Cricket'),
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Format'),
                        DropdownButtonFormField<String>(
                            decoration: const InputDecoration(),
                            items: [
                              'T10',
                              'T20',
                              'ODI',
                              'Box Cricket',
                              'Round Robin'
                            ]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (_) {},
                            value: 'T10'),
                      ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Start Date'),
                        TextFormField(
                            decoration:
                                const InputDecoration(hintText: 'Select date'),
                            keyboardType: TextInputType.datetime)
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('End Date'),
                        TextFormField(
                            decoration:
                                const InputDecoration(hintText: 'Select date'),
                            keyboardType: TextInputType.datetime)
                      ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Venue / Turf'),
                        DropdownButtonFormField<String>(
                            decoration: const InputDecoration(),
                            items: [
                              'DLF Arena Cricket',
                              'Sector 56 Box',
                              'CyberHub Arena'
                            ]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (_) {},
                            value: 'DLF Arena Cricket'),
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Max Teams'),
                        TextFormField(
                            decoration: const InputDecoration(hintText: '16'),
                            keyboardType: TextInputType.number)
                      ])),
                ]),
                const SizedBox(height: 16),
                const FieldLabel('Tournament Description'),
                TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                        hintText:
                            'Describe the tournament format, rules overview, special features...')),
                const SizedBox(height: 16),
                const FieldLabel('Tournament Poster / Banner'),
                const UploadZone(
                    label: 'Upload tournament poster',
                    subtitle: 'Recommended 1200×630px'),
              ])),
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 15),
                  const SizedBox(width: 8),
                  const Text('Entry & Prize',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700))
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Entry Fee / Team'),
                        const PrefixInput(
                            prefix: '₹',
                            hint: '500',
                            keyboardType: TextInputType.number)
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('Platform Fee %'),
                        const PrefixInput(
                            prefix: '%',
                            hint: '5',
                            keyboardType: TextInputType.number)
                      ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('1st Prize'),
                        const PrefixInput(
                            prefix: '₹',
                            hint: '5000',
                            keyboardType: TextInputType.number)
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('2nd Prize'),
                        const PrefixInput(
                            prefix: '₹',
                            hint: '2000',
                            keyboardType: TextInputType.number)
                      ])),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const FieldLabel('3rd Prize'),
                        const PrefixInput(
                            prefix: '₹',
                            hint: '1000',
                            keyboardType: TextInputType.number)
                      ])),
                ]),
              ])),
          PrimaryButton(
              label: 'Publish Tournament',
              bgColor: AppColors.green,
              onPressed: () {}),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.dark, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Save as Draft',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.dark)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ═══════════════════ TOURNAMENT REGISTRATIONS ═══════════════════
class TourneyRegistrationsScreen extends StatelessWidget {
  const TourneyRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Team Registrations',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Gurugram T10 Cup · 8/16 teams registered',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 20),
          AppCard(
              child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Registration Progress',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const Text('8 / 16 Teams',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green)),
            ]),
            const SizedBox(height: 8),
            const AppProgressBar(value: 0.5, height: 10),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('8 slots remaining',
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
              const Text('Closes Apr 10',
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ])),
          AppCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bg2),
                headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted),
                dataTextStyle:
                    const TextStyle(fontSize: 13, color: AppColors.dark),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('TEAM NAME')),
                  DataColumn(label: Text('CAPTAIN')),
                  DataColumn(label: Text('PLAYERS')),
                  DataColumn(label: Text('ENTRY FEE')),
                  DataColumn(label: Text('PAYMENT')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: [
                  _teamRow('1', 'Sector 29 Warriors', 'Rahul Kumar',
                      '9876543210', '12', '₹529', StatusType.active, 'Paid'),
                  _teamRow('2', 'Galaxy XI', 'Arjun Mehta', '9812345678', '11',
                      '₹529', StatusType.active, 'Paid'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _teamRow(String num, String team, String captain, String phone,
      String players, String fee, StatusType status, String statusLabel) {
    return DataRow(cells: [
      DataCell(Text(num,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.muted))),
      DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(team, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(captain,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ])),
      DataCell(Text(phone, style: const TextStyle(fontSize: 12))),
      DataCell(
          Text(players, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(fee,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.green))),
      DataCell(StatusBadge(label: statusLabel, type: status)),
      DataCell(Row(children: [
        SmallButton.ghost('View'),
        const SizedBox(width: 4),
        SmallButton.red('Remove')
      ])),
    ]);
  }
}

// ═══════════════════ TOURNAMENT REVIEWS ═══════════════════
class TourneyReviewsScreen extends StatelessWidget {
  const TourneyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tournament Reviews',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Team Reviews',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _review(
              'GX',
              AppColors.amberLt,
              AppColors.amber,
              'Galaxy XI',
              'Apr 22 · Finished 3rd',
              5,
              '"Fantastic event! Well-organised with fair umpiring throughout. Will definitely join next season."'),
          const Divider(color: AppColors.border),
          _review(
              'S9',
              AppColors.greenLt,
              AppColors.green,
              'Sector 9 Strikers',
              'Apr 21 · Runners-up',
              4,
              '"Good event but scheduling was chaotic on day 3. Prize money was paid within 2 days though."'),
        ])),
      ]),
    );
  }

  Widget _review(String initials, Color avBg, Color avFg, String name,
      String meta, int stars, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            AppAvatar(initials: initials, bg: avBg, fg: avFg),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              Text(meta,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ]),
          Text('★' * stars,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.dark2, height: 1.6)),
      ]),
    );
  }
}

// ═══════════════════ PAYMENTS ═══════════════════
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Payments',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            const Text('Revenue & payout tracking',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
          PillButton.ghost('Export CSV', icon: Icons.upload),
        ]),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final count = constraints.maxWidth > 700 ? 4 : 2;
          return GridView.count(
            crossAxisCount: count,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.8,
            children: [
              StatCard(
                  label: 'Total Revenue (Apr)',
                  value: '₹1,24,000',
                  change: '+18% vs Mar',
                  isUp: true),
              StatCard(
                  label: 'Settled to Bank',
                  value: '₹1,16,800',
                  change: 'Last payout Apr 1',
                  isUp: true,
                  changeColor: AppColors.muted),
              StatCard(
                  label: 'Pending Payout',
                  value: '₹7,200',
                  change: 'Processing',
                  isUp: false,
                  changeColor: AppColors.amber),
              StatCard(
                  label: 'Platform Fee (5%)',
                  value: '₹6,200',
                  change: 'Deducted',
                  isUp: false,
                  changeColor: AppColors.muted),
            ],
          );
        }),
        const SizedBox(height: 16),
        AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Payment Transactions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bg2),
                headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted),
                dataTextStyle:
                    const TextStyle(fontSize: 13, color: AppColors.dark),
                columns: const [
                  DataColumn(label: Text('TXN ID')),
                  DataColumn(label: Text('TYPE')),
                  DataColumn(label: Text('PLAYER / TEAM')),
                  DataColumn(label: Text('AMOUNT')),
                  DataColumn(label: Text('PLATFORM FEE')),
                  DataColumn(label: Text('NET EARNING')),
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('STATUS')),
                ],
                rows: [
                  _txnRow(
                      'TXN-8821042',
                      'Booking',
                      AppColors.greenLt,
                      AppColors.green,
                      'Rahul Kumar',
                      '₹1,600',
                      '−₹80',
                      '₹1,520',
                      AppColors.green,
                      'Apr 7',
                      StatusType.active,
                      'Settled'),
                  _txnRow(
                      'TXN-8821040',
                      'Tournament',
                      AppColors.blueLt,
                      AppColors.blue,
                      'Sector 29 Warriors',
                      '₹529',
                      '−₹26',
                      '₹503',
                      AppColors.green,
                      'Apr 5',
                      StatusType.active,
                      'Settled'),
                  _txnRow(
                      'TXN-8821038',
                      'Refund',
                      AppColors.redLt,
                      AppColors.red,
                      'Sahil Rawat',
                      '−₹600',
                      '—',
                      '−₹600',
                      AppColors.red,
                      'Apr 6',
                      StatusType.cancelled,
                      'Refunded'),
                  _txnRow(
                      'TXN-8821035',
                      'Booking',
                      AppColors.greenLt,
                      AppColors.green,
                      'Arjun Kapoor',
                      '₹1,200',
                      '—',
                      'Pending',
                      AppColors.amber,
                      'Apr 7',
                      StatusType.pending,
                      'Pending'),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  DataRow _txnRow(
      String id,
      String type,
      Color typeBg,
      Color typeFg,
      String name,
      String amount,
      String fee,
      String net,
      Color netColor,
      String date,
      StatusType status,
      String statusLabel) {
    return DataRow(cells: [
      DataCell(Text(id,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              fontSize: 11))),
      DataCell(AppBadge(label: type, bg: typeBg, fg: typeFg)),
      DataCell(Text(name)),
      DataCell(
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w700))),
      DataCell(Text(fee, style: const TextStyle(color: AppColors.red))),
      DataCell(Text(net,
          style: TextStyle(fontWeight: FontWeight.w700, color: netColor))),
      DataCell(Text(date,
          style: const TextStyle(fontSize: 12, color: AppColors.muted))),
      DataCell(StatusBadge(label: statusLabel, type: status)),
    ]);
  }
}

// ═══════════════════ CANCELLATIONS ═══════════════════
class CancellationsScreen extends StatelessWidget {
  const CancellationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cancellations & Refunds',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Track cancellations and process refunds',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final count = constraints.maxWidth > 700 ? 4 : 2;
          return GridView.count(
            crossAxisCount: count,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.8,
            children: [
              StatCard(
                  label: 'Cancellations (Apr)',
                  value: '32',
                  change: '6.6% of bookings',
                  isUp: false),
              StatCard(
                  label: 'Refunds Issued',
                  value: '₹14,200',
                  change: 'Auto-processed',
                  isUp: false,
                  changeColor: AppColors.muted),
              StatCard(
                  label: 'No-show Penalties',
                  value: '₹2,400',
                  change: '48 no-shows',
                  isUp: true),
              StatCard(
                  label: 'Pending Refunds',
                  value: '₹3,600',
                  change: '4 pending',
                  isUp: false,
                  changeColor: AppColors.amber),
            ],
          );
        }),
        const SizedBox(height: 16),
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cancellation Log',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bg2),
              headingTextStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted),
              dataTextStyle:
                  const TextStyle(fontSize: 13, color: AppColors.dark),
              columns: const [
                DataColumn(label: Text('BOOKING')),
                DataColumn(label: Text('PLAYER')),
                DataColumn(label: Text('TURF')),
                DataColumn(label: Text('CANCELLED AT')),
                DataColumn(label: Text('BEFORE MATCH')),
                DataColumn(label: Text('REFUND')),
                DataColumn(label: Text('STATUS')),
              ],
              rows: [
                _cancelRow(
                    '#T11-4818',
                    'Sahil Rawat',
                    'CyberHub Arena',
                    'Apr 6, 6:00 PM',
                    '2 hrs before',
                    AppColors.redLt,
                    AppColors.red,
                    '₹0 (no refund)',
                    AppColors.red,
                    StatusType.completed,
                    'Processed'),
                _cancelRow(
                    '#T11-4810',
                    'Priya Kapoor',
                    'DLF Arena',
                    'Apr 5, 10:00 AM',
                    '14 hrs before',
                    AppColors.amberLt,
                    AppColors.amber,
                    '₹600 (50%)',
                    AppColors.amber,
                    StatusType.active,
                    'Refunded'),
                _cancelRow(
                    '#T11-4802',
                    'Mohit Jain',
                    'Sector 56 Box',
                    'Apr 4, 9:00 AM',
                    '36 hrs before',
                    AppColors.greenLt,
                    AppColors.green,
                    '₹1,200 (full)',
                    AppColors.green,
                    StatusType.active,
                    'Refunded'),
                _cancelRow(
                    '#T11-4795',
                    'Karan Malhotra',
                    'DLF Arena',
                    'Apr 3, 4:00 PM',
                    '1 hr before',
                    AppColors.redLt,
                    AppColors.red,
                    '₹0 + ₹50 penalty',
                    AppColors.red,
                    StatusType.pending,
                    'Processing'),
              ],
            ),
          ),
        ])),
      ]),
    );
  }

  DataRow _cancelRow(
      String id,
      String name,
      String turf,
      String time,
      String before,
      Color beforeBg,
      Color beforeFg,
      String refund,
      Color refundColor,
      StatusType status,
      String statusLabel) {
    return DataRow(cells: [
      DataCell(Text(id,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              fontSize: 11))),
      DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(turf)),
      DataCell(Text(time,
          style: const TextStyle(fontSize: 12, color: AppColors.muted))),
      DataCell(AppBadge(label: before, bg: beforeBg, fg: beforeFg)),
      DataCell(Text(refund,
          style: TextStyle(fontWeight: FontWeight.w700, color: refundColor))),
      DataCell(StatusBadge(label: statusLabel, type: status)),
    ]);
  }
}

// ═══════════════════ PROFILE ═══════════════════
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Business Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            const Text('Manage your owner account details',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
          PillButton.green('Edit Profile', icon: Icons.edit),
        ]),
        const SizedBox(height: 20),

        // Profile Card
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const AppAvatar(initials: 'VS', size: 64, bg: AppColors.dark),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Vikram Singh',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              const Text('Turf Owner · Gurugram',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 8),
              Row(children: [
                const StatusBadge(label: 'Verified', type: StatusType.active),
                const SizedBox(width: 6),
                AppBadge.amber('Pro Owner'),
              ]),
            ]),
          ]),
          const Divider(color: AppColors.border, height: 24),
          _infoRow(Icons.smartphone, '+91 9876543210'),
          const SizedBox(height: 10),
          _infoRow(Icons.email_outlined, 'vikram@dlfarena.com'),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on_outlined, 'Gurugram, Haryana'),
          const SizedBox(height: 10),
          _infoRow(Icons.business, 'DLF Sports Arena Pvt. Ltd.'),
        ])),

        // Notification Preferences
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Notification Preferences',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const ToggleRow(label: 'New booking alerts', value: true),
          const Divider(color: AppColors.border),
          const ToggleRow(label: 'Payment received', value: true),
          const Divider(color: AppColors.border),
          const ToggleRow(label: 'Cancellation alerts', value: true),
          const Divider(color: AppColors.border),
          const ToggleRow(label: 'New reviews', value: true),
          const Divider(color: AppColors.border),
          const ToggleRow(label: 'Weekly earnings report', value: true),
        ])),

        // Business Stats
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Business Stats',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2,
            children: [
              _miniStat('Total Turfs', '3'),
              _miniStat('Total Bookings', '486'),
              _miniStat('Total Revenue', '₹1.24L', color: AppColors.green),
              _miniStat('Avg Rating', '4.2 ★', color: AppColors.green),
            ],
          ),
        ])),

        // Bank Details
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bank & Payment Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _bankRow('UPI ID', 'vikram@paytm'),
          const SizedBox(height: 8),
          _bankRow('Bank', 'HDFC Bank ••••4521'),
          const SizedBox(height: 8),
          _bankRow('GST', '29AAAAA0000A1Z5'),
          const SizedBox(height: 8),
          _bankRow('PAN', 'ABCDE1234F'),
          const SizedBox(height: 14),
          PillButton.ghost('Update Banking Details', icon: Icons.edit),
        ])),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.muted),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(fontSize: 13)),
    ]);
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.dark)),
      ]),
    );
  }

  Widget _bankRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ═══════════════════ VERIFICATION ═══════════════════
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Business Verification',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Complete verification to unlock all features',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.greenLt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green)),
          child: Row(children: [
            const Icon(Icons.verified_user_outlined,
                size: 20, color: AppColors.green),
            const SizedBox(width: 12),
            Expanded(
                child: RichText(
              text: const TextSpan(
                  style: TextStyle(
                      fontSize: 13, color: AppColors.dark, height: 1.5),
                  children: [
                    TextSpan(text: 'Verified owners get '),
                    TextSpan(
                        text: 'priority listing',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ', '),
                    TextSpan(
                        text: 'higher booking trust',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ', and '),
                    TextSpan(
                        text: 'faster payouts',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: '. Verification takes 24–48 hours.'),
                  ]),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        _step(true, null, 'Mobile OTP Verified', '+91 9876543210 confirmed',
            true),
        _step(true, null, 'GST Registration', '29AAAAA0000A1Z5 verified', true),
        _step(false, '3', 'Business PAN / Aadhaar',
            'Upload owner Aadhaar or business PAN', false,
            showUpload: true),
        _step(false, '4', 'Bank Account Verification',
            'Verify bank account for payouts via penny drop', false,
            disabled: true),
        _step(false, '5', 'Turf Location Verification',
            'Confirm turf GPS coordinates match your address', false,
            disabled: true),
      ]),
    );
  }

  Widget _step(
      bool done, String? number, String title, String subtitle, bool complete,
      {bool showUpload = false, bool disabled = false}) {
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.greenLt : AppColors.white,
              border: Border.all(
                  color: done
                      ? AppColors.green
                      : (number != null ? AppColors.dark : AppColors.border),
                  width: 2),
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check, size: 14, color: AppColors.green)
                : (number != null
                    ? Text(number,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: disabled ? AppColors.muted : AppColors.dark))
                    : null),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted)),
                if (complete) ...[
                  const SizedBox(height: 8),
                  AppBadge.green('Complete')
                ],
                if (showUpload) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: UploadZone(
                            label: 'Aadhaar Front',
                            icon: Icons.photo_outlined)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: UploadZone(
                            label: 'Aadhaar Back', icon: Icons.photo_outlined)),
                  ]),
                  const SizedBox(height: 6),
                  PillButton(
                    label: 'Upload & Verify',
                    icon: Icons.upload,
                    onPressed: disabled ? null : () {},
                  )
                ],
              ])),
        ]),
      ),
    );
  }
}

// ═══════════════════ TERMS & POLICIES ═══════════════════
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Terms & Policies',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Turf11 owner agreements and platform policies',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 20),
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Owner Terms of Service',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Last updated: April 2025 · Version 3.1',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 24),
          _policySection(Icons.shield_outlined, '1. Acceptance & Eligibility',
              'By registering as a Turf Owner or Tournament Organizer on Turf11, you confirm that you are at least 18 years of age and legally authorized to operate the listed sports facility.'),
          _policySection(Icons.grid_view, '2. Turf Listing Standards',
              'Turf listings must accurately describe the facility, amenities, and pricing. Misleading descriptions or fake photos will result in immediate suspension.'),
          _policySection(Icons.work_outline, '3. Booking & Cancellation',
              'Owner-initiated cancellations within 24 hours incur a 10% penalty. Players cancelling 24+ hours before receive a full refund; 6–24 hours receive 50%.'),
          _policySection(Icons.attach_money, '4. Payments & Payouts',
              'Turf11 collects a 5% platform fee on all booking revenue. Payouts are processed weekly every Monday to the registered bank account.'),
          _policySection(
              Icons.emoji_events_outlined,
              '5. Tournament Organizer Rules',
              'Tournament organizers must clearly state all rules, prize structures, and eligibility criteria before publishing. Entry fees are non-refundable unless the organizer cancels.'),
          _policySection(Icons.location_on_outlined, '6. Disputes & Liability',
              'Turf11 acts as a marketplace and is not liable for physical injuries or disputes arising on-venue. Legal jurisdiction is Gurugram, Haryana, India.'),
          _policySection(Icons.lock_outline, '7. Data & Privacy',
              'Owner business data and player transaction data are handled per India\'s DPDP Act 2023. Turf11 does not sell owner data to third parties.'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.bg2, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const AppToggle(value: true),
              const SizedBox(width: 12),
              const Expanded(
                  child: Text(
                      'I have read and agree to all Turf11 Owner Terms, Cancellation Policy, and Refund Policy',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500))),
            ]),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
              label: 'Accept & Continue',
              bgColor: AppColors.green,
              onPressed: () {}),
        ])),
      ]),
    );
  }

  Widget _policySection(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: AppColors.green),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text(body,
            style: const TextStyle(
                fontSize: 13, color: AppColors.muted, height: 1.85)),
      ]),
    );
  }
}
