import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/events/event_screen.dart';

import '../../test_helpers/test_app.dart';

void main() {
  group('EventScreen', () {
    testWidgets('renders selected event title and buy ticket CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: const EventScreen(eventId: 'jazz-botanical-garden'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Szczegóły wydarzenia'), findsOneWidget);
      expect(find.text('Jazz w Ogrodzie Botanicznym'), findsOneWidget);
      expect(find.text('Kup bilet'), findsOneWidget);
      expect(find.text('Czat uczestników'), findsOneWidget);
    });

    testWidgets('renders fallback content when event is unknown', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedTestApp(home: const EventScreen(eventId: 'unknown-id')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wydarzenie'), findsOneWidget);
      expect(find.text('Lokalizacja nieznana'), findsOneWidget);
      expect(find.text('Zapisz się'), findsOneWidget);
    });
  });
}
