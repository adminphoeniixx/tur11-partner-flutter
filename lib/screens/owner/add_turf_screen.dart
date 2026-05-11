import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

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
    'Water & Drinking',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Add New Turf',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Fill details to go live on Turf11',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        _section(
          icon: Icons.grid_view,
          title: 'Basic Information',
          children: [
            _field('Turf Name', 'e.g. DLF Arena Cricket Box'),
            _dropdown('Sport Type', 'Cricket',
                ['Cricket', 'Football', 'Badminton', 'Basketball']),
            _dropdown('Format', '6v6', ['6v6', '8v8', '11v11', 'Box Cricket']),
            _price('Weekday Price / Hour', '800'),
            _price('Weekend Price / Hour', '1000'),
            _price('Peak Hours Price', '1200'),
            _field('Max Capacity (players)', '22',
                keyboardType: TextInputType.number),
            const FieldLabel('Description'),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText:
                      'Describe pitch quality, facilities and unique features.'),
            ),
          ],
        ),
        _section(
          icon: Icons.location_on_outlined,
          title: 'Location',
          children: [
            _field('Full Address',
                'Plot 12, Sector 29, Gurugram, Haryana 122002'),
            _field('City', 'Gurugram'),
            _field('State', 'Haryana'),
            _field('PIN Code', '122002', keyboardType: TextInputType.number),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 30, color: AppColors.muted2),
                    SizedBox(height: 8),
                    Text('Tap to pin location on map',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted)),
                  ]),
            ),
          ],
        ),
        _section(
          icon: Icons.photo_library_outlined,
          title: 'Photos & Videos',
          children: const [
            Text('Upload clear photos of pitch, lights and facilities.',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
            SizedBox(height: 14),
            UploadZone(
                label: 'Upload turf photos',
                subtitle: 'JPG/PNG, max 8MB per image'),
          ],
        ),
        _section(
          icon: Icons.check_circle_outline,
          title: 'Amenities & Facilities',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'LED Floodlights',
                'Changing Rooms',
                'Free Parking',
                'Food & Snacks',
                'Cafe / Canteen',
                'Water & Drinking',
                'CCTV Security',
                'Free Wi-Fi',
                'First Aid Kit',
                'Spectator Seating',
              ].map(_amenityChip).toList(),
            ),
          ],
        ),
        PrimaryButton(
            label: 'Submit for Review',
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

  Widget _price(String label, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      PrefixInput(
          prefix: 'Rs', hint: hint, keyboardType: TextInputType.number),
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

  Widget _amenityChip(String name) {
    final isOn = _amenities.contains(name);
    return GestureDetector(
      onTap: () =>
          setState(() => isOn ? _amenities.remove(name) : _amenities.add(name)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: isOn ? AppColors.greenLt : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isOn ? AppColors.green : AppColors.border),
        ),
        child: Text(name,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isOn ? AppColors.green : AppColors.muted)),
      ),
    );
  }
}




