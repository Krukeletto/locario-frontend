import 'package:flutter_test/flutter_test.dart';
import 'package:locario/shared/auth/auth_models.dart';

void main() {
  test('UpdateProfileRequest.toJson', () {
    const req = UpdateProfileRequest(
      username: 'u',
      email: 'e@x.com',
      avatarUrl: 'data:...jpg',
      bio: 'bio',
      websiteUrl: 'https://site',
      instagramUrl: 'https://instagram.com/u',
      facebookUrl: 'https://facebook.com/u',
    );

    final json = req.toJson();
    expect(json['username'], 'u');
    expect(json['email'], 'e@x.com');
    expect(json['avatarUrl'], 'data:...jpg');
    expect(json['bio'], 'bio');
    expect(json['websiteUrl'], 'https://site');
    expect(json['instagramUrl'], 'https://instagram.com/u');
    expect(json['facebookUrl'], 'https://facebook.com/u');
  });

  test('UserProfile.fromJson parses nested lists', () {
    final now = DateTime.utc(2026, 5, 1).toIso8601String();
    final json = {
      'id': 'u1',
      'username': 'tester',
      'email': 't@example.com',
      'hasPassword': true,
      'avatarUrl': 'https://img',
      'bio': 'bio',
      'websiteUrl': 'https://site',
      'instagramUrl': 'https://instagram',
      'facebookUrl': 'https://facebook',
      'createdAt': now,
      'eventRegistrations': [
        {'eventId': 'e1', 'name': 'Event', 'startAt': now},
      ],
      'favorites': [
        {'eventId': 'f1', 'name': 'Fav', 'startAt': now},
      ],
    };

    final profile = UserProfile.fromJson(json);
    expect(profile.id, 'u1');
    expect(profile.username, 'tester');
    expect(profile.avatarUrl, 'https://img');
    expect(profile.eventRegistrations.length, 1);
    expect(profile.favorites.length, 1);
  });
}
