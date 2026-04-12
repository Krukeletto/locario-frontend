import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locario/app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LocarioApp renders main bottom navigation tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LocarioApp());
    await tester.pumpAndSettle();

    expect(find.text('Odkrywaj'), findsOneWidget);
    expect(find.text('Skrzynka'), findsOneWidget);
    expect(find.text('Hub'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
