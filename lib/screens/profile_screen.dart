import 'package:flutter/material.dart';

import '../app/clinic_models.dart';
import '../app/clinic_store.dart';
import '../app/clinic_theme.dart';
import '../widgets/clinic_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.store, required this.user});

  final ClinicStore store;
  final ClinicUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  DateTime? _birthDate;
  String _gender = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _birthDate = widget.user.birthDate;
    _gender = widget.user.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Pilih tanggal lahir',
    );
    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  void _saveProfile() {
    if (_nameController.text.trim().length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama minimal 3 karakter.')));
      return;
    }
    if (!ClinicStore.isValidPhone(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor telepon yang valid.')),
      );
      return;
    }
    final updated = widget.store.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      birthDate: _birthDate,
      gender: _gender,
    );
    if (!updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Periksa kembali data profil Anda.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
      children: [
        const SectionHeading(
          title: 'Profil pasien',
          subtitle: 'Kelola informasi pribadi Anda.',
        ),
        const SizedBox(height: 17),
        ClinicCard(
          padding: 0,
          child: Column(
            children: [
              Container(
                height: 82,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  gradient: LinearGradient(
                    colors: [ClinicColors.blue, ClinicColors.cyan],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -6,
                      top: -42,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 15),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 17,
                      top: 17,
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        color: Colors.white70,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 17),
                child: Row(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: PatientAvatar(name: widget.user.name, size: 54),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ClinicColors.navy,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.user.email,
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
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PASIEN',
                        style: TextStyle(
                          color: ClinicColors.green,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeading(
          title: 'Informasi pribadi',
          subtitle: 'Perubahan data berlaku selama sesi demo ini.',
        ),
        const SizedBox(height: 13),
        ClinicCard(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: widget.user.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                  helperText: 'Email akun demo tidak dapat diubah.',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor telepon',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickBirthDate,
                borderRadius: BorderRadius.circular(15),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal lahir',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    suffixIcon: Icon(Icons.expand_more_rounded),
                  ),
                  child: Text(
                    _birthDate == null
                        ? 'Pilih tanggal lahir'
                        : clinicDate(_birthDate!),
                    style: TextStyle(
                      color: _birthDate == null
                          ? ClinicColors.muted
                          : ClinicColors.text,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender.isEmpty ? null : _gender,
                decoration: const InputDecoration(
                  labelText: 'Jenis kelamin',
                  prefixIcon: Icon(Icons.wc_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                ],
                onChanged: (value) => setState(() => _gender = value ?? ''),
              ),
              const SizedBox(height: 17),
              PrimaryButton(
                label: 'Simpan perubahan',
                onPressed: _saveProfile,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 19),
        OutlinedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Keluar dari akun'),
          style: OutlinedButton.styleFrom(
            foregroundColor: ClinicColors.red,
            side: const BorderSide(color: Color(0xFFF1D7D7)),
            minimumSize: const Size.fromHeight(49),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 17),
        const Center(
          child: Text(
            'SmartClinic v1.0 · Data demo lokal',
            style: TextStyle(color: ClinicColors.muted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda akan kembali ke halaman masuk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      widget.store.logout();
    }
  }
}
