import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:locario/shared/groups/group_models.dart';
import 'package:locario/shared/groups/group_repository.dart';

void main() {
  group('HttpGroupRepository', () {
    test('fetchDiscoverGroups maps paged response', () async {
      final repository = HttpGroupRepository(
        client: MockClient((request) async {
          expect(request.url.path, '/api/groups/discover');
          expect(request.url.queryParameters['q'], 'music');
          return http.Response(
            jsonEncode({
              'content': [
                {
                  'id': 'group-1',
                  'name': 'Jazz Crew',
                  'description': 'Local concerts',
                  'visibility': 'PUBLIC',
                  'memberCount': 14,
                  'categoryName': 'Music',
                },
              ],
            }),
            200,
          );
        }),
        baseUrl: 'http://example.com',
      );

      final groups = await repository.fetchDiscoverGroups(query: 'music');

      expect(groups, hasLength(1));
      expect(groups.single.name, 'Jazz Crew');
      expect(groups.single.visibility, GroupVisibility.public);
      expect(groups.single.memberCount, 14);
    });

    test('createGroup sends auth header and JSON body', () async {
      late http.Request capturedRequest;
      final repository = HttpGroupRepository(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 'group-1',
              'name': 'Jazz Crew',
              'visibility': 'PRIVATE',
            }),
            201,
          );
        }),
        baseUrl: 'http://example.com',
      );

      final group = await repository.createGroup(
        const GroupCreateRequest(
          name: 'Jazz Crew',
          description: 'Local concerts',
          visibility: GroupVisibility.private,
        ),
        accessToken: 'access-token',
      );

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/api/groups');
      expect(capturedRequest.headers['Authorization'], 'Bearer access-token');
      expect(
        jsonDecode(capturedRequest.body),
        containsPair('visibility', 'PRIVATE'),
      );
      expect(group.visibility, GroupVisibility.private);
    });
  });
}
