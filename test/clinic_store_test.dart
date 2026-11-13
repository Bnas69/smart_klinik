import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic/app/clinic_models.dart';
import 'package:smart_clinic/app/clinic_store.dart';

void main() {
  late ClinicStore store;

  setUp(() => store = ClinicStore());
  tearDown(() => store.dispose());

  test('demo fixtures can be disabled for a clean store', () {
    final cleanStore = ClinicStore(seedDemoData: false);
    addTearDown(cleanStore.dispose);

    expect(cleanStore.users, isEmpty);
    expect(cleanStore.appointments, isEmpty);
    expect(cleanStore.notices, isEmpty);
  });

  group('authentication and registration', () {
    test('login normalizes email but keeps password exact', () {
      expect(store.login('  PASIEN@SMARTCLINIC.ID ', 'pasien123'), isTrue);
      expect(store.currentUser?.role, AccountRole.patient);

      store.logout();
      expect(store.login('pasien@smartclinic.id', 'wrong-password'), isFalse);
      expect(store.currentUser, isNull);
    });

    test('registration validates fields and rejects duplicate email', () {
      expect(
        store.register(
          name: 'Al',
          email: 'pasien@smartclinic.id',
          password: 'secret123',
          phone: '081234567890',
        ),
        'Nama minimal 3 karakter.',
      );
      expect(
        store.register(
          name: 'Pasien Baru',
          email: 'bukan-email',
          password: 'secret123',
          phone: '',
        ),
        'Masukkan alamat email yang valid.',
      );
      expect(
        store.register(
          name: 'Pasien Baru',
          email: 'baru@example.id',
          password: 'short',
          phone: '',
        ),
        'Kata sandi minimal 8 karakter.',
      );
      expect(
        store.register(
          name: 'Pasien Baru',
          email: 'baru@example.id',
          password: 'secret123',
          phone: 'nomor-salah',
        ),
        'Masukkan nomor telepon yang valid.',
      );
      expect(
        store.register(
          name: 'Pasien Baru',
          email: 'PASIEN@SMARTCLINIC.ID',
          password: 'secret123',
          phone: '',
        ),
        'Email sudah terdaftar. Silakan masuk ke akun Anda.',
      );

      expect(
        store.register(
          name: 'Pasien Baru',
          email: 'baru@example.id',
          password: 'secret123',
          phone: '+62 812-3456-7890',
        ),
        isNull,
      );
      expect(store.currentUser?.name, 'Pasien Baru');
      expect(store.currentUser?.role, AccountRole.patient);
    });
  });

  group('appointments', () {
    test('patient access is scoped to their own records', () {
      store.login('pasien@smartclinic.id', 'pasien123');
      final otherPatientVisit = store.appointments.firstWhere(
        (item) => item.id == 'visit-3',
      );

      expect(store.appointmentsFor('patient-3'), isEmpty);
      expect(store.noticesFor('patient-3'), isEmpty);
      expect(store.patientById('patient-3'), isNull);
      store.cancelAppointment(otherPatientVisit);
      store.completeAppointment(otherPatientVisit);
      expect(otherPatientVisit.status, VisitStatus.scheduled);

      store.login('admin@smartclinic.id', 'admin123');
      expect(store.appointmentsFor('patient-3'), hasLength(1));
      expect(store.patientById('patient-3')?.name, 'Nadia Putri');
      store.cancelAppointment(otherPatientVisit);
      expect(otherPatientVisit.status, VisitStatus.cancelled);
    });

    test('patient can book an available future slot only once', () {
      expect(store.login('pasien@smartclinic.id', 'pasien123'), isTrue);
      final today = DateTime.now();
      final visitDate = DateTime(today.year, today.month, today.day + 5);
      final appointment = store.createAppointment(
        doctorId: 'doctor-1',
        date: visitDate,
        time: '08:00',
        notes: 'Kontrol rutin',
      );

      expect(appointment, isNotNull);
      expect(appointment!.queueNumber, 1);
      expect(appointment.patientId, store.currentUser!.id);
      expect(store.noticesFor(store.currentUser!.id), hasLength(2));
      expect(
        store.createAppointment(
          doctorId: 'doctor-1',
          date: visitDate,
          time: '08:00',
          notes: '',
        ),
        isNull,
      );
      expect(
        store.createAppointment(
          doctorId: 'doctor-1',
          date: DateTime(today.year, today.month, today.day + 181),
          time: '09:00',
          notes: '',
        ),
        isNull,
      );

      store.cancelAppointment(appointment);
      expect(appointment.status, VisitStatus.cancelled);
      expect(
        store.noticesFor(store.currentUser!.id).first.title,
        'Jadwal pemeriksaan dibatalkan',
      );
      final noticeCount = store.notices.length;
      store.cancelAppointment(appointment);
      expect(store.notices, hasLength(noticeCount));
    });

    test('admin and past dates cannot create a patient booking', () {
      final today = DateTime.now();
      expect(store.login('admin@smartclinic.id', 'admin123'), isTrue);
      expect(
        store.createAppointment(
          doctorId: 'doctor-1',
          date: DateTime(today.year, today.month, today.day + 2),
          time: '09:00',
          notes: '',
        ),
        isNull,
      );

      store.logout();
      expect(store.login('pasien@smartclinic.id', 'pasien123'), isTrue);
      expect(
        store.createAppointment(
          doctorId: 'doctor-1',
          date: DateTime(today.year, today.month, today.day - 1),
          time: '09:00',
          notes: '',
        ),
        isNull,
      );
    });

    test('next appointment ignores scheduled visits in the past', () {
      store.login('pasien@smartclinic.id', 'pasien123');
      final now = DateTime.now();
      store.appointments.add(
        ClinicAppointment(
          id: 'past-visit',
          patientId: 'patient-1',
          doctorId: 'doctor-1',
          date: DateTime(now.year, now.month, now.day - 1),
          time: '09:00',
          queueNumber: 1,
        ),
      );

      final next = store.nextAppointmentFor('patient-1');
      expect(next?.id, 'visit-1');
    });

    test('status completion sends a notice and cannot be repeated', () {
      store.login('admin@smartclinic.id', 'admin123');
      final appointment = store.appointments.firstWhere(
        (item) => item.id == 'visit-1',
      );
      store.completeAppointment(appointment);
      expect(appointment.status, VisitStatus.completed);
      expect(
        store.noticesFor('patient-1').first.title,
        'Kunjungan telah selesai',
      );

      final noticeCount = store.notices.length;
      store.completeAppointment(appointment);
      expect(store.notices, hasLength(noticeCount));
    });
  });

  test(
    'profile validation rejects malformed details and accepts valid edits',
    () {
      store.login('pasien@smartclinic.id', 'pasien123');
      expect(
        store.updateProfile(
          name: 'Aini Rahmawati',
          phone: 'not-a-phone',
          birthDate: null,
          gender: '',
        ),
        isFalse,
      );
      expect(
        store.updateProfile(
          name: 'Aini Rahmawati',
          phone: '0812 3456 7890',
          birthDate: DateTime(1997, 6, 12),
          gender: 'Perempuan',
        ),
        isTrue,
      );
      expect(store.currentUser?.phone, '0812 3456 7890');
    },
  );
}
