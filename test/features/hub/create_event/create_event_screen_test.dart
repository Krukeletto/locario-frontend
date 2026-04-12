import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/hub/create_event/create_event_screen.dart';

import '../../../test_helpers/test_app.dart';

Future<void> _pumpCreateEventScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    buildLocalizedTestApp(home: const CreateEventScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CreateEventScreen', () {
    testWidgets('renders core create event sections', (tester) async {
      await _pumpCreateEventScreen(tester);

      expect(find.text('Dodaj zdjęcie główne'), findsOneWidget);
      expect(find.text('Sugerowany rozmiar: 1600 x 900 px'), findsOneWidget);
      expect(find.text('Nazwa wydarzenia'), findsOneWidget);
      expect(find.text('Kategoria'), findsOneWidget);
      expect(find.text('Bilety i wstęp'), findsOneWidget);
      expect(find.text('Stwórz wydarzenie'), findsWidgets);
    });

    testWidgets('shows date/time validation when submit without pickers', (
      tester,
    ) async {
      await _pumpCreateEventScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Wieczór planszówek',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Łódź, Centrum');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Spotykamy się na wspólne granie i integrację.',
      );

      final submitButton = find.text('Stwórz wydarzenie');
      await tester.tap(submitButton.first);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('toggles ticketing fields visibility', (tester) async {
      await _pumpCreateEventScreen(tester);

      expect(find.byType(TextFormField), findsNWidgets(3));

      final ticketSwitch = find.byType(Switch);
      await tester.tap(ticketSwitch.first);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(5));

      await tester.tap(ticketSwitch.first);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(3));
    });
  });
}
