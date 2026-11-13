import 'package:flutter/material.dart';

import '../../app/clinic_models.dart';
import '../../app/clinic_store.dart';
import '../../app/clinic_theme.dart';
import '../../widgets/clinic_widgets.dart';

class AdminAppointmentScreen extends StatefulWidget {
  const AdminAppointmentScreen({super.key, required this.store});

  final ClinicStore store;

  @override
  State<AdminAppointmentScreen> createState() => _AdminAppointmentScreenState();
}

class _AdminAppointmentScreenState extends State<AdminAppointmentScreen> {
  VisitStatus? _statusFilter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final allAppointments = widget.store.appointments.toList()
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        return dateCompare == 0 ? b.time.compareTo(a.time) : dateCompare;
      });
    final statusCounts = <VisitStatus, int>{};
    for (final appointment in allAppointments) {
      statusCounts.update(
        appointment.status,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final patientsById = {
      for (final user in widget.store.users)
        if (user.role == AccountRole.patient) user.id: user,
    };
    final doctorsById = {
      for (final doctor in ClinicStore.doctors) doctor.id: doctor,
    };
    final query = _search.toLowerCase();
    final appointments = allAppointments.where((appointment) {
      if (_statusFilter != null && appointment.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final patient = patientsById[appointment.patientId];
      final doctor = doctorsById[appointment.doctorId];
      return (patient?.name.toLowerCase().contains(query) ?? false) ||
          (patient?.email.toLowerCase().contains(query) ?? false) ||
          (patient?.phone.toLowerCase().contains(query) ?? false) ||
          (doctor?.name.toLowerCase().contains(query) ?? false) ||
          (doctor?.specialty.toLowerCase().contains(query) ?? false);
    }).toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
      itemCount: appointments.isEmpty ? 1 : appointments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(
                title: 'Jadwal kunjungan',
                subtitle: 'Booking seluruh pasien SmartClinic.',
              ),
              const SizedBox(height: 15),
              TextField(
                onChanged: (value) => setState(() => _search = value.trim()),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Cari pasien atau dokter',
                ),
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _statusChip(
                    label: 'Semua',
                    count: allAppointments.length,
                    status: null,
                  ),
                  _statusChip(
                    label: 'Terjadwal',
                    count: statusCounts[VisitStatus.scheduled] ?? 0,
                    status: VisitStatus.scheduled,
                  ),
                  _statusChip(
                    label: 'Selesai',
                    count: statusCounts[VisitStatus.completed] ?? 0,
                    status: VisitStatus.completed,
                  ),
                  _statusChip(
                    label: 'Dibatalkan',
                    count: statusCounts[VisitStatus.cancelled] ?? 0,
                    status: VisitStatus.cancelled,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (appointments.isEmpty)
                const ClinicCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        color: ClinicColors.muted,
                        size: 34,
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Jadwal tidak ditemukan',
                        style: TextStyle(
                          color: ClinicColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Coba ubah pencarian atau filter status.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ClinicColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }
        return _appointmentCard(
          appointments[index - 1],
          patientsById,
          doctorsById,
        );
      },
    );
  }

  Widget _appointmentCard(
    ClinicAppointment appointment,
    Map<String, ClinicUser> patientsById,
    Map<String, ClinicDoctor> doctorsById,
  ) {
    final patient = patientsById[appointment.patientId];
    final doctor = doctorsById[appointment.doctorId];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClinicCard(
        padding: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PatientAvatar(name: patient?.name ?? '?', size: 41),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient?.name ?? 'Pasien',
                        style: const TextStyle(
                          color: ClinicColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doctor?.name ?? 'Dokter',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: ClinicColors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      clinicDate(appointment.date, withWeekday: true),
                      style: const TextStyle(
                        color: ClinicColors.text,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.access_time_rounded,
                    color: ClinicColors.blue,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${appointment.time} WIB',
                    style: const TextStyle(
                      color: ClinicColors.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 9),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F4),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Keluhan: ${appointment.notes}',
                  style: const TextStyle(
                    color: ClinicColors.muted,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            if (appointment.status == VisitStatus.scheduled) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmComplete(context, appointment),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 17,
                      ),
                      label: const Text('Selesai'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ClinicColors.green,
                        side: BorderSide(
                          color: ClinicColors.green.withValues(alpha: .3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmCancel(context, appointment),
                      icon: const Icon(Icons.close_rounded, size: 17),
                      label: const Text('Batalkan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ClinicColors.red,
                        side: BorderSide(
                          color: ClinicColors.red.withValues(alpha: .3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required int count,
    required VisitStatus? status,
  }) {
    return ChoiceChip(
      selected: _statusFilter == status,
      label: Text('$label  $count'),
      onSelected: (_) => setState(() => _statusFilter = status),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: _statusFilter == status ? ClinicColors.blue : ClinicColors.text,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFEAF4F0),
      side: BorderSide(
        color: _statusFilter == status ? ClinicColors.blue : ClinicColors.line,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    ClinicAppointment appointment,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan jadwal pasien?'),
        content: const Text(
          'Pasien akan menerima pemberitahuan bahwa jadwalnya dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: ClinicColors.red),
            child: const Text('Batalkan jadwal'),
          ),
        ],
      ),
    );
    if (shouldCancel == true) {
      widget.store.cancelAppointment(appointment);
    }
  }

  Future<void> _confirmComplete(
    BuildContext context,
    ClinicAppointment appointment,
  ) async {
    final shouldComplete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan kunjungan?'),
        content: const Text(
          'Status kunjungan akan diperbarui dan pasien akan menerima notifikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tandai selesai'),
          ),
        ],
      ),
    );
    if (shouldComplete == true) {
      widget.store.completeAppointment(appointment);
    }
  }
}
