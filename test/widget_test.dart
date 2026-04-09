import 'package:flutter_test/flutter_test.dart';

import 'package:locario/app/app.dart';

void main() {
  testWidgets('LocarioApp renders main bottom navigation tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LocarioApp());
    await tester.pumpAndSettle();

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}
