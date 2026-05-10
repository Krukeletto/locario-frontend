import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/shell/hub/hub_action_item.dart';
import 'package:locario/features/shell/hub/hub_panel.dart';
import 'package:locario/shared/services/feedback_service.dart';

import '../../../test_helpers/test_app.dart';

void main() {
  testWidgets('shows coming soon toast for disabled hub tiles', (tester) async {
    FeedbackService.resetForTests();

    var selectedCount = 0;

    await tester.pumpWidget(
      buildLocalizedTestApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: Center(
            child: HubPanel(
              items: const [
                HubActionItem(
                  id: 'create-event',
                  icon: 'add_box',
                  routePath: '/hub/create-event',
                  isPrimary: true,
                ),
                HubActionItem(
                  id: 'inbox',
                  icon: 'inbox',
                  routePath: '/hub/inbox',
                  isEnabled: false,
                ),
                HubActionItem(
                  id: 'messages',
                  icon: 'mail',
                  routePath: '/hub/messages',
                  isEnabled: false,
                ),
                HubActionItem(
                  id: 'community',
                  icon: 'groups',
                  routePath: '/hub/community',
                  isEnabled: false,
                ),
                HubActionItem(
                  id: 'friends',
                  icon: 'person_add',
                  routePath: '/hub/friends',
                  isEnabled: false,
                ),
              ],
              onItemSelected: (_) {
                selectedCount += 1;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final communityTile = find.ancestor(
      of: find.text('Community'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(communityTile);
    await tester.tap(communityTile);
    await tester.pumpAndSettle();

    expect(selectedCount, 0);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('This section is still being built.'), findsOneWidget);
  });
}
