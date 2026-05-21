import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/verification_controller.dart';
import '../../models/verification_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final VerificationController _controller = VerificationController();
  final ImagePicker _picker = ImagePicker();
  XFile? _document;
  String _docType = 'aadhaar';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.loadStatus();
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
    final status = _controller.status;

    return RefreshIndicator(
      onRefresh: _controller.loadStatus,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Business Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Complete verification to unlock all features',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_controller.errorMessage!,
                style: const TextStyle(color: AppColors.red, fontSize: 12)),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greenLt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.green),
            ),
            child: Row(children: [
              const Icon(Icons.verified_user_outlined,
                  size: 22, color: AppColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status?.message ??
                      'Verified owners get priority listing, higher booking trust and faster payouts. Review usually takes 24-48 hours.',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.dark, height: 1.45),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          if (_controller.isLoading && status == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            _step(
              done: status?.mobileVerified ?? false,
              title: 'Mobile OTP Verified',
              subtitle: _subtitle(
                status?.mobileSubtitle,
                fallback: (status?.mobileVerified ?? false)
                    ? 'Mobile number confirmed'
                    : 'Complete OTP verification from login',
              ),
            ),
            _step(
              done: status?.gstVerified ?? false,
              title: 'GST Registration',
              subtitle: _subtitle(
                status?.gstSubtitle,
                fallback: (status?.gstVerified ?? false)
                    ? 'GST details verified'
                    : 'GST verification is pending',
              ),
            ),
            _step(
              done: status?.documentVerified ?? false,
              number: '3',
              title: 'Business PAN / Aadhaar',
              subtitle: _subtitle(
                status?.documentSubtitle,
                fallback: (status?.documentVerified ?? false)
                    ? 'Identity document verified'
                    : 'Upload owner Aadhaar or business PAN',
              ),
              showUpload: !(status?.documentVerified ?? false),
            ),
            _step(
              done: status?.bankVerified ?? false,
              number: '4',
              title: 'Bank Account Verification',
              subtitle: _subtitle(
                status?.bankSubtitle,
                fallback: (status?.bankVerified ?? false)
                    ? 'Bank account verified for payouts'
                    : 'Verify bank account for payouts via penny drop',
              ),
              disabled: !(status?.documentVerified ?? false),
            ),
            _step(
              done: status?.locationVerified ?? false,
              number: '5',
              title: 'Turf Location Verification',
              subtitle: _subtitle(
                status?.locationSubtitle,
                fallback: (status?.locationVerified ?? false)
                    ? 'Turf location verified'
                    : 'Confirm turf GPS coordinates match your address',
              ),
              disabled: !(status?.bankVerified ?? false),
            ),
          ],
        ]),
      ),
    );
  }

  String _subtitle(String? value, {required String fallback}) {
    final text = value?.trim();
    if (text != null && text.isNotEmpty) return text;
    return fallback;
  }

  Widget _step({
    required String title,
    required String subtitle,
    bool done = false,
    String? number,
    bool showUpload = false,
    bool disabled = false,
  }) {
    final borderColor = done ? AppColors.green : AppColors.border;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.greenLt : AppColors.white,
                border: Border.all(color: borderColor, width: 2),
              ),
              alignment: Alignment.center,
              child: done
                  ? const Icon(Icons.check, size: 16, color: AppColors.green)
                  : Text(number ?? '',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                    const SizedBox(height: 8),
                    done
                        ? AppBadge.green('Complete')
                        : AppBadge.amber(disabled ? 'Locked' : 'Pending'),
                  ]),
            ),
          ]),
          if (showUpload) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _docType,
                  decoration: const InputDecoration(labelText: 'Document type'),
                  items: const [
                    DropdownMenuItem(value: 'aadhaar', child: Text('Aadhaar')),
                    DropdownMenuItem(value: 'pan', child: Text('PAN')),
                  ],
                  onChanged: _controller.isSaving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _docType = value);
                        },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            UploadZone(
              label: _document == null
                  ? 'Upload Aadhaar / PAN'
                  : _fileName(_document!.path),
              subtitle: _document == null
                  ? 'Tap to choose a clear image from gallery'
                  : 'Tap to choose a different file',
              onTap: _controller.isSaving ? null : _pickDocument,
            ),
            const SizedBox(height: 10),
            PillButton(
              label: _controller.isSaving ? 'Uploading...' : 'Upload & Verify',
              icon: Icons.upload,
              onPressed: disabled || _controller.isSaving ? null : _upload,
            ),
          ],
        ]),
      ),
    );
  }

  Future<void> _pickDocument() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );
      if (file == null) return;
      setState(() => _document = file);
    } catch (_) {
      _showSnack('Document picker is not ready. Restart the app and try again.',
          isError: true);
    }
  }

  Future<void> _upload() async {
    final document = _document;
    if (document == null) {
      _showSnack('Please choose a document image first.', isError: true);
      return;
    }

    final uploaded = await _controller.uploadDocument(
      docType: _docType,
      documentPath: document.path,
    );
    if (!mounted) return;

    _showSnack(
      uploaded
          ? _controller.lastResponse?.message ?? 'Document uploaded for review.'
          : _controller.errorMessage ?? 'Unable to upload document.',
      isError: !uploaded,
    );
    if (uploaded) {
      setState(() => _document = null);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.green,
      ),
    );
  }

  String _fileName(String path) {
    return path.split(RegExp(r'[\\/]')).last;
  }
}
