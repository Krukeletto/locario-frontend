import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as ph;

import '../location/location_service.dart';
import '../notifications/notification_service.dart';

enum AppPermissionStatus {
  granted,
  limited,
  denied,
  permanentlyDenied,
  restricted,
  unsupported,
}

class AppPermissionSnapshot {
  const AppPermissionSnapshot({
    required this.location,
    required this.notifications,
    required this.photos,
    required this.calendar,
  });

  final AppPermissionStatus location;
  final AppPermissionStatus notifications;
  final AppPermissionStatus photos;
  final AppPermissionStatus calendar;
}

abstract class AppPermissionService {
  Future<AppPermissionSnapshot> loadStatus();
  Future<AppPermissionStatus> requestLocation();
  Future<AppPermissionStatus> requestNotifications();
  Future<bool> openAppSettings();
}

class DeviceAppPermissionService implements AppPermissionService {
  DeviceAppPermissionService({LocationService? locationService})
    : _locationService = locationService ?? GeolocatorLocationService();

  final LocationService _locationService;

  @override
  Future<AppPermissionSnapshot> loadStatus() async {
    final statuses = await Future.wait([
      _loadLocationStatus(),
      _permissionStatus(ph.Permission.notification.status),
      _loadPhotosStatus(),
      _loadCalendarStatus(),
    ]);

    return AppPermissionSnapshot(
      location: statuses[0],
      notifications: statuses[1],
      photos: statuses[2],
      calendar: statuses[3],
    );
  }

  @override
  Future<AppPermissionStatus> requestLocation() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return AppPermissionStatus.denied;
    }

    var status = await _locationService.checkPermission();
    if (status == geo.LocationPermission.denied) {
      status = await _locationService.requestPermission();
    }
    return _locationStatus(status);
  }

  @override
  Future<AppPermissionStatus> requestNotifications() async {
    await NotificationService.requestPermissions();
    return _permissionStatus(ph.Permission.notification.status);
  }

  @override
  Future<bool> openAppSettings() {
    return ph.openAppSettings();
  }

  Future<AppPermissionStatus> _loadLocationStatus() async {
    try {
      final status = await _locationService.checkPermission();
      return _locationStatus(status);
    } catch (_) {
      return AppPermissionStatus.unsupported;
    }
  }

  Future<AppPermissionStatus> _loadPhotosStatus() async {
    final photos = await _permissionStatus(ph.Permission.photos.status);
    if (photos == AppPermissionStatus.granted ||
        photos == AppPermissionStatus.limited) {
      return photos;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final storage = await _permissionStatus(ph.Permission.storage.status);
      if (storage == AppPermissionStatus.granted) {
        return storage;
      }
    }

    return photos;
  }

  Future<AppPermissionStatus> _loadCalendarStatus() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AppPermissionStatus.granted;
    }

    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return AppPermissionStatus.unsupported;
    }

    return _permissionStatus(ph.Permission.calendarWriteOnly.status);
  }

  Future<AppPermissionStatus> _permissionStatus(
    Future<ph.PermissionStatus> future,
  ) async {
    try {
      final status = await future;
      return _mapPermissionHandlerStatus(status);
    } catch (_) {
      return AppPermissionStatus.unsupported;
    }
  }

  AppPermissionStatus _locationStatus(geo.LocationPermission status) {
    return switch (status) {
      geo.LocationPermission.always ||
      geo.LocationPermission.whileInUse => AppPermissionStatus.granted,
      geo.LocationPermission.denied => AppPermissionStatus.denied,
      geo.LocationPermission.deniedForever =>
        AppPermissionStatus.permanentlyDenied,
      geo.LocationPermission.unableToDetermine =>
        AppPermissionStatus.unsupported,
    };
  }

  AppPermissionStatus _mapPermissionHandlerStatus(ph.PermissionStatus status) {
    if (status.isGranted) return AppPermissionStatus.granted;
    if (status.isLimited) return AppPermissionStatus.limited;
    if (status.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) return AppPermissionStatus.restricted;
    if (status.isDenied) return AppPermissionStatus.denied;
    return AppPermissionStatus.unsupported;
  }
}
