import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ManageSlotsScreen extends StatelessWidget {
  const ManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Manage Slots',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Monday, April 7 - DLF Arena Cricket',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              SmallButton.ghost('Add Slot', icon: Icons.add),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: text)),
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
}

class _Slot {
  final String time, info;
  final SlotState state;
  _Slot(this.time, this.info, this.state);
}

enum SlotState { booked, available, blocked }




