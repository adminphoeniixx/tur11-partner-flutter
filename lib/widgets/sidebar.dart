import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final String currentScreen;
  final ValueChanged<String> onNavigate;

  const AppSidebar({super.key, required this.currentScreen, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.dark,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            // Brand
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08)))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Turf', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                      const Text('11', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.greenBright)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('OWNER PANEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.4), letterSpacing: 0.8)),
                ],
              ),
            ),
            // Navigation
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Overview'),
                    _navItem('Dashboard', Icons.grid_view_rounded, 'dashboard'),
                    _navItem('Notifications', Icons.notifications_outlined, 'notifications'),
                    _sectionLabel('Turf Management'),
                    _navItem('My Turfs', Icons.sports_cricket, 'my_turfs'),
                    _navItem('Add Turf', Icons.add_circle_outline, 'add_turf'),
                    _navItem('Manage Slots', Icons.calendar_month, 'manage_slots'),
                    _navItem('Bookings', Icons.description_outlined, 'bookings'),
                    _navItem('Turf Reviews', Icons.star_outline, 'turf_reviews'),
                    _sectionLabel('Tournaments'),
                    _navItem('Tournaments', Icons.emoji_events_outlined, 'tournaments'),
                    _navItem('Add Tournament', Icons.add_circle_outline, 'add_tournament'),
                    _navItem('Registrations', Icons.group_add_outlined, 'tourney_registrations'),
                    _navItem('Tournament Reviews', Icons.rate_review_outlined, 'tourney_reviews'),
                    _sectionLabel('Finance'),
                    _navItem('Payments', Icons.account_balance_wallet_outlined, 'payments'),
                    _navItem('Cancellations', Icons.cancel_outlined, 'cancellations'),
                    _sectionLabel('Account'),
                    _navItem('Profile', Icons.person_outline, 'profile'),
                    _navItem('Verification', Icons.verified_user_outlined, 'verify'),
                    _navItem('Terms & Policies', Icons.description_outlined, 'terms'),
                  ],
                ),
              ),
            ),
            // User
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08)))),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('VS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vikram Singh',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                        Text('Turf Owner · Gurugram',
                            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.45))),
                      ],
                    ),
                  ),
                  Icon(Icons.logout, size: 16, color: Colors.white.withOpacity(0.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.3), letterSpacing: 1),
      ),
    );
  }

  Widget _navItem(String label, IconData icon, String screen) {
    final isOn = currentScreen == screen;
    return GestureDetector(
      onTap: () => onNavigate(screen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: isOn ? AppColors.greenBright.withOpacity(0.12) : Colors.transparent,
          border: Border(left: BorderSide(color: isOn ? AppColors.greenBright : Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isOn ? AppColors.greenBright : Colors.white.withOpacity(0.65)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isOn ? FontWeight.w600 : FontWeight.w500,
                color: isOn ? AppColors.greenBright : Colors.white.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
