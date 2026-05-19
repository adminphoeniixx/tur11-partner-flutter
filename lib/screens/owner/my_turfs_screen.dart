import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/turf_controller.dart';
import '../../models/turf_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class MyTurfsScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;
  const MyTurfsScreen({super.key, required this.onNavigate});

  @override
  State<MyTurfsScreen> createState() => _MyTurfsScreenState();
}

class _MyTurfsScreenState extends State<MyTurfsScreen> {
  final TurfController _controller = TurfController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final active = _controller.turfs.where((turf) => turf.isActive).length;
    final pending = _controller.turfs.where((turf) => turf.isPending).length;

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width:
                      compact ? constraints.maxWidth : constraints.maxWidth - 120,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Turfs',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(
                          '${_controller.turfs.length} turfs - $active active - $pending pending',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ]),
                ),
                PillButton.green('Add Turf',
                    icon: Icons.add,
                    onPressed: () => widget.onNavigate('add_turf')),
              ],
            );
          }),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_controller.errorMessage!,
                style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ],
          const SizedBox(height: 14),
          if (_controller.isLoading && _controller.turfs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.turfs.isEmpty)
            SizedBox(
              width: double.infinity,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No turfs found',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text(
                        'Create your first turf to start accepting slots.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 12),
                    PillButton.green('Add Turf',
                        icon: Icons.add,
                        onPressed: () => widget.onNavigate('add_turf')),
                  ],
                ),
              ),
            )
          else
            ..._controller.turfs.map(_turfCard),
        ]),
      ),
    );
  }

  Widget _turfCard(TurfItem turf) {
    final active = turf.isActive;
    final pending = turf.isPending;
    final statusType = active
        ? StatusType.active
        : pending
            ? StatusType.pending
            : StatusType.cancelled;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Opacity(
        opacity: pending ? 0.75 : 1,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? AppColors.dark : AppColors.dark2,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(turf.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 5),
                      Row(children: [
                        Icon(Icons.location_on,
                            size: 13, color: Colors.white.withOpacity(0.65)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(turf.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.65))),
                        ),
                      ]),
                    ]),
              ),
              const SizedBox(width: 10),
              StatusBadge(label: _label(turf.status), type: statusType),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (context, constraints) {
              final itemWidth = constraints.maxWidth < 330
                  ? (constraints.maxWidth - 8) / 2
                  : (constraints.maxWidth - 24) / 4;
              return Wrap(spacing: 8, runSpacing: 10, children: [
                _stat(turf.pricePerHour, 'per hour', width: itemWidth),
                _stat(turf.rating, 'rating',
                    color: AppColors.green, width: itemWidth),
                _stat(turf.reviews, 'reviews', width: itemWidth),
                _stat(turf.occupancy, 'filled', width: itemWidth),
              ]);
            }),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              SmallButton.ghost('Slots',
                  icon: Icons.calendar_month,
                  onPressed: () => widget.onNavigate('manage_slots')),
              SmallButton.ghost('Edit',
                  icon: Icons.edit_outlined,
                  onPressed:
                      turf.id == null ? null : () => _showEditDialog(turf)),
              SmallButton.ghost('Media',
                  icon: Icons.photo_library_outlined,
                  onPressed:
                      turf.id == null ? null : () => _showMediaDialog(turf)),
              SmallButton.ghost('Reviews',
                  icon: Icons.star_outline,
                  onPressed: () => widget.onNavigate('turf_reviews')),
              SmallButton.red(
                active ? 'Deactivate' : 'Activate',
                icon: active ? Icons.block : Icons.check_circle_outline,
                onPressed: turf.id == null || _controller.isSaving
                    ? null
                    : () => _toggle(turf),
              ),
            ]),
          ),
          if (pending)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(children: [
                Icon(Icons.access_time, size: 16, color: AppColors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Under review by Turf11 team. Typically takes 24-48 hours.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ),
              ]),
            ),
        ]),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(TurfItem turf) async {
    final name = TextEditingController(text: turf.name);
    final weekday = TextEditingController(text: _priceNumber(turf.pricePerHour));
    final weekend = TextEditingController(text: _priceNumber(turf.priceWeekend));
    final amenities = TextEditingController(text: turf.amenities.join(', '));

    final request = await showDialog<UpdateTurfRequest>(
      context: context,
      builder: (context) {
        return ResponsiveAlertDialog(
          title: const Text('Edit Turf'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField('Name', name),
              _dialogField('Weekday Price', weekday,
                  keyboardType: TextInputType.number),
              _dialogField('Weekend Price', weekend,
                  keyboardType: TextInputType.number),
              _dialogField('Amenities', amenities),
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
                UpdateTurfRequest(
                  name: name.text.trim(),
                  pricePerHour: weekday.text.trim(),
                  priceWeekend: weekend.text.trim(),
                  amenities: _csv(amenities.text),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    name.dispose();
    weekday.dispose();
    weekend.dispose();
    amenities.dispose();
    if (request == null || turf.id == null) return;
    final saved = await _controller.update(turf.id!, request);
    if (!mounted) return;
    _showResult(saved, 'Turf updated.');
  }

  Future<void> _showMediaDialog(TurfItem turf) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              12 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Upload photos from phone'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadPhotos(turf);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: const Text('Upload video from phone'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadVideo(turf);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove existing media URL'),
                onTap: () {
                  Navigator.pop(context);
                  _showRemoveMediaDialog(turf);
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadPhotos(TurfItem turf) async {
    if (turf.id == null) return;
    final List<XFile> files;
    try {
      files = await _picker.pickMultiImage(imageQuality: 82);
    } catch (_) {
      _showPickerError();
      return;
    }
    if (files.isEmpty) return;
    final saved = await _controller.uploadMedia(
      turfId: turf.id!,
      photoPaths: files.map((file) => file.path).toList(),
    );
    if (!mounted) return;
    _showResult(saved, 'Photos uploaded.');
  }

  Future<void> _pickAndUploadVideo(TurfItem turf) async {
    if (turf.id == null) return;
    final XFile? file;
    try {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    } catch (_) {
      _showPickerError();
      return;
    }
    if (file == null) return;
    final saved = await _controller.uploadMedia(
      turfId: turf.id!,
      videoPaths: [file.path],
    );
    if (!mounted) return;
    _showResult(saved, 'Video uploaded.');
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

  Future<void> _showRemoveMediaDialog(TurfItem turf) async {
    final url = TextEditingController();
    var type = 'photo';
    final result = await showDialog<_MediaAction>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return ResponsiveAlertDialog(
            title: const Text('Remove Media'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'photo', child: Text('Photo')),
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => type = value);
                },
              ),
              const SizedBox(height: 12),
              _dialogField('URL', url, keyboardType: TextInputType.url),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  _MediaAction(action: 'remove', type: type, url: url.text),
                ),
                child: const Text('Remove'),
              ),
            ],
          );
        });
      },
    );
    url.dispose();
    if (result == null || turf.id == null || result.url.isEmpty) return;
    final saved = await _controller.removeMedia(
      turfId: turf.id!,
      url: result.url.trim(),
      type: result.type,
    );
    if (!mounted) return;
    _showResult(saved, 'Media removed.');
  }

  Future<void> _toggle(TurfItem turf) async {
    final saved = await _controller.toggleStatus(turf.id!);
    if (!mounted) return;
    _showResult(saved, turf.isActive ? 'Turf deactivated.' : 'Turf activated.');
  }

  void _showResult(bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? successMessage
            : _controller.errorMessage ?? 'Unable to save changes.'),
        backgroundColor: success ? AppColors.green : AppColors.red,
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

  Widget _stat(String value, String label, {Color? color, double width = 70}) {
    return SizedBox(
      width: width,
      child: Column(children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.dark)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 9, color: AppColors.muted)),
      ]),
    );
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

  List<String> _csv(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _priceNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9.]'), '');
  }
}

class _MediaAction {
  final String action;
  final String type;
  final String url;

  const _MediaAction({
    required this.action,
    required this.type,
    required this.url,
  });
}
