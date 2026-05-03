import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/shared/services/map_launch_service.dart';

void main() {
  const location = LatLng(51.7592, 19.4550);

  group('MapLaunchService', () {
    test('buildLocationUri uses geo scheme on Android', () {
      final uri = MapLaunchService.buildLocationUri(
        location,
        platform: TargetPlatform.android,
      );

      expect(uri.scheme, 'geo');
      expect(uri.path, '51.759200,19.455000');
      expect(uri.queryParameters['q'], '51.759200,19.455000');
    });

    test('buildLocationUri uses Apple Maps on iOS', () {
      final uri = MapLaunchService.buildLocationUri(
        location,
        platform: TargetPlatform.iOS,
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'maps.apple.com');
      expect(uri.queryParameters['ll'], '51.759200,19.455000');
    });

    test('buildLocationUri falls back to Google Maps on web and desktop', () {
      final webUri = MapLaunchService.buildLocationUri(location, isWeb: true);
      final desktopUri = MapLaunchService.buildLocationUri(
        location,
        platform: TargetPlatform.windows,
      );

      for (final uri in [webUri, desktopUri]) {
        expect(uri.scheme, 'https');
        expect(uri.host, 'www.google.com');
        expect(uri.path, '/maps/search/');
        expect(uri.queryParameters['api'], '1');
        expect(uri.queryParameters['query'], '51.759200,19.455000');
      }
    });
  });
}
