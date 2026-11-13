import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';
import '../screens/main_shell.dart';
import 'clinic_store.dart';
import 'clinic_theme.dart';

class SmartClinicApp extends StatefulWidget {
  const SmartClinicApp({super.key});

  @override
  State<SmartClinicApp> createState() => _SmartClinicAppState();
}

class _SmartClinicAppState extends State<SmartClinicApp> {
  late final ClinicStore _store;

  @override
  void initState() {
    super.initState();
    _store = ClinicStore();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartClinic',
      debugShowCheckedModeBanner: false,
      theme: buildClinicTheme(),
      home: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final user = _store.currentUser;
          if (user == null) {
            return AuthScreen(store: _store);
          }
          return MainShell(store: _store, user: user);
        },
      ),
    );
  }
}
