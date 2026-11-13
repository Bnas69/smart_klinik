import 'package:flutter/material.dart';

import '../app/clinic_models.dart';
import '../app/clinic_store.dart';
import '../app/clinic_theme.dart';
import '../widgets/clinic_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.store, required this.onBooked});

  final ClinicStore store;
  final VoidCallback onBooked;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  ClinicDoctor? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDoctor = ClinicStore.doctors.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate.isBefore(DateTime(now.year, now.month, now.day))
          ? DateTime(now.year, now.month, now.day)
          : _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
      helpText: 'Pilih tanggal pemeriksaan',
    );
    if (date == null) {
      return;
    }
    setState(() {
      _selectedDate = date;
      if (_selectedTime != null && _isBooked(_selectedTime!)) {
        _selectedTime = null;
      }
    });
  }

  bool _isBooked(String time) {
    final doctor = _selectedDoctor;
    return doctor != null &&
        widget.store.bookedTimes(doctor.id, _selectedDate).contains(time);
  }

  bool _isPastTime(String time) {
    final now = DateTime.now();
    if (_selectedDate.year != now.year ||
        _selectedDate.month != now.month ||
        _selectedDate.day != now.day) {
      return false;
    }
    final parts = time.split(':');
    if (parts.length != 2) {
      return true;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return true;
    }
    return !DateTime(now.year, now.month, now.day, hour, minute).isAfter(now);
  }

  void _confirmBooking() {
    final doctor = _selectedDoctor;
    if (doctor == null || _selectedTime == null) {
      _showMessage('Pilih dokter, tanggal, dan jam pemeriksaan.');
      return;
    }
    if (_isPastTime(_selectedTime!)) {
      setState(() => _selectedTime = null);
      _showMessage('Jam yang dipilih sudah lewat. Silakan pilih jam lain.');
      return;
    }
    final result = widget.store.createAppointment(
      doctorId: doctor.id,
      date: _selectedDate,
      time: _selectedTime!,
      notes: _notesController.text,
    );
    if (result == null) {
      _showMessage('Jam tersebut baru saja dipesan. Silakan pilih jam lain.');
      return;
    }
    _showMessage(
      'Booking berhasil. Nomor antrean Anda A-${result.queueNumber.toString().padLeft(2, '0')}.',
    );
    widget.onBooked();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
      children: [
        const SectionHeading(
          title: 'Atur jadwal periksa',
          subtitle: 'Pilih dokter dan waktu yang sesuai.',
        ),
        const SizedBox(height: 20),
        const _BookingStep(
          number: '1',
          title: 'Pilih dokter',
          subtitle: 'Dokter siap melayani Anda',
        ),
        const SizedBox(height: 12),
        ...ClinicStore.doctors.map(_doctorCard),
        const SizedBox(height: 12),
        const _BookingStep(
          number: '2',
          title: 'Tanggal pemeriksaan',
          subtitle: 'Pilih hari kunjungan Anda',
        ),
        const SizedBox(height: 12),
        _datePickerCard(),
        const SizedBox(height: 20),
        const _BookingStep(
          number: '3',
          title: 'Pilih jam',
          subtitle: 'Jam menggunakan waktu WIB',
        ),
        const SizedBox(height: 12),
        _timePickerCard(),
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 8),
          child: Text(
            'Jam yang sudah terisi atau lewat tidak dapat dipilih.',
            style: TextStyle(color: ClinicColors.muted, fontSize: 10),
          ),
        ),
        const SizedBox(height: 20),
        const _BookingStep(
          number: '4',
          title: 'Keluhan singkat',
          subtitle: 'Opsional, membantu dokter mempersiapkan pemeriksaan',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          maxLength: 300,
          decoration: const InputDecoration(
            hintText: 'Tulis keluhan atau catatan untuk dokter...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F6F3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: ClinicColors.blue, size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Jadwal yang dikonfirmasi akan tercatat di riwayat dan notifikasi akun Anda.',
                  style: TextStyle(
                    color: ClinicColors.text,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        PrimaryButton(
          label: 'Konfirmasi booking',
          onPressed: _confirmBooking,
          icon: Icons.event_available_rounded,
        ),
      ],
    );
  }

  Widget _doctorCard(ClinicDoctor doctor) {
    final selected = _selectedDoctor?.id == doctor.id;
    return Semantics(
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? ClinicColors.blue : ClinicColors.line,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: ClinicColors.blue.withValues(alpha: .07),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() {
              _selectedDoctor = doctor;
              if (_selectedTime != null && _isBooked(_selectedTime!)) {
                _selectedTime = null;
              }
            }),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  PatientAvatar(name: doctor.name, size: 49, color: doctor.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
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
                          doctor.specialty,
                          style: TextStyle(
                            color: doctor.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${doctor.experience} tahun pengalaman · ${doctor.room}',
                          style: const TextStyle(
                            color: ClinicColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color:
                        selected ? ClinicColors.blue : const Color(0xFFC6D1DC),
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _datePickerCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _selectDate,
      child: ClinicCard(
        padding: 15,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: ClinicColors.blue,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal kunjungan',
                    style: TextStyle(color: ClinicColors.muted, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    clinicDate(_selectedDate, withWeekday: true),
                    style: const TextStyle(
                      color: ClinicColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_calendar_rounded,
              color: ClinicColors.blue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePickerCard() {
    return ClinicCard(
      padding: 15,
      child: Wrap(
        spacing: 8,
        runSpacing: 9,
        children: [
          for (final time in ClinicStore.availableTimes)
            _TimeOption(
              time: time,
              selected: _selectedTime == time,
              booked: _isBooked(time),
              unavailable: _isPastTime(time),
              onTap: () => setState(() => _selectedTime = time),
            ),
        ],
      ),
    );
  }
}

class _BookingStep extends StatelessWidget {
  const _BookingStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ClinicColors.blue,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ClinicColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: ClinicColors.muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.time,
    required this.selected,
    required this.booked,
    required this.unavailable,
    required this.onTap,
  });

  final String time;
  final bool selected;
  final bool booked;
  final bool unavailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = booked || unavailable;
    final color = disabled
        ? const Color(0xFFBAC4CF)
        : selected
        ? Colors.white
        : ClinicColors.text;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFF0F3F6)
              : selected
              ? ClinicColors.blue
              : const Color(0xFFF5F7F4),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected
                ? ClinicColors.blue
                : disabled
                ? const Color(0xFFE7EBEF)
                : ClinicColors.line,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            decoration: booked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
