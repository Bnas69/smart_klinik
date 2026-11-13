import 'package:flutter/material.dart';

import '../app/clinic_store.dart';
import '../app/clinic_theme.dart';
import '../widgets/clinic_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.store});

  final ClinicStore store;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _isRegistering = false;
  bool _hidePassword = true;
  String? _authError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _authError = null);
    if (_isRegistering) {
      final error = widget.store.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
      );
      if (error != null) {
        setState(() => _authError = error);
      }
      return;
    }

    if (!widget.store.login(_emailController.text, _passwordController.text)) {
      setState(() => _authError = 'Email atau kata sandi tidak cocok.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -130,
            left: -100,
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                color: ClinicColors.blue.withValues(alpha: .05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -110,
            bottom: -100,
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                color: ClinicColors.cyan.withValues(alpha: .07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 24, 25, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandLogo(centered: true, large: true),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: ClinicColors.line),
                          boxShadow: [
                            BoxShadow(
                              color: ClinicColors.navy.withValues(alpha: .07),
                              blurRadius: 34,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4F0),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                _isRegistering
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.favorite_rounded,
                                color: ClinicColors.blue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _isRegistering
                                  ? 'Buat akun pasien'
                                  : 'Halo, selamat datang!',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isRegistering
                                  ? 'Daftar untuk mulai mengatur kunjungan Anda.'
                                  : 'Masuk untuk mengakses layanan kesehatan Anda.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 22),
                            if (_authError != null) ...[
                              _AuthError(message: _authError!),
                              const SizedBox(height: 14),
                            ],
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_isRegistering) ...[
                                    _inputField(
                                      controller: _nameController,
                                      label: 'Nama lengkap',
                                      hint: 'Masukkan nama Anda',
                                      icon: Icons.person_outline_rounded,
                                      validator: (value) =>
                                          value == null ||
                                              value.trim().length < 3
                                          ? 'Nama minimal 3 karakter.'
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  _inputField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'nama@email.com',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (!ClinicStore.isValidEmail(
                                        value ?? '',
                                      )) {
                                        return 'Masukkan alamat email yang valid.';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_isRegistering) ...[
                                    const SizedBox(height: 14),
                                    _inputField(
                                      controller: _phoneController,
                                      label: 'Nomor telepon',
                                      hint: '08xxxxxxxxxx',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) =>
                                          ClinicStore.isValidPhone(value ?? '')
                                          ? null
                                          : 'Masukkan nomor telepon yang valid.',
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  _inputField(
                                    controller: _passwordController,
                                    label: 'Kata sandi',
                                    hint: 'Minimal 8 karakter',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _hidePassword,
                                    suffix: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => setState(
                                        () => _hidePassword = !_hidePassword,
                                      ),
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: ClinicColors.muted,
                                        size: 19,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_isRegistering &&
                                          (value?.length ?? 0) < 8) {
                                        return 'Kata sandi minimal 8 karakter.';
                                      }
                                      if (value == null || value.isEmpty) {
                                        return 'Kata sandi wajib diisi.';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_isRegistering) ...[
                                    const SizedBox(height: 14),
                                    _inputField(
                                      controller: _confirmationController,
                                      label: 'Ulangi kata sandi',
                                      hint: 'Masukkan kembali kata sandi',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _hidePassword,
                                      validator: (value) =>
                                          value != _passwordController.text
                                          ? 'Konfirmasi kata sandi belum sama.'
                                          : null,
                                    ),
                                  ],
                                  const SizedBox(height: 21),
                                  PrimaryButton(
                                    label: _isRegistering
                                        ? 'Buat akun'
                                        : 'Masuk',
                                    icon: _isRegistering
                                        ? Icons.arrow_forward_rounded
                                        : Icons.login_rounded,
                                    onPressed: _submit,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    _isRegistering
                                        ? 'Sudah punya akun? '
                                        : 'Belum punya akun? ',
                                    style: const TextStyle(
                                      color: ClinicColors.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _isRegistering = !_isRegistering;
                                      _authError = null;
                                      _formKey.currentState?.reset();
                                    }),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      _isRegistering
                                          ? 'Masuk'
                                          : 'Daftar pasien',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 19),
                      const _DemoAccounts(),
                      const SizedBox(height: 23),
                      const Center(
                        child: Text(
                          '✦  Layanan aman untuk perjalanan sehat Anda',
                          style: TextStyle(
                            color: ClinicColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 19),
        suffixIcon: suffix,
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: ClinicColors.red,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: ClinicColors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccounts extends StatelessWidget {
  const _DemoAccounts();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClinicColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UTS PEMOGRAMAN FULLSTACK',
            style: TextStyle(
              color: ClinicColors.blue,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Septian Dwi Saputra',
            style: TextStyle(color: ClinicColors.text, fontSize: 11),
          ),
          SizedBox(height: 4),
          Text(
            '411232056',
            style: TextStyle(color: ClinicColors.text, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
