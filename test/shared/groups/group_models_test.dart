import 'package:flutter_test/flutter_test.dart';
import 'package:locario/shared/groups/group_models.dart';

void main() {
  test('GroupFeedItem parses organizer fallback for event items', () {
    final item = GroupFeedItem.fromJson({
      'type': 'EVENT',
      'id': 'event-1',
      'content': 'Linked event',
      'createdAt': '2026-06-12T12:45:00Z',
      'eventId': 'linked-event',
      'eventName': 'Mountain walk',
      'eventStartAt': '2026-06-18T18:00:00Z',
      'organizer': {
        'userId': 'user-2',
        'username': 'Piotr',
        'avatarUrl': 'https://example.com/avatar.png',
      },
    });

    expect(item.authorId, 'user-2');
    expect(item.authorUsername, 'Piotr');
    expect(item.authorAvatarUrl, 'https://example.com/avatar.png');
  });
}
