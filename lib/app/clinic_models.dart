import 'package:flutter/material.dart';

enum AccountRole { patient, admin }

enum VisitStatus { scheduled, cancelled, completed }

class ClinicUser {
  ClinicUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone = '',
    this.birthDate,
    this.gender = '',
  });

  final String id;
  String name;
  final String email;
  final String password;
  final AccountRole role;
  String phone;
  DateTime? birthDate;
  String gender;
}

class ClinicDoctor {
  const ClinicDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.room,
    required this.color,
  });

  final String id;
  final String name;
  final String specialty;
  final int experience;
  final String room;
  final Color color;
}

class ClinicAppointment {
  ClinicAppointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.time,
    required this.queueNumber,
    this.notes = '',
    this.status = VisitStatus.scheduled,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final DateTime date;
  final String time;
  final int queueNumber;
  final String notes;
  VisitStatus status;
}

class ClinicNotice {
  ClinicNotice({
    required this.id,
    required this.patientId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String patientId;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;
}
