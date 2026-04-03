import 'package:flutter_test/flutter_test.dart';

import 'package:locario/app/app.dart';

void main() {
  testWidgets('shell shows Explore by default', (tester) async {
    await tester.pumpWidget(const LocarioApp());
    await tester.pumpAndSettle();

    expect(find.text('Locario'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
