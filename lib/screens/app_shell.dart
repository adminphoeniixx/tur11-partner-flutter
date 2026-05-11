import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
  final List<String> _history = [];

  static const Set<String> _rootScreens = {
    'dashboard',
    'my_turfs',
    'bookings',
    'payments',
    'more',
  };

  bool get _canGoBack => _history.isNotEmpty && !_rootScreens.contains(_currentScreen);

  void _navigate(String screen, {bool root = false}) {
    if (screen == _currentScreen) return;

    setState(() {
      if (root) {
        _history.clear();
      } else {
        _history.add(_currentScreen);
      }
      _currentScreen = screen;
    });
  }

  void _goBack() {
    if (_history.isEmpty) return;
    setState(() => _currentScreen = _history.removeLast());
  }

  int _bottomIndexFor(String screen) {
    switch (screen) {
      case 'dashboard':
        return 0;
      case 'my_turfs':
      case 'add_turf':
      case 'manage_slots':
      case 'turf_reviews':
        return 1;
      case 'bookings':
        return 2;
      case 'payments':
      case 'cancellations':
        return 3;
      case 'more':
      case 'profile':
      case 'verify':
      case 'terms':
      case 'tournaments':
      case 'add_tournament':
      case 'tourney_registrations':
      case 'tourney_reviews':
        return 4;
      default:
        return 0;
    }
  }

  void _onBottomTap(int index) {
    const screens = ['dashboard', 'my_turfs', 'bookings', 'payments', 'more'];
    _navigate(screens[index], root: true);
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
      case 'more':
        return _MoreScreen(onNavigate: _navigate, onLogout: widget.onLogout);
      default:
        return DashboardScreen(onNavigate: _navigate);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            bottom: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            if (_canGoBack) ...[
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back, size: 16),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: const Turf11PartnerLogo(markSize: 30, textSize: 16),
            ),
            GestureDetector(
              onTap: () => _navigate('notifications'),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 15,
                        color: AppColors.muted,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _navigate('profile'),
              child: const AppAvatar(
                initials: 'VS',
                size: 32,
                bg: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const iconSize = 18.0;

    return NavigationBar(
      selectedIndex: _bottomIndexFor(_currentScreen),
      onDestinationSelected: _onBottomTap,
      height: 66,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.greenLt,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 10,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AppColors.green
              : AppColors.muted,
        ),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined, size: iconSize),
          selectedIcon: Icon(Icons.grid_view_rounded, size: iconSize),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_cricket_outlined, size: iconSize),
          selectedIcon: Icon(Icons.sports_cricket, size: iconSize),
          label: 'Turfs',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined, size: iconSize),
          selectedIcon: Icon(Icons.receipt_long, size: iconSize),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined, size: iconSize),
          selectedIcon: Icon(Icons.account_balance_wallet, size: iconSize),
          label: 'Payments',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz, size: iconSize),
          selectedIcon: Icon(Icons.more, size: iconSize),
          label: 'More',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_canGoBack,
      onPopInvoked: (didPop) {
        if (!didPop && _canGoBack) {
          _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildBottomNavigation(),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _buildScreen(),
        ),
      ),
    );
  }
}

class _MoreScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const _MoreScreen({required this.onNavigate, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 78),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const AppAvatar(initials: 'VS', size: 46, bg: AppColors.dark),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Vikram Singh',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text('Turf Owner - Gurugram',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
            ),
            IconButton(
              onPressed: () => onNavigate('profile'),
              icon: const Icon(Icons.chevron_right),
            ),
          ]),
        ),
        _group('Tournaments', [
          _MoreItem('Tournaments', Icons.emoji_events_outlined, 'tournaments'),
          _MoreItem('Add Tournament', Icons.add_circle_outline, 'add_tournament'),
          _MoreItem('Registrations', Icons.group_add_outlined,
              'tourney_registrations'),
          _MoreItem('Tournament Reviews', Icons.rate_review_outlined,
              'tourney_reviews'),
        ]),
        _group('Finance & Account', [
          _MoreItem('Cancellations', Icons.cancel_outlined, 'cancellations'),
          _MoreItem('Verification', Icons.verified_user_outlined, 'verify'),
          _MoreItem('Terms & Policies', Icons.description_outlined, 'terms'),
        ]),
        AppCard(
          padding: const EdgeInsets.all(8),
          child: _tile(
            label: 'Logout',
            icon: Icons.logout,
            color: AppColors.red,
            onTap: onLogout,
          ),
        ),
      ]),
    );
  }

  Widget _group(String title, List<_MoreItem> items) {
    return AppCard(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted)),
        ),
        const SizedBox(height: 6),
        ...items.map((item) => _tile(
              label: item.label,
              icon: item.icon,
              onTap: () => onNavigate(item.screen),
            )),
      ]),
    );
  }

  Widget _tile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.dark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
            Icon(Icons.chevron_right, size: 16, color: color.withOpacity(0.5)),
          ]),
        ),
      ),
    );
  }
}

class _MoreItem {
  final String label;
  final IconData icon;
  final String screen;

  const _MoreItem(this.label, this.icon, this.screen);
}




