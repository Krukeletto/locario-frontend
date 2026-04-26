import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/auth/login_screen.dart';
import 'package:locario/features/auth/register_screen.dart';

import '../../test_helpers/test_app.dart';

Future<void> _pumpRegisterScreen(
  WidgetTester tester, {
  Locale locale = const Locale('pl'),
}) async {
  await tester.pumpWidget(
    buildLocalizedTestApp(locale: locale, home: const RegisterScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('RegisterScreen', () {
    testWidgets('shows validation errors for empty submit', (tester) async {
      await _pumpRegisterScreen(tester);

      final submitButton = find.text('Zarejestruj się');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Podaj nazwę użytkownika'), findsOneWidget);
      expect(find.text('Podaj adres e-mail'), findsOneWidget);
      expect(find.text('Podaj hasło'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid values', (tester) async {
      await _pumpRegisterScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'zly login');
      await tester.enterText(find.byType(TextField).at(1), 'zly-email');
      await tester.enterText(find.byType(TextField).at(2), '123');
      final submitButton = find.text('Zarejestruj się');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Dozwolone: litery, cyfry, . _ -'), findsOneWidget);
      expect(find.text('Podaj poprawny adres e-mail'), findsOneWidget);
      expect(find.text('Hasło musi mieć min. 8 znaków'), findsOneWidget);
    });

    testWidgets('accepts valid values without validation errors', (
      tester,
    ) async {
      await _pumpRegisterScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'uzytkownik_01');
      await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'stringst');
      final submitButton = find.text('Zarejestruj się');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Podaj nazwę użytkownika'), findsNothing);
      expect(find.text('Podaj poprawny adres e-mail'), findsNothing);
      expect(find.text('Hasło musi mieć min. 8 znaków'), findsNothing);
    });

    testWidgets('navigates to login screen from footer action', (tester) async {
      await _pumpRegisterScreen(tester);

      final loginAction = find.text('Zaloguj się na konto');
      await tester.ensureVisible(loginAction);
      await tester.tap(loginAction);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
