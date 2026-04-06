import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/shared_widgets.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';
import 'app_screens.dart';

class AppShell extends StatefulWidget {
  final VoidCallback onLogout;
  const AppShell({super.key, required this.onLogout});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _currentScreen = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Map<String, String> _titles = {
    'dashboard': 'Dashboard',
    'notifications': 'Notifications',
    'my_turfs': 'My Turfs',
    'add_turf': 'Add Turf',
    'manage_slots': 'Manage Slots',
    'bookings': 'Bookings',
    'turf_reviews': 'Turf Reviews',
    'tournaments': 'Tournaments',
    'add_tournament': 'Add Tournament',
    'tourney_registrations': 'Registrations',
    'tourney_reviews': 'Tournament Reviews',
    'payments': 'Payments',
    'cancellations': 'Cancellations & Refunds',
    'profile': 'Profile',
    'verify': 'Verification',
    'terms': 'Terms & Policies',
  };

  void _navigate(String screen) {
    setState(() => _currentScreen = screen);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case 'dashboard':
        return DashboardScreen(onNavigate: _navigate);
      case 'notifications':
        return const NotificationsScreen();
      case 'my_turfs':
        return MyTurfsScreen(onNavigate: _navigate);
      case 'add_turf':
        return const AddTurfScreen();
      case 'manage_slots':
        return const ManageSlotsScreen();
      case 'bookings':
        return const BookingsScreen();
      case 'turf_reviews':
        return const TurfReviewsScreen();
      case 'tournaments':
        return TournamentsScreen(onNavigate: _navigate);
      case 'add_tournament':
        return const AddTournamentScreen();
      case 'tourney_registrations':
        return const TourneyRegistrationsScreen();
      case 'tourney_reviews':
        return const TourneyReviewsScreen();
      case 'payments':
        return const PaymentsScreen();
      case 'cancellations':
        return const CancellationsScreen();
      case 'profile':
        return const ProfileScreen();
      case 'verify':
        return const VerificationScreen();
      case 'terms':
        return const TermsScreen();
      default:
        return DashboardScreen(onNavigate: _navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg,
      drawer: isWide
          ? null
          : AppSidebar(currentScreen: _currentScreen, onNavigate: _navigate),
      body: Row(
        children: [
          // Persistent sidebar on wide screens
          if (isWide)
            SizedBox(
              width: 240,
              child: AppSidebar(currentScreen: _currentScreen, onNavigate: _navigate),
            ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: const Border(bottom: BorderSide(color: AppColors.border)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (!isWide)
                        GestureDetector(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.bg2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.menu, size: 16),
                          ),
                        ),
                      if (!isWide) const SizedBox(width: 12),
                      Text(
                        _titles[_currentScreen] ?? 'Turf11',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark),
                      ),
                      const Spacer(),
                      // Notification bell
                      GestureDetector(
                        onTap: () => _navigate('notifications'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.bg2,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Stack(
                            children: [
                              const Center(child: Icon(Icons.notifications_outlined, size: 16, color: AppColors.muted)),
                              Positioned(
                                top: 6, right: 6,
                                child: Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.white, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Profile avatar
                      GestureDetector(
                        onTap: () => _navigate('profile'),
                        child: const AppAvatar(initials: 'VS', size: 36, bg: AppColors.dark),
                      ),
                    ],
                  ),
                ),
                // Screen content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _buildScreen(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
