import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Terms & Policies',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        const Text('Turf11 owner agreements and platform policies',
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Owner Terms of Service',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Last updated: April 2025 - Version 3.1',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 16),
            _policySection(Icons.shield_outlined, 'Acceptance & Eligibility',
                'You confirm that you are at least 18 years old and authorized to operate the listed sports facility.'),
            _policySection(Icons.grid_view, 'Turf Listing Standards',
                'Turf listings must accurately describe facilities, pricing and amenities.'),
            _policySection(Icons.work_outline, 'Booking & Cancellation',
                'Owner cancellations within 24 hours may incur a penalty. Player refunds follow the cancellation window.'),
            _policySection(Icons.attach_money, 'Payments & Payouts',
                'Turf11 collects platform fees on bookings and processes payouts to your registered bank account.'),
            _policySection(Icons.emoji_events_outlined, 'Tournament Rules',
                'Tournament organizers must clearly publish rules, prize details and eligibility before accepting entries.'),
            _policySection(Icons.lock_outline, 'Data & Privacy',
                'Owner and player data is handled according to applicable privacy regulations.'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(children: [
                AppToggle(value: true),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I have read and agree to Turf11 owner terms, cancellation policy and refund policy.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
                label: 'Accept & Continue',
                bgColor: AppColors.green,
                compact: true,
                onPressed: () {}),
          ]),
        ),
      ]),
    );
  }

  Widget _policySection(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: AppColors.greenLt,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: AppColors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(body,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.muted, height: 1.55)),
          ]),
        ),
      ]),
    );
  }
}





