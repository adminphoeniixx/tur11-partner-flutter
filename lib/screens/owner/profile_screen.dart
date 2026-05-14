import 'package:flutter/material.dart';

import '../../controllers/profile_controller.dart';
import '../../models/profile_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileController? controller;

  const ProfileScreen({super.key, this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ProfileController();
    _controller.addListener(_onProfileChanged);
    if (_controller.profile == null && !_controller.isLoading) {
      _controller.loadProfile();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onProfileChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = _controller.profile;

    return RefreshIndicator(
      onRefresh: _controller.loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const SizedBox(
                width: 230,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Business Profile',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('Manage your owner account details',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
                    ]),
              ),
              PillButton.green(
                _controller.isSaving ? 'Saving...' : 'Edit Profile',
                icon: Icons.edit,
                onPressed: _controller.isSaving || profile == null
                    ? null
                    : () => _showEditProfileDialog(profile),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_controller.isLoading && profile == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.errorMessage != null && profile == null)
            _errorCard(_controller.errorMessage!)
          else
            ..._profileContent(profile ?? _fallbackProfile()),
        ]),
      ),
    );
  }

  List<Widget> _profileContent(OwnerProfile profile) {
    final location = [
      profile.city,
      profile.state,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
    final bank = profile.bankDetails;

    return [
      if (_controller.errorMessage != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _controller.errorMessage!,
            style: const TextStyle(color: AppColors.red, fontSize: 12),
          ),
        ),
      AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AppAvatar(initials: profile.initials, size: 60, bg: AppColors.dark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      'Turf Owner${profile.city == null ? '' : ' - ${profile.city}'}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ]),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            StatusBadge(
              label: profile.isVerified == false ? 'Pending' : 'Verified',
              type: profile.isVerified == false
                  ? StatusType.pending
                  : StatusType.active,
            ),
            AppBadge.amber('Pro Owner'),
          ]),
          const Divider(color: AppColors.border, height: 26),
          _infoRow(Icons.smartphone, _value(profile.phone)),
          _infoRow(Icons.email_outlined, _value(profile.email)),
          _infoRow(Icons.location_on_outlined, _value(location)),
          _infoRow(Icons.business, _value(profile.businessName)),
        ]),
      ),
      AppCard(
        padding: const EdgeInsets.all(12),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Notification Preferences',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          ToggleRow(label: 'New booking alerts', value: true),
          Divider(color: AppColors.border),
          ToggleRow(label: 'Payment received', value: true),
          Divider(color: AppColors.border),
          ToggleRow(label: 'Cancellation alerts', value: true),
          Divider(color: AppColors.border),
          ToggleRow(label: 'New reviews', value: true),
        ]),
      ),
      AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Business Stats',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.85,
            children: [
              _miniStat('Total Turfs', _statValue(profile, 'total_turfs', '3')),
              _miniStat('Bookings', _statValue(profile, 'bookings', '486')),
              _miniStat('Revenue', _statValue(profile, 'revenue', 'Rs 1.24L'),
                  color: AppColors.green),
              _miniStat('Rating', _statValue(profile, 'rating', '4.2'),
                  color: AppColors.green),
            ],
          ),
        ]),
      ),
      AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bank & Payment Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _bankRow('Account Holder', _value(bank?.accountHolder)),
          _bankRow('UPI ID', _value(bank?.upiId)),
          _bankRow('Bank', _bankSummary(bank)),
          _bankRow('IFSC', _value(bank?.ifsc)),
          _bankRow('GST', _value(profile.gstNumber)),
          _bankRow('PAN', _value(profile.panNumber)),
          const SizedBox(height: 12),
          PillButton.ghost(
            _controller.isSaving ? 'Saving...' : 'Update Banking Details',
            icon: Icons.edit,
            onPressed: _controller.isSaving
                ? null
                : () => _showBankDetailsDialog(bank),
          ),
        ]),
      ),
    ];
  }

  Widget _errorCard(String message) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Unable to load profile',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(message,
            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 14),
        PillButton.green(
          'Retry',
          icon: Icons.refresh,
          onPressed: _controller.loadProfile,
        ),
      ]),
    );
  }

  Future<void> _showEditProfileDialog(OwnerProfile profile) async {
    final name = TextEditingController(text: profile.displayName);
    final businessName =
        TextEditingController(text: profile.businessName ?? '');
    final email = TextEditingController(text: profile.email ?? '');
    final city = TextEditingController(text: profile.city ?? '');

    final request = await showDialog<UpdateProfileRequest>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField('Name', name),
              _dialogField('Business Name', businessName),
              _dialogField('Email', email,
                  keyboardType: TextInputType.emailAddress),
              _dialogField('City', city),
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
                UpdateProfileRequest(
                  name: name.text,
                  businessName: businessName.text,
                  email: email.text,
                  city: city.text,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    name.dispose();
    businessName.dispose();
    email.dispose();
    city.dispose();

    if (request == null) return;
    final saved = await _controller.updateProfile(request);
    if (!mounted) return;
    _showResult(saved, 'Profile updated');
  }

  Future<void> _showBankDetailsDialog(BankDetails? bank) async {
    final accountNumber =
        TextEditingController(text: bank?.accountNumber ?? '');
    final bankName = TextEditingController(text: bank?.bankName ?? '');
    final ifsc = TextEditingController(text: bank?.ifsc ?? '');
    final upiId = TextEditingController(text: bank?.upiId ?? '');
    final accountHolder =
        TextEditingController(text: bank?.accountHolder ?? '');

    final request = await showDialog<UpdateBankDetailsRequest>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bank Details'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField('Account Number', accountNumber,
                  keyboardType: TextInputType.number),
              _dialogField('Bank Name', bankName),
              _dialogField('IFSC', ifsc),
              _dialogField('UPI ID', upiId),
              _dialogField('Account Holder', accountHolder),
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
                UpdateBankDetailsRequest(
                  accountNumber: accountNumber.text,
                  bankName: bankName.text,
                  ifsc: ifsc.text,
                  upiId: upiId.text,
                  accountHolder: accountHolder.text,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    accountNumber.dispose();
    bankName.dispose();
    ifsc.dispose();
    upiId.dispose();
    accountHolder.dispose();

    if (request == null) return;
    final saved = await _controller.updateBankDetails(request);
    if (!mounted) return;
    _showResult(saved, 'Bank details updated');
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

  void _showResult(bool success, String successMessage) {
    final message = success
        ? successMessage
        : (_controller.errorMessage ?? 'Unable to save changes');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.green : AppColors.red,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        const Spacer(),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.dark)),
      ]),
    );
  }

  Widget _bankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  OwnerProfile _fallbackProfile() {
    return const OwnerProfile(
      name: 'Owner',
      businessName: 'Business profile',
    );
  }

  String _value(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) return 'Not added';
    return cleaned;
  }

  String _bankSummary(BankDetails? bank) {
    final name = bank?.bankName?.trim();
    final account = bank?.accountNumber?.trim();
    if ((name == null || name.isEmpty) &&
        (account == null || account.isEmpty)) {
      return 'Not added';
    }
    if (account == null || account.length < 4) return _value(name);
    return '${_value(name)} ****${account.substring(account.length - 4)}';
  }

  String _statValue(OwnerProfile profile, String key, String fallback) {
    final stats = profile.data['stats'];
    if (stats is Map && stats[key] != null) return stats[key].toString();
    final value = profile.data[key];
    return value == null ? fallback : value.toString();
  }
}
