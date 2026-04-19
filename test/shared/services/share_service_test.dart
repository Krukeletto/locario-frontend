import 'package:flutter_test/flutter_test.dart';
import 'package:locario/shared/services/share_service.dart';

void main() {
  test('getEventUrl returns the HTTPS event deep link', () {
    expect(
      ShareService.getEventUrl('11111111-1111-1111-1111-111111111111'),
      'https://locario-events.web.app/events/11111111-1111-1111-1111-111111111111',
    );
  });
}
