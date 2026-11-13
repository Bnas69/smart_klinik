import 'package:flutter/material.dart';

import '../app/clinic_models.dart';
import '../app/clinic_store.dart';
import '../app/clinic_theme.dart';
import '../widgets/clinic_widgets.dart';
import 'admin_screens.dart';
import 'booking_screen.dart';
import 'history_screen.dart';
import 'patient_home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.store, required this.user});

  final ClinicStore store;
  final ClinicUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  bool get _isAdmin => widget.user.role == AccountRole.admin;

  List<String> get _titles => _isAdmin
      ? const ['Dashboard admin', 'Data pasien', 'Kunjungan']
      : const ['Beranda', 'Booking dokter', 'Riwayat kunjungan', 'Profil saya'];

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NotificationPage(store: widget.store, user: widget.user),
      ),
    );
  }

  void _onAccountAction(String action) {
    switch (action) {
      case 'profile':
        setState(() => _selectedIndex = 3);
        return;
      case 'logout':
        _confirmLogout();
        return;
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: ClinicColors.red),
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda akan kembali ke halaman masuk SmartClinic.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: ClinicColors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      widget.store.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useNavigationRail = screenWidth >= 760;
    final extendNavigationRail = screenWidth >= 1120;
    final pages = _isAdmin
        ? [
            AdminOverviewScreen(store: widget.store),
            AdminPatientScreen(store: widget.store),
            AdminAppointmentScreen(store: widget.store),
          ]
        : [
            PatientHomeScreen(
              store: widget.store,
              user: widget.user,
              onNavigate: (index) => setState(() => _selectedIndex = index),
              onOpenNotifications: _openNotifications,
            ),
            BookingScreen(
              store: widget.store,
              onBooked: () => setState(() => _selectedIndex = 2),
            ),
            HistoryScreen(store: widget.store, user: widget.user),
            ProfileScreen(store: widget.store, user: widget.user),
          ];

    final destinations = _isAdmin
        ? const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Pasien',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Kunjungan',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              label: 'Booking',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SMARTCLINIC',
              style: TextStyle(
                color: ClinicColors.blue,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                color: ClinicColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isAdmin)
            AnimatedBuilder(
              animation: widget.store,
              builder: (context, _) {
                final unread = widget.store
                    .noticesFor(widget.user.id)
                    .where((notice) => !notice.isRead)
                    .length;
                return IconButton(
                  onPressed: _openNotifications,
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread'),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: ClinicColors.navy,
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 14),
            child: PopupMenuButton<String>(
              tooltip: 'Menu akun',
              onSelected: _onAccountAction,
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: SizedBox(
                    width: 190,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ClinicColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ClinicColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!_isAdmin)
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_outline_rounded),
                      title: Text('Profil saya'),
                      dense: true,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.logout_rounded,
                      color: ClinicColors.red,
                    ),
                    title: Text(
                      'Keluar dari akun',
                      style: TextStyle(color: ClinicColors.red),
                    ),
                    dense: true,
                  ),
                ),
              ],
              child: PatientAvatar(name: widget.user.name, size: 37),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: useNavigationRail
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _selectedIndex = index),
                    extended: extendNavigationRail,
                    labelType: extendNavigationRail
                        ? null
                        : NavigationRailLabelType.all,
                    minExtendedWidth: 220,
                    backgroundColor: Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                      child: extendNavigationRail
                          ? const BrandLogo(centered: true)
                          : const Icon(
                              Icons.health_and_safety_rounded,
                              color: ClinicColors.blue,
                              size: 28,
                            ),
                    ),
                    destinations: destinations
                        .map(
                          (destination) => NavigationRailDestination(
                            icon: destination.icon,
                            selectedIcon: destination.selectedIcon,
                            label: Text(destination.label),
                          ),
                        )
                        .toList(),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: ClinicColors.line,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: pages,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: useNavigationRail
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: destinations,
            ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key, required this.store, required this.user});

  final ClinicStore store;
  final ClinicUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClinicColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final hasUnread = store
                  .noticesFor(user.id)
                  .any((notice) => !notice.isRead);
              return TextButton(
                onPressed: hasUnread
                    ? () => store.markNoticesRead(user.id)
                    : null,
                child: const Text('Tandai dibaca'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final notices = store.noticesFor(user.id);
          if (notices.isEmpty) {
            return const _NoticeEmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: notices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => store.markNoticeRead(notice),
                  borderRadius: BorderRadius.circular(22),
                  child: ClinicCard(
                    padding: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF4F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.event_available_rounded,
                            color: ClinicColors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notice.title,
                                style: const TextStyle(
                                  color: ClinicColors.navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                notice.message,
                                style: const TextStyle(
                                  color: ClinicColors.muted,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                timeAgo(notice.createdAt),
                                style: const TextStyle(
                                  color: ClinicColors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notice.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ClinicColors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NoticeEmptyState extends StatelessWidget {
  const _NoticeEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: ClinicColors.muted,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                color: ClinicColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Info jadwal pemeriksaan akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ClinicColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
