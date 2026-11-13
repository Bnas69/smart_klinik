import 'clinic_models.dart';

/// Sample records used by the offline showcase app. Never use for production.
class ClinicDemoData {
  const ClinicDemoData._();

  static ClinicDemoFixtures create() {
    final now = DateTime.now();
    return ClinicDemoFixtures(
      users: [
        ClinicUser(
          id: 'patient-1',
          name: 'Aini Rahmawati',
          email: 'pasien@smartclinic.id',
          password: 'pasien123',
          role: AccountRole.patient,
          phone: '0812 3456 7890',
          birthDate: DateTime(1997, 6, 12),
          gender: 'Perempuan',
        ),
        ClinicUser(
          id: 'patient-2',
          name: 'Bima Saputra',
          email: 'bima@example.id',
          password: 'password',
          role: AccountRole.patient,
          phone: '0813 1122 3344',
        ),
        ClinicUser(
          id: 'patient-3',
          name: 'Nadia Putri',
          email: 'nadia@example.id',
          password: 'password',
          role: AccountRole.patient,
          phone: '0821 7777 9911',
        ),
        ClinicUser(
          id: 'admin-1',
          name: 'Admin SmartClinic',
          email: 'admin@smartclinic.id',
          password: 'admin123',
          role: AccountRole.admin,
        ),
      ],
      appointments: [
        ClinicAppointment(
          id: 'visit-1',
          patientId: 'patient-1',
          doctorId: 'doctor-1',
          date: DateTime(now.year, now.month, now.day + 2),
          time: '09:30',
          queueNumber: 3,
        ),
        ClinicAppointment(
          id: 'visit-2',
          patientId: 'patient-2',
          doctorId: 'doctor-2',
          date: DateTime(now.year, now.month, now.day - 14),
          time: '10:00',
          queueNumber: 2,
          status: VisitStatus.completed,
        ),
        ClinicAppointment(
          id: 'visit-3',
          patientId: 'patient-3',
          doctorId: 'doctor-3',
          date: DateTime(now.year, now.month, now.day + 4),
          time: '13:00',
          queueNumber: 1,
        ),
      ],
      notices: [
        ClinicNotice(
          id: 'notice-1',
          patientId: 'patient-1',
          title: 'Jadwal pemeriksaan tersimpan',
          message: 'Jangan lupa hadir 15 menit sebelum jadwal Anda.',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
    );
  }
}

class ClinicDemoFixtures {
  const ClinicDemoFixtures({
    required this.users,
    required this.appointments,
    required this.notices,
  });

  final List<ClinicUser> users;
  final List<ClinicAppointment> appointments;
  final List<ClinicNotice> notices;
}
