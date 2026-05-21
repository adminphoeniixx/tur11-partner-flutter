import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/turf_controller.dart';
import '../../models/turf_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AddTurfScreen extends StatefulWidget {
  final ValueChanged<String>? onNavigate;

  const AddTurfScreen({super.key, this.onNavigate});

  @override
  State<AddTurfScreen> createState() => _AddTurfScreenState();
}

class _AddTurfScreenState extends State<AddTurfScreen> {
  final TurfController _controller = TurfController();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController(text: 'Gurugram');
  final _state = TextEditingController(text: 'Haryana');
  final _weekdayPrice = TextEditingController();
  final _weekendPrice = TextEditingController();
  final _maxCapacity = TextEditingController(text: '22');
  final _openTime = TextEditingController(text: '6:00 AM');
  final _closeTime = TextEditingController(text: '11:00 PM');
  final _description = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];
  final List<XFile> _videos = [];

  String _sportType = 'cricket';
  bool _isLocating = false;
  final Set<String> _amenities = {
    'Floodlights',
    'Changing Room',
    'Parking',
    'Water',
  };

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    for (final controller in [
      _name,
      _address,
      _city,
      _state,
      _weekdayPrice,
      _weekendPrice,
      _maxCapacity,
      _openTime,
      _closeTime,
      _description,
    ]) {
      controller.dispose();
    }
    super.dispose();
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
          const Text('Add New Turf',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Fill details to go live on Turf11',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_controller.errorMessage!,
                style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ],
          const SizedBox(height: 14),
          _section(
            icon: Icons.grid_view,
            title: 'Basic Information',
            children: [
              _field('Turf Name', 'e.g. DLF Arena Cricket Box', _name),
              _dropdown(
                'Sport Type',
                _sportType,
                const {
                  'cricket': 'Cricket',
                  'football': 'Football',
                  'badminton': 'Badminton',
                  'basketball': 'Basketball',
                },
              ),
              _price('Weekday Price / Hour', '800', _weekdayPrice),
              _price('Weekend Price / Hour', '1000', _weekendPrice),
              _field('Max Capacity (players)', '22', _maxCapacity,
                  keyboardType: TextInputType.number),
              _timeField('Opening Time', _openTime),
              _timeField('Closing Time', _closeTime),
              const FieldLabel('Description'),
              TextFormField(
                controller: _description,
                maxLines: 4,
                validator: _required,
                decoration: const InputDecoration(
                  hintText:
                      'Describe pitch quality, facilities and unique features.',
                ),
              ),
            ],
          ),
          _section(
            icon: Icons.location_on_outlined,
            title: 'Location',
            children: [
              _field('Full Address',
                  'Plot 12, Sector 29, Gurugram, Haryana 122002', _address),
              _field('City', 'Gurugram', _city),
              _field('State', 'Haryana', _state),
              const Text(
                'Location coordinates will be added automatically from this address.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          _section(
            icon: Icons.photo_library_outlined,
            title: 'Photos & Videos',
            children: [
              const Text('Upload clear media from your phone.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
              Row(children: [
                Expanded(
                  child: SmallButton.ghost(
                    'Add Photos',
                    icon: Icons.photo_library_outlined,
                    onPressed: _pickPhotos,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SmallButton.ghost(
                    'Add Video',
                    icon: Icons.video_library_outlined,
                    onPressed: _pickVideo,
                  ),
                ),
              ]),
              _photoPreview(),
              _videoPreview(),
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
                  'Floodlights',
                  'Changing Room',
                  'Parking',
                  'Food & Snacks',
                  'Cafe / Canteen',
                  'Water',
                  'CCTV Security',
                  'Free Wi-Fi',
                  'First Aid Kit',
                  'Spectator Seating',
                ].map(_amenityChip).toList(),
              ),
            ],
          ),
          PrimaryButton(
            label: _controller.isSaving || _isLocating
                ? 'Submitting...'
                : 'Submit for Review',
            bgColor: AppColors.green,
            compact: true,
            onPressed: _controller.isSaving || _isLocating ? null : _submit,
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final coordinates = await _coordinatesFromAddress();
    if (coordinates == null) return;
    final request = CreateTurfRequest(
      name: _name.text.trim(),
      sportType: _sportType,
      address: _address.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      latitude: coordinates.latitude.toString(),
      longitude: coordinates.longitude.toString(),
      maxCapacity: _maxCapacity.text.trim(),
      pricePerHour: _weekdayPrice.text.trim(),
      priceWeekend: _weekendPrice.text.trim(),
      operatingHoursOpen: _apiTimeFromText(_openTime.text),
      operatingHoursClose: _apiTimeFromText(_closeTime.text),
      description: _description.text.trim(),
      amenities: _amenities.toList(),
      photoPaths: _photos.map((photo) => photo.path).toList(),
      videoPaths: _videos.map((video) => video.path).toList(),
    );

    final saved = await _controller.create(request);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved
            ? 'Turf submitted for review.'
            : _controller.errorMessage ?? 'Unable to create turf.'),
        backgroundColor: saved ? AppColors.green : AppColors.red,
      ),
    );
    if (saved) {
      _formKey.currentState!.reset();
      setState(() {
        _photos.clear();
        _videos.clear();
      });
      widget.onNavigate?.call('my_turfs');
    }
  }

  Future<_Coordinates?> _coordinatesFromAddress() async {
    final address = [
      _address.text.trim(),
      _city.text.trim(),
      _state.text.trim(),
    ].where((part) => part.isNotEmpty).join(', ');

    setState(() => _isLocating = true);
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        throw Exception('No location found');
      }
      final first = locations.first;
      return _Coordinates(first.latitude, first.longitude);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to find location from address.'),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 82);
      if (files.isEmpty) return;
      setState(() => _photos.addAll(files));
    } catch (_) {
      _showPickerError();
    }
  }

  Future<void> _pickVideo() async {
    try {
      final file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      setState(() => _videos.add(file));
    } catch (_) {
      _showPickerError();
    }
  }

  void _showPickerError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Media picker is not ready. Restart the app and try again.'),
        backgroundColor: AppColors.red,
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 17, color: AppColors.dark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 16),
          ..._spaced(children),
        ]),
      ),
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
    String hint,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool required = true,
    int maxLines = 1,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: required ? _required : null,
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }

  Widget _price(String label, String hint, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      PrefixInput(
        prefix: 'Rs',
        hint: hint,
        controller: controller,
        keyboardType: TextInputType.number,
      ),
    ]);
  }

  Widget _timeField(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      TextFormField(
        controller: controller,
        readOnly: true,
        validator: _required,
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.schedule),
        ),
        onTap: () => _pickTime(controller),
      ),
    ]);
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = _apiTimeFromText(controller.text).split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 6,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    controller.text = _displayTime(picked);
  }

  Widget _photoPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Photos (${_photos.length})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        if (_photos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('No file selected',
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
          )
        else ...[
          const SizedBox(height: 10),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 520 ? 4 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _photos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) => _photoTile(_photos[index], index),
            );
          }),
        ],
      ]),
    );
  }

  Widget _photoTile(XFile photo, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(fit: StackFit.expand, children: [
        Image.file(
          File(photo.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.border,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColors.muted),
            );
          },
        ),
        Positioned(
          right: 4,
          top: 4,
          child: _removeMediaButton(() {
            setState(() => _photos.removeAt(index));
          }),
        ),
        Positioned(
          left: 6,
          right: 6,
          bottom: 5,
          child: Text(
            _fileName(photo.path),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _videoPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Videos (${_videos.length})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        if (_videos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('No file selected',
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
          )
        else ...[
          const SizedBox(height: 8),
          ...List.generate(_videos.length, (index) {
            final video = _videos[index];
            return Container(
              margin:
                  EdgeInsets.only(bottom: index == _videos.length - 1 ? 0 : 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.greenLt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.play_circle_outline,
                      color: AppColors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileName(video.path),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        const Text('Ready to upload',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ]),
                ),
                IconButton(
                  onPressed: () => setState(() => _videos.removeAt(index)),
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.red,
                  tooltip: 'Remove video',
                ),
              ]),
            );
          }),
        ],
      ]),
    );
  }

  Widget _removeMediaButton(VoidCallback onPressed) {
    return Material(
      color: Colors.black.withOpacity(0.62),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 26,
          height: 26,
          child: Icon(Icons.close, size: 15, color: Colors.white),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, Map<String, String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(),
        value: value,
        items: items.entries
            .map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _sportType = value);
        },
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String _fileName(String path) {
    return path.split(RegExp(r'[\\/]')).last;
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

class _Coordinates {
  final double latitude;
  final double longitude;

  const _Coordinates(this.latitude, this.longitude);
}
