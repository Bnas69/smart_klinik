import 'package:flutter/material.dart';

import '../../app/clinic_models.dart';
import '../../app/clinic_store.dart';
import '../../app/clinic_theme.dart';
import '../../widgets/clinic_widgets.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key, required this.store});

  final ClinicStore store;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final patients = store.users
        .where((user) => user.role == AccountRole.patient)
        .length;
    final todayVisits = store.appointments.where((appointment) {
      return appointment.status == VisitStatus.scheduled &&
          appointment.date.year == now.year &&
          appointment.date.month == now.month &&
          appointment.date.day == now.day;
    }).length;
    final activeVisits = store.appointments
        .where((appointment) => appointment.status == VisitStatus.scheduled)
        .length;
    final recentAppointments = store.appointments.toList()
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        return dateCompare == 0 ? b.time.compareTo(a.time) : dateCompare;
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [ClinicColors.navy, ClinicColors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white24,
                  size: 75,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PANEL ADMINISTRATOR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ringkasan klinik',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    clinicDate(DateTime.now(), withWeekday: true),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 19),
        const SectionHeading(
          title: 'Statistik klinik',
          subtitle: 'Aktivitas terbaru SmartClinic.',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final cardWidth = (constraints.maxWidth - 10) / 2;
            final cardAspectRatio =
                wide ? 1.08 : (cardWidth < 150 ? 0.85 : 1.2);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: wide ? 4 : 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: cardAspectRatio,
              children: [
                _StatCard(
                  label: 'Total pasien',
                  value: '$patients',
                  helper: 'Pasien terdaftar',
                  icon: Icons.people_alt_rounded,
                  tint: ClinicColors.blue,
                ),
                _StatCard(
                  label: 'Jadwal hari ini',
                  value: '$todayVisits',
                  helper: 'Pemeriksaan hari ini',
                  icon: Icons.today_rounded,
                  tint: ClinicColors.green,
                ),
                _StatCard(
                  label: 'Jadwal aktif',
                  value: '$activeVisits',
                  helper: 'Menunggu pemeriksaan',
                  icon: Icons.calendar_month_rounded,
                  tint: const Color(0xFF8A6BE8),
                ),
                _StatCard(
                  label: 'Dokter aktif',
                  value: '${ClinicStore.doctors.length}',
                  helper: 'Siap melayani',
                  icon: Icons.medical_services_rounded,
                  tint: const Color(0xFFF09A45),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        SectionHeading(
          title: 'Kunjungan terbaru',
          subtitle: '${store.appointments.length} data booking tercatat.',
        ),
        const SizedBox(height: 12),
        ClinicCard(
          padding: 7,
          child: recentAppointments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Belum ada kunjungan.',
                    style: TextStyle(color: ClinicColors.muted),
                  ),
                )
              : Column(
                  children: recentAppointments.take(4).map((appointment) {
                    final patient = store.patientById(appointment.patientId);
                    final doctor = store.doctorById(appointment.doctorId);
                    return _AdminVisitRow(
                      appointment: appointment,
                      patient: patient,
                      doctor: doctor,
                      showDate: true,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),
        const _AdminPrivacy(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: ClinicColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
              width: 28,
              height: 28,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: tint, size: 17),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: tint.withValues(alpha: .65),
              size: 15,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: ClinicColors.navy,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              color: ClinicColors.text,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ClinicColors.muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _AdminVisitRow extends StatelessWidget {
  const _AdminVisitRow({
    required this.appointment,
    required this.patient,
    required this.doctor,
    required this.showDate,
  });

  final ClinicAppointment appointment;
  final ClinicUser? patient;
  final ClinicDoctor? doctor;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
      child: Row(
        children: [
          PatientAvatar(name: patient?.name ?? '?', size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient?.name ?? 'Pasien',
                  style: const TextStyle(
                    color: ClinicColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  doctor?.name ?? 'Dokter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ClinicColors.muted,
                    fontSize: 9,
                  ),
                ),
                if (showDate)
                  Text(
                    '${clinicDate(appointment.date)} · ${appointment.time} WIB',
                    style: const TextStyle(
                      color: ClinicColors.muted,
                      fontSize: 9,
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

class _AdminPrivacy extends StatelessWidget {
  const _AdminPrivacy();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.shield_outlined, color: ClinicColors.green, size: 16),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'Data pasien hanya untuk kebutuhan pelayanan klinik.',
            style: TextStyle(color: ClinicColors.muted, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
