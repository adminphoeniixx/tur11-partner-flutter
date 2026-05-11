import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Business Verification',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Complete verification to unlock all features',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.greenLt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.green),
          ),
          child: const Row(children: [
            Icon(Icons.verified_user_outlined,
                size: 22, color: AppColors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Verified owners get priority listing, higher booking trust and faster payouts. Review usually takes 24-48 hours.',
                style:
                    TextStyle(fontSize: 13, color: AppColors.dark, height: 1.45),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        _step(
          done: true,
          title: 'Mobile OTP Verified',
          subtitle: '+91 9876543210 confirmed',
        ),
        _step(
          done: true,
          title: 'GST Registration',
          subtitle: '29AAAAA0000A1Z5 verified',
        ),
        _step(
          number: '3',
          title: 'Business PAN / Aadhaar',
          subtitle: 'Upload owner Aadhaar or business PAN',
          showUpload: true,
        ),
        _step(
          number: '4',
          title: 'Bank Account Verification',
          subtitle: 'Verify bank account for payouts via penny drop',
          disabled: true,
        ),
        _step(
          number: '5',
          title: 'Turf Location Verification',
          subtitle: 'Confirm turf GPS coordinates match your address',
          disabled: true,
        ),
      ]),
    );
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
                    if (done) ...[
                      const SizedBox(height: 8),
                      AppBadge.green('Complete'),
                    ],
                  ]),
            ),
          ]),
          if (showUpload) ...[
            const SizedBox(height: 14),
            const UploadZone(label: 'Upload Aadhaar / PAN'),
            const SizedBox(height: 10),
            PillButton(
              label: 'Upload & Verify',
              icon: Icons.upload,
              onPressed: disabled ? null : () {},
            ),
          ],
        ]),
      ),
    );
  }
}




