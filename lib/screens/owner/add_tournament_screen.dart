import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AddTournamentScreen extends StatelessWidget {
  const AddTournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Add Tournament',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Create and publish a tournament on Turf11',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        _section(
          icon: Icons.emoji_events_outlined,
          title: 'Tournament Details',
          children: [
            _field('Tournament Name', 'e.g. Gurugram T10 Cup 2025'),
            _dropdown('Sport', 'Cricket', ['Cricket', 'Football', 'Badminton']),
            _dropdown('Format', 'T10',
                ['T10', 'T20', 'ODI', 'Box Cricket', 'Round Robin']),
            _field('Start Date', 'Select date',
                keyboardType: TextInputType.datetime),
            _field('End Date', 'Select date',
                keyboardType: TextInputType.datetime),
            _dropdown('Venue / Turf', 'DLF Arena Cricket',
                ['DLF Arena Cricket', 'Sector 56 Box', 'CyberHub Arena']),
            _field('Max Teams', '16', keyboardType: TextInputType.number),
            const FieldLabel('Tournament Description'),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText:
                      'Describe format, rules overview and special features.'),
            ),
            const FieldLabel('Tournament Poster / Banner'),
            const UploadZone(
                label: 'Upload tournament poster',
                subtitle: 'Recommended 1200 x 630 px'),
          ],
        ),
        _section(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Entry & Prize',
          children: [
            _price('Entry Fee / Team', '500'),
            _price('Platform Fee %', '5', prefix: '%'),
            _price('1st Prize', '5000'),
            _price('2nd Prize', '2000'),
            _price('3rd Prize', '1000'),
          ],
        ),
        PrimaryButton(
            label: 'Publish Tournament',
            bgColor: AppColors.green,
            compact: true,
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
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('Save as Draft',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark)),
          ),
        ),
      ]),
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

  Widget _field(String label, String hint, {TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }

  Widget _price(String label, String hint, {String prefix = 'Rs'}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      PrefixInput(prefix: prefix, hint: hint, keyboardType: TextInputType.number),
    ]);
  }

  Widget _dropdown(String label, String value, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (_) {},
      ),
    ]);
  }
}




