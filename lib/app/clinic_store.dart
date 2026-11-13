import 'package:flutter/material.dart';

import 'clinic_demo_data.dart';
import 'clinic_models.dart';

class ClinicStore extends ChangeNotifier {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static final _phonePattern = RegExp(r'^\+?[0-9]{8,15}$');

  static bool isValidEmail(String value) =>
      _emailPattern.hasMatch(value.trim());

  static bool isValidPhone(String value) {
    final compact = value.replaceAll(RegExp(r'[\s()-]'), '');
    return compact.isEmpty || _phonePattern.hasMatch(compact);
  }

  ClinicStore({bool seedDemoData = true}) {
    if (!seedDemoData) {
      return;
    }
    final fixtures = ClinicDemoData.create();
    users.addAll(fixtures.users);
    appointments.addAll(fixtures.appointments);
    notices.addAll(fixtures.notices);
  }

  static const availableTimes = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
  ];

  final List<ClinicUser> users = [];
  final List<ClinicAppointment> appointments = [];
  final List<ClinicNotice> notices = [];
  int _idSequence = 0;
  ClinicUser? currentUser;

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}';

  bool _canViewPatient(String patientId) {
    final user = currentUser;
    return user != null &&
        (user.role == AccountRole.admin || user.id == patientId);
  }

  static const doctors = [
    ClinicDoctor(
      id: 'doctor-1',
      name: 'dr. Andi Pratama',
      specialty: 'Dokter Umum',
      experience: 12,
      room: 'Ruang 02',
      color: Color(0xFF496783),
    ),
    ClinicDoctor(
      id: 'doctor-2',
      name: 'dr. Sarah Lestari, Sp.A',
      specialty: 'Dokter Anak',
      experience: 9,
      room: 'Ruang 04',
      color: Color(0xFF397264),
    ),
    ClinicDoctor(
      id: 'doctor-3',
      name: 'drg. Budi Santoso',
      specialty: 'Dokter Gigi',
      experience: 8,
      room: 'Ruang 06',
      color: Color(0xFF6E5C8B),
    ),
    ClinicDoctor(
      id: 'doctor-4',
      name: 'dr. Citra Maharani, Sp.PD',
      specialty: 'Penyakit Dalam',
      experience: 14,
      room: 'Ruang 08',
      color: Color(0xFF896038),
    ),
  ];

  bool login(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in users) {
      if (user.email.toLowerCase() == normalizedEmail &&
          user.password == password) {
        currentUser = user;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  String? register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedName.length < 3) {
      return 'Nama minimal 3 karakter.';
    }
    if (!isValidEmail(normalizedEmail)) {
      return 'Masukkan alamat email yang valid.';
    }
    if (password.trim().length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }
    if (!isValidPhone(phone)) {
      return 'Masukkan nomor telepon yang valid.';
    }
    if (users.any((user) => user.email.toLowerCase() == normalizedEmail)) {
      return 'Email sudah terdaftar. Silakan masuk ke akun Anda.';
    }

    final patient = ClinicUser(
      id: _newId('patient'),
      name: normalizedName,
      email: normalizedEmail,
      password: password,
      phone: phone.trim(),
      role: AccountRole.patient,
    );
    users.add(patient);
    currentUser = patient;
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  List<ClinicAppointment> appointmentsFor(String patientId) {
    if (!_canViewPatient(patientId)) {
      return [];
    }
    final items = appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
    items.sort((first, second) {
      final dateCompare = second.date.compareTo(first.date);
      return dateCompare == 0 ? second.time.compareTo(first.time) : dateCompare;
    });
    return items;
  }

  ClinicAppointment? nextAppointmentFor(String patientId) {
    if (!_canViewPatient(patientId)) {
      return null;
    }
    final now = DateTime.now();
    final upcoming =
        appointments
            .where(
              (appointment) =>
                  appointment.patientId == patientId &&
                  appointment.status == VisitStatus.scheduled &&
                  _isUpcoming(appointment, now),
            )
            .toList()
          ..sort((first, second) {
            final dateCompare = first.date.compareTo(second.date);
            return dateCompare == 0
                ? first.time.compareTo(second.time)
                : dateCompare;
          });
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<ClinicNotice> noticesFor(String patientId) {
    if (!_canViewPatient(patientId)) {
      return [];
    }
    final items =
        notices.where((notice) => notice.patientId == patientId).toList()..sort(
          (first, second) => second.createdAt.compareTo(first.createdAt),
        );
    return items;
  }

  List<String> bookedTimes(String doctorId, DateTime date) {
    return appointments
        .where(
          (appointment) =>
              appointment.doctorId == doctorId &&
              appointment.status == VisitStatus.scheduled &&
              appointment.date.year == date.year &&
              appointment.date.month == date.month &&
              appointment.date.day == date.day,
        )
        .map((appointment) => appointment.time)
        .toList();
  }

  bool _isUpcoming(ClinicAppointment appointment, DateTime now) {
    final appointmentDate = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    if (appointmentDate.isAfter(today)) {
      return true;
    }
    if (appointmentDate.isBefore(today)) {
      return false;
    }
    final timeParts = appointment.time.split(':');
    if (timeParts.length != 2) {
      return false;
    }
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) {
      return false;
    }
    final appointmentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    return !appointmentDateTime.isBefore(now);
  }

  ClinicAppointment? createAppointment({
    required String doctorId,
    required DateTime date,
    required String time,
    required String notes,
  }) {
    final patient = currentUser;
    final today = DateTime.now();
    final selectedDate = DateTime(date.year, date.month, date.day);
    final currentDate = DateTime(today.year, today.month, today.day);
    final lastBookableDate = currentDate.add(const Duration(days: 180));
    if (patient == null ||
        patient.role != AccountRole.patient ||
        doctorById(doctorId) == null ||
        !availableTimes.contains(time) ||
        selectedDate.isBefore(currentDate) ||
        selectedDate.isAfter(lastBookableDate) ||
        !_isFutureSlot(date, time, today) ||
        notes.trim().length > 300 ||
        bookedTimes(doctorId, date).contains(time)) {
      return null;
    }

    final queueNumber =
        appointments
            .where(
              (appointment) =>
                  appointment.doctorId == doctorId &&
                  appointment.date.year == date.year &&
                  appointment.date.month == date.month &&
                  appointment.date.day == date.day,
            )
            .length +
        1;
    final appointment = ClinicAppointment(
      id: _newId('visit'),
      patientId: patient.id,
      doctorId: doctorId,
      date: DateTime(date.year, date.month, date.day),
      time: time,
      queueNumber: queueNumber,
      notes: notes.trim(),
    );
    appointments.add(appointment);
    final doctor = doctorById(doctorId);
    notices.add(
      ClinicNotice(
        id: _newId('notice'),
        patientId: patient.id,
        title: 'Booking pemeriksaan berhasil',
        message: 'Jadwal bersama ${doctor?.name ?? 'dokter'} sudah tersimpan.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return appointment;
  }

  bool _isFutureSlot(DateTime date, String time, DateTime now) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return false;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return false;
    }
    final slot = DateTime(date.year, date.month, date.day, hour, minute);
    return slot.isAfter(now);
  }

  void cancelAppointment(ClinicAppointment appointment) {
    final user = currentUser;
    if (user == null ||
        appointment.status != VisitStatus.scheduled ||
        (user.role != AccountRole.admin && appointment.patientId != user.id)) {
      return;
    }
    appointment.status = VisitStatus.cancelled;
    notices.add(
      ClinicNotice(
        id: _newId('notice'),
        patientId: appointment.patientId,
        title: 'Jadwal pemeriksaan dibatalkan',
        message:
            'Jadwal ${appointment.time} pada ${appointment.date.day}/${appointment.date.month}/${appointment.date.year} telah dibatalkan.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markNoticesRead(String patientId) {
    if (currentUser?.id != patientId) {
      return;
    }
    var changed = false;
    for (final notice in notices.where((item) => item.patientId == patientId)) {
      if (!notice.isRead) {
        notice.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void markNoticeRead(ClinicNotice notice) {
    if (currentUser?.id != notice.patientId || notice.isRead) {
      return;
    }
    notice.isRead = true;
    notifyListeners();
  }

  bool updateProfile({
    required String name,
    required String phone,
    required DateTime? birthDate,
    required String gender,
  }) {
    final user = currentUser;
    final today = DateTime.now();
    if (user == null ||
        name.trim().length < 3 ||
        !isValidPhone(phone) ||
        (birthDate != null &&
            birthDate.isAfter(DateTime(today.year, today.month, today.day))) ||
        (gender.isNotEmpty &&
            !const {'Perempuan', 'Laki-laki', 'Lainnya'}.contains(gender))) {
      return false;
    }
    user
      ..name = name.trim()
      ..phone = phone.trim()
      ..birthDate = birthDate
      ..gender = gender;
    notifyListeners();
    return true;
  }

  void completeAppointment(ClinicAppointment appointment) {
    if (currentUser?.role != AccountRole.admin ||
        appointment.status != VisitStatus.scheduled) {
      return;
    }
    appointment.status = VisitStatus.completed;
    notices.add(
      ClinicNotice(
        id: _newId('notice'),
        patientId: appointment.patientId,
        title: 'Kunjungan telah selesai',
        message:
            'Terima kasih telah berkunjung pada ${appointment.date.day}/${appointment.date.month}/${appointment.date.year}.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  ClinicDoctor? doctorById(String id) {
    for (final doctor in doctors) {
      if (doctor.id == id) {
        return doctor;
      }
    }
    return null;
  }

  ClinicUser? patientById(String id) {
    if (currentUser?.role != AccountRole.admin) {
      return null;
    }
    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }
}
