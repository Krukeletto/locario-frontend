import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLaunchService {
  MapLaunchService._();

  static Uri buildLocationUri(
    LatLng location, {
    TargetPlatform? platform,
    bool isWeb = false,
  }) {
    final latitude = location.latitude.toStringAsFixed(6);
    final longitude = location.longitude.toStringAsFixed(6);

    if (isWeb) {
      return _googleMapsUri(latitude, longitude);
    }

    return switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.android => Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude',
      ),
      TargetPlatform.iOS || TargetPlatform.macOS => Uri.parse(
        'https://maps.apple.com/?ll=$latitude,$longitude',
      ),
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.windows => _googleMapsUri(latitude, longitude),
    };
  }

  static Future<bool> openLocation(
    LatLng location, {
    TargetPlatform? platform,
    bool isWeb = false,
    Future<bool> Function(Uri uri)? opener,
  }) {
    final uri = buildLocationUri(location, platform: platform, isWeb: isWeb);
    return (opener ?? _launchExternal)(uri);
  }

  static Uri _googleMapsUri(String latitude, String longitude) {
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
  }

  static Future<bool> _launchExternal(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
