import 'package:flutter/material.dart';

class ClinicColors {
  static const blue = Color(0xFF176B65);
  static const blueDark = Color(0xFF11534E);
  static const navy = Color(0xFF193B3A);
  static const cyan = Color(0xFF54AFA2);
  static const canvas = Color(0xFFF4F6F2);
  static const text = Color(0xFF2C4542);
  static const muted = Color(0xFF607873);
  static const line = Color(0xFFDCE7E2);
  static const green = Color(0xFF21816E);
  static const red = Color(0xFFB94E4B);
}

ThemeData buildClinicTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: ClinicColors.blue,
    primary: ClinicColors.blue,
    secondary: ClinicColors.cyan,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: ClinicColors.canvas,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ClinicColors.navy,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: ClinicColors.navy,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: ClinicColors.blue.withValues(alpha: .1),
      elevation: 12,
      height: 70,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? ClinicColors.blue : ClinicColors.muted,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 11,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAFBF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: const TextStyle(color: ClinicColors.muted, fontSize: 14),
      labelStyle: const TextStyle(color: ClinicColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: ClinicColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: ClinicColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: ClinicColors.blue, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: ClinicColors.red, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: ClinicColors.red),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: ClinicColors.navy,
        fontWeight: FontWeight.w800,
        fontSize: 25,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        color: ClinicColors.navy,
        fontWeight: FontWeight.w800,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: ClinicColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(color: ClinicColors.text, fontSize: 15),
      bodyMedium: TextStyle(color: ClinicColors.muted, fontSize: 13),
    ),
  );
}
