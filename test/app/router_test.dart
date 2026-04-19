import 'package:flutter_test/flutter_test.dart';
import 'package:locario/app/router.dart';

void main() {
  group('normalizeIncomingLocation', () {
    test('normalizes locario host-based event deep links', () {
      expect(
        normalizeIncomingLocation(
          Uri.parse('locario://events/11111111-1111-1111-1111-111111111111'),
        ),
        '/events/11111111-1111-1111-1111-111111111111',
      );
    });

    test('normalizes path-only UUID event deep links', () {
      expect(
        normalizeIncomingLocation(
          Uri.parse('/11111111-1111-1111-1111-111111111111'),
        ),
        '/events/11111111-1111-1111-1111-111111111111',
      );
    });

    test('does not rewrite normal top-level app routes', () {
      expect(normalizeIncomingLocation(Uri.parse('/explore')), isNull);
      expect(normalizeIncomingLocation(Uri.parse('/profile')), isNull);
    });
  });
}
