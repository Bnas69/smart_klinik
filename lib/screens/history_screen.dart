import 'package:flutter/material.dart';

import '../app/clinic_models.dart';
import '../app/clinic_store.dart';
import '../app/clinic_theme.dart';
import '../widgets/clinic_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.store, required this.user});

  final ClinicStore store;
  final ClinicUser user;

  @override
  Widget build(BuildContext context) {
    final appointments = store.appointmentsFor(user.id);
    final statusCounts = <VisitStatus, int>{};
    for (final appointment in appointments) {
      statusCounts.update(
        appointment.status,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      itemCount: appointments.isEmpty ? 1 : appointments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(
                title: 'Riwayat kunjungan',
                subtitle: 'Semua jadwal pemeriksaan Anda tersimpan di sini.',
              ),
              const SizedBox(height: 17),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryTag(
                    label: 'Semua',
                    count: appointments.length,
                    tint: ClinicColors.blue,
                  ),
                  _SummaryTag(
                    label: 'Terjadwal',
                    count: statusCounts[VisitStatus.scheduled] ?? 0,
                    tint: ClinicColors.green,
                  ),
                  _SummaryTag(
                    label: 'Selesai',
                    count: statusCounts[VisitStatus.completed] ?? 0,
                    tint: ClinicColors.blue,
                  ),
                  _SummaryTag(
                    label: 'Dibatalkan',
                    count: statusCounts[VisitStatus.cancelled] ?? 0,
                    tint: ClinicColors.red,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (appointments.isEmpty)
                const ClinicCard(
                  padding: 26,
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note_rounded,
                        size: 43,
                        color: ClinicColors.muted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada kunjungan',
                        style: TextStyle(
                          color: ClinicColors.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Booking dokter untuk mencatat jadwal pemeriksaan pertama Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ClinicColors.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }

        final appointment = appointments[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: _AppointmentHistoryCard(
            appointment: appointment,
            doctor: store.doctorById(appointment.doctorId),
            onCancel: () => _confirmCancel(context, appointment),
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    ClinicAppointment appointment,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan jadwal?'),
        content: const Text(
          'Jadwal ini akan berubah menjadi dibatalkan. Anda dapat membuat booking baru kapan saja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (shouldCancel == true) {
      store.cancelAppointment(appointment);
    }
  }
}

class _SummaryTag extends StatelessWidget {
  const _SummaryTag({
    required this.label,
    required this.count,
    required this.tint,
  });

  final String label;
  final int count;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ClinicColors.line),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ClinicColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: tint,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentHistoryCard extends StatelessWidget {
  const _AppointmentHistoryCard({
    required this.appointment,
    required this.doctor,
    required this.onCancel,
  });

  final ClinicAppointment appointment;
  final ClinicDoctor? doctor;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ClinicCard(
      padding: 14,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${appointment.date.day}',
                      style: const TextStyle(
                        color: ClinicColors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _month(appointment.date.month),
                      style: const TextStyle(
                        color: ClinicColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              PatientAvatar(
                name: doctor?.name ?? 'D',
                size: 44,
                color: doctor?.color,
              ),
              const SizedBox(width: 10),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor?.specialty ?? 'Pemeriksaan',
                      style: const TextStyle(
                        color: ClinicColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${clinicDate(appointment.date, withWeekday: true)} · ${appointment.time} WIB',
                      style: const TextStyle(
                        color: ClinicColors.text,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(height: 1, color: ClinicColors.line),
          const SizedBox(height: 11),
          Row(
            children: [
              VisitStatusChip(status: appointment.status),
              const Spacer(),
              Text(
                'Antrean A-${appointment.queueNumber.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: ClinicColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (appointment.status == VisitStatus.scheduled) ...[
                const SizedBox(width: 9),
                Container(width: 1, height: 17, color: ClinicColors.line),
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: ClinicColors.red,
                    padding: const EdgeInsets.only(left: 9),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Batalkan',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F4),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                'Catatan: ${appointment.notes}',
                style: const TextStyle(color: ClinicColors.muted, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
