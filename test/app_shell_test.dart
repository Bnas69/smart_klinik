import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic/app/clinic_store.dart';
import 'package:smart_clinic/app/smart_clinic_app.dart';
import 'package:smart_clinic/screens/main_shell.dart';

void main() {
  testWidgets('patient can log in and log out from the account menu', (
    tester,
  ) async {
    await tester.pumpWidget(const SmartClinicApp());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'pasien@smartclinic.id');
    await tester.enterText(fields.at(1), 'pasien123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('SMARTCLINIC'), findsOneWidget);
    await tester.tap(find.byTooltip('Menu akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar dari akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, selamat datang!'), findsOneWidget);
  });

  testWidgets('wide screens use a navigation rail', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = ClinicStore()..login('admin@smartclinic.id', 'admin123');
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1200, 900)),
          child: MainShell(store: store, user: store.currentUser!),
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone screens use bottom navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = ClinicStore()..login('pasien@smartclinic.id', 'pasien123');
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: MainShell(store: store, user: store.currentUser!),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin pages remain usable on a phone screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = ClinicStore()..login('admin@smartclinic.id', 'admin123');
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: MainShell(store: store, user: store.currentUser!),
        ),
      ),
    );

    await tester.tap(find.text('Pasien').last);
    await tester.pumpAndSettle();
    expect(find.text('Data pasien'), findsWidgets);
    final exception = tester.takeException();
    expect(exception, isNull);

    await tester.tap(find.text('Kunjungan').last);
    await tester.pumpAndSettle();
    expect(find.text('Jadwal kunjungan'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
