import 'dart:async';

import 'package:location_platform_interface/location_platform_interface.dart';

///replaces the method-channel location implementation with an in-memory one.
class FakeLocationPlatform extends LocationPlatform {
  LocationData? lastKnownLocation;
  LocationData? currentLocation;
  PermissionStatus permissionStatus = PermissionStatus.granted;
  PermissionStatus permissionStatusAfterRequest = PermissionStatus.granted;

  int getLocationCalls = 0;
  int hasPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int changeSettingsCalls = 0;
  int enableBackgroundModeCalls = 0;
  int requestServiceCalls = 0;

  LocationAccuracy? accuracy;
  int? interval;
  double? distanceFilter;
  bool? backgroundModeEnabled;

  final StreamController<LocationData> controller =
      StreamController<LocationData>.broadcast();

  @override
  Future<LocationData?> getLastKnownLocation() async => lastKnownLocation;

  @override
  Future<LocationData> getLocation() async {
    getLocationCalls++;
    return currentLocation ??
        (throw StateError('No current location configured'));
  }

  @override
  Future<PermissionStatus> hasPermission() async {
    hasPermissionCalls++;
    return permissionStatus;
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    requestPermissionCalls++;
    return permissionStatusAfterRequest;
  }

  @override
  Future<bool> changeSettings({
    LocationAccuracy? accuracy,
    int? interval,
    double? distanceFilter,
    bool? pausesLocationUpdatesAutomatically,
    int? backgroundInterval,
  }) async {
    changeSettingsCalls++;
    this.accuracy = accuracy;
    this.interval = interval;
    this.distanceFilter = distanceFilter;
    return true;
  }

  @override
  Future<bool> enableBackgroundMode({
    bool? enable = true,
    bool requireBackgroundPermission = true,
  }) async {
    enableBackgroundModeCalls++;
    backgroundModeEnabled = enable;
    return true;
  }

  @override
  Future<bool> requestService() async {
    requestServiceCalls++;
    return true;
  }

  @override
  Stream<LocationData> get onLocationChanged => controller.stream;
}

/// Builds a [LocationData] with nothing but the coordinates filled in.
LocationData at(double latitude, double longitude) => LocationData.fromMap(
  <String, dynamic>{'latitude': latitude, 'longitude': longitude},
);
