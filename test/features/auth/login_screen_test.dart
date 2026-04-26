import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/auth/login_screen.dart';
import 'package:locario/features/auth/register_screen.dart';

import '../../test_helpers/test_app.dart';

Future<void> _pumpLoginScreen(
  WidgetTester tester, {
  Locale locale = const Locale('pl'),
}) async {
  await tester.pumpWidget(
    buildLocalizedTestApp(locale: locale, home: const LoginScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LoginScreen', () {
    testWidgets('shows validation errors for empty submit', (tester) async {
      await _pumpLoginScreen(tester);

      await tester.tap(find.text('Zaloguj się'));
      await tester.pumpAndSettle();

      expect(find.text('Podaj adres e-mail'), findsOneWidget);
      expect(find.text('Podaj hasło'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid values', (tester) async {
      await _pumpLoginScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'zly-email');
      await tester.enterText(find.byType(TextField).at(1), '123');
      await tester.tap(find.text('Zaloguj się'));
      await tester.pumpAndSettle();

      expect(find.text('Podaj poprawny adres e-mail'), findsOneWidget);
      expect(find.text('Hasło musi mieć min. 8 znaków'), findsOneWidget);
    });

    testWidgets('accepts valid values without validation errors', (
      tester,
    ) async {
      await _pumpLoginScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'stringst');
      await tester.tap(find.text('Zaloguj się'));
      await tester.pumpAndSettle();

      expect(find.text('Podaj poprawny adres e-mail'), findsNothing);
      expect(find.text('Hasło musi mieć min. 8 znaków'), findsNothing);
      expect(find.text('Podaj adres e-mail'), findsNothing);
      expect(find.text('Podaj hasło'), findsNothing);
    });

    testWidgets('navigates to register screen from footer action', (
      tester,
    ) async {
      await _pumpLoginScreen(tester);

      final registerAction = find.text('Utwórz darmowe konto');
      await tester.ensureVisible(registerAction);
      await tester.tap(registerAction);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
}
