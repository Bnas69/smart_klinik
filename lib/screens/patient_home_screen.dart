import 'package:flutter/material.dart';

import '../app/clinic_models.dart';
import '../app/clinic_store.dart';
import '../app/clinic_theme.dart';
import '../widgets/clinic_widgets.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({
    super.key,
    required this.store,
    required this.user,
    required this.onNavigate,
    required this.onOpenNotifications,
  });

  final ClinicStore store;
  final ClinicUser user;
  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final appointments = store.appointmentsFor(user.id);
    final nextAppointment = store.nextAppointmentFor(user.id);
    final recentVisits = appointments.take(3).toList();
    final unreadCount = store
        .noticesFor(user.id)
        .where((notice) => !notice.isRead)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(
              name: user.name,
              onNotifications: onOpenNotifications,
              unreadCount: unreadCount,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: SectionHeading(
                    title: 'Layanan klinik',
                    subtitle: 'Apa yang ingin Anda lakukan?',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    clinicDate(DateTime.now()),
                    style: const TextStyle(
                      color: ClinicColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_box_rounded,
                    label: 'Booking',
                    detail: 'Pilih dokter',
                    tint: ClinicColors.blue,
                    onTap: () => onNavigate(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.history_rounded,
                    label: 'Riwayat',
                    detail:
                        '${appointments.length} kunjungan',
                    tint: ClinicColors.green,
                    onTap: () => onNavigate(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    detail: 'Data diri',
                    tint: const Color(0xFF8A6BE8),
                    onTap: () => onNavigate(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeading(
              title: 'Jadwal berikutnya',
              subtitle: 'Siapkan kunjungan Anda',
              action: 'Lihat semua',
              onAction: () => onNavigate(2),
            ),
            const SizedBox(height: 12),
            if (nextAppointment != null)
              _NextAppointmentCard(appointment: nextAppointment, store: store)
            else
              _NoAppointmentCard(onBook: () => onNavigate(1)),
            const SizedBox(height: 24),
            SectionHeading(
              title: 'Riwayat terbaru',
              subtitle: 'Catatan kunjungan Anda',
              action: 'Semua',
              onAction: () => onNavigate(2),
            ),
            const SizedBox(height: 12),
            if (recentVisits.isEmpty)
              const ClinicCard(child: _NoHistoryMessage())
            else
              ClinicCard(
                padding: 7,
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < recentVisits.length;
                      index++
                    ) ...[
                      _RecentVisitRow(
                        appointment: recentVisits[index],
                        store: store,
                      ),
                      if (index != recentVisits.length - 1)
                        const Divider(
                          height: 1,
                          indent: 70,
                          color: ClinicColors.line,
                        ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 18),
            const _PrivacyNotice(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.name,
    required this.onNotifications,
    required this.unreadCount,
  });

  final String name;
  final VoidCallback onNotifications;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF125B55), Color(0xFF1C7168), Color(0xFF3A9585)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ClinicColors.blue.withValues(alpha: .24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -55,
            child: _DecorCircle(size: 190, opacity: .12),
          ),
          Positioned(
            right: 53,
            bottom: -106,
            child: _DecorCircle(size: 185, opacity: .1),
          ),
          Positioned(
            right: 28,
            bottom: 20,
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white24,
              size: 92,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 15, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFD56A),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'LAYANAN KESEHATAN ANDA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onNotifications,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: .16),
                        foregroundColor: Colors.white,
                      ),
                      icon: Badge(
                        isLabelVisible: unreadCount > 0,
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Halo, ${name.split(' ').first}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 23,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Semoga hari Anda menyenangkan.\nYuk, tetap sehat bersama kami.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .86),
                    fontSize: 12,
                    height: 1.45,
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

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 24,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.detail,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: tint, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ClinicColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: ClinicColors.muted, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment, required this.store});

  final ClinicAppointment appointment;
  final ClinicStore store;

  @override
  Widget build(BuildContext context) {
    final doctor = store.doctorById(appointment.doctorId);
    return ClinicCard(
      padding: 15,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _weekday(appointment.date.weekday),
                      style: const TextStyle(
                        color: ClinicColors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${appointment.date.day}',
                      style: const TextStyle(
                        color: ClinicColors.navy,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      _month(appointment.date.month),
                      style: const TextStyle(
                        color: ClinicColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor?.name ?? 'Dokter SmartClinic',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ClinicColors.navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor?.specialty ?? 'Pemeriksaan',
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
              const SizedBox(width: 8),
              Column(
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    color: ClinicColors.cyan,
                    size: 20,
                  ),
                  Text(
                    'A-${appointment.queueNumber.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: ClinicColors.blue,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  const Text(
                    'antrean',
                    style: TextStyle(color: ClinicColors.muted, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const VisitStatusChip(status: VisitStatus.scheduled),
              _TinyMeta(
                icon: Icons.access_time_rounded,
                label: '${appointment.time} WIB',
              ),
              _TinyMeta(
                icon: Icons.room_outlined,
                label: doctor?.room ?? 'Klinik',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoAppointmentCard extends StatelessWidget {
  const _NoAppointmentCard({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return ClinicCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ClinicColors.blue.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: ClinicColors.blue,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada jadwal periksa',
                  style: TextStyle(
                    color: ClinicColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pilih dokter untuk mulai booking.',
                  style: TextStyle(color: ClinicColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onBook,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _RecentVisitRow extends StatelessWidget {
  const _RecentVisitRow({required this.appointment, required this.store});

  final ClinicAppointment appointment;
  final ClinicStore store;

  @override
  Widget build(BuildContext context) {
    final doctor = store.doctorById(appointment.doctorId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          PatientAvatar(
            name: doctor?.name ?? 'D',
            size: 42,
            color: doctor?.color,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor?.name ?? 'Dokter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ClinicColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${clinicDate(appointment.date)} · ${appointment.time}',
                  style: const TextStyle(
                    color: ClinicColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          VisitStatusChip(status: appointment.status),
        ],
      ),
    );
  }
}

class _NoHistoryMessage extends StatelessWidget {
  const _NoHistoryMessage();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.folder_open_rounded, color: ClinicColors.muted),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Riwayat kunjungan akan muncul setelah Anda booking dokter.',
            style: TextStyle(color: ClinicColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined, color: ClinicColors.green, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Informasi yang Anda masukkan pada demo ini digunakan untuk simulasi pelayanan klinik.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontSize: 11, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _TinyMeta extends StatelessWidget {
  const _TinyMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: ClinicColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: ClinicColors.muted, fontSize: 10),
        ),
      ],
    );
  }
}

String _weekday(int day) =>
    const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][day - 1];
String _month(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
][month - 1];
