import 'package:flutter/material.dart';

import '../../app/clinic_models.dart';
import '../../app/clinic_store.dart';
import '../../app/clinic_theme.dart';
import '../../widgets/clinic_widgets.dart';

class AdminPatientScreen extends StatefulWidget {
  const AdminPatientScreen({super.key, required this.store});

  final ClinicStore store;

  @override
  State<AdminPatientScreen> createState() => _AdminPatientScreenState();
}

class _AdminPatientScreenState extends State<AdminPatientScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final query = _search.toLowerCase();
    final patients = widget.store.users.where((user) {
      if (user.role != AccountRole.patient) {
        return false;
      }
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phone.toLowerCase().contains(query);
    }).toList();
    final visitCounts = <String, int>{};
    for (final appointment in widget.store.appointments) {
      visitCounts.update(
        appointment.patientId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
      itemCount: patients.isEmpty ? 1 : patients.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeading(
                title: 'Data pasien',
                subtitle: 'Kelola informasi pasien terdaftar.',
              ),
              const SizedBox(height: 15),
              TextField(
                onChanged: (value) => setState(() => _search = value.trim()),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Cari nama atau email pasien',
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Text(
                    '${patients.length} pasien',
                    style: const TextStyle(
                      color: ClinicColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: ClinicColors.green,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Data privat',
                    style: TextStyle(
                      color: ClinicColors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              if (patients.isEmpty)
                const ClinicCard(
                  child: Text(
                    'Pasien tidak ditemukan.',
                    style: TextStyle(color: ClinicColors.muted),
                  ),
                ),
            ],
          );
        }

        final patient = patients[index - 1];
        final visits = visitCounts[patient.id] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClinicCard(
            padding: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PatientAvatar(name: patient.name, size: 43),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              color: ClinicColors.navy,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            patient.email,
                            style: const TextStyle(
                              color: ClinicColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$visits kunjungan',
                        style: const TextStyle(
                          color: ClinicColors.blue,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: ClinicColors.line),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: ClinicColors.muted,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        patient.phone.isEmpty
                            ? 'Nomor telepon belum diisi'
                            : patient.phone,
                        style: const TextStyle(
                          color: ClinicColors.text,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.verified_user_outlined,
                      color: ClinicColors.green,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Terdaftar',
                      style: TextStyle(
                        color: ClinicColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
