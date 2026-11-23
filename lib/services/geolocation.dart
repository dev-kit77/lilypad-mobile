import 'dart:async';

import 'package:geocoder_pro/geocoder_pro.dart';
import 'package:lilypad/services/log.dart';
import 'package:location/location.dart';

class GeolocationService {
  static PermissionStatus _enabled = PermissionStatus.denied;
  static late Stream<LocationData> _locationStream;
  static LocationData? _lastKnown;
  static GeoData? _areaData;
  static bool initalized = false;

  ///Reason the service could not be initialized, for UI error messages.
  static String? initializationError;

  GeolocationService._();

  /// Start the location service.
  ///
  /// [initalized] reports whether usable coordinates were obtained and
  /// [initializationError] records why they were not, so the UI can report a
  /// location problem instead of waiting forever.
  static Future<void> init() async {
    initalized = false;
    initializationError = null;
    await _start();
  }

  static Future<void> _start() async {
    //get cached last location
    _lastKnown = await Location.instance.getLastKnownLocation();

    //check if we have last location
    if (_lastKnown != null) {
      LogService.log('Fetched Last Known Location', src: 'Geolocation Service');
      await _updateArea(_lastKnown!);
    }

    //get location permission status
    _enabled = await Location.instance.hasPermission();

    LogService.log(
      'Checked location permission - ${_enabled.name}',
      src: 'Geolocation Service',
    );

    //check status
    if (_enabled != PermissionStatus.granted) {
      //request permission
      _enabled = await Location.instance.requestPermission();

      //recheck status
      if (_enabled != PermissionStatus.granted &&
          _enabled != PermissionStatus.grantedLimited) {
        initializationError = 'Location permission was not granted.';
        LogService.err(
          'Location Permissions not granted! App will fail to Initalize!',
          src: 'Geolocation Service',
        );
        return;
      }
    }

    //setup location request settings
    await Location.instance.changeSettings(
      //toggle accuracy based on granted/grantedLimited
      accuracy: _enabled == PermissionStatus.granted
          ? LocationAccuracy.balanced
          : LocationAccuracy.low,
      interval: 30000, //30 sec
      distanceFilter: 50, //refresh if more than 50m moved
    );
    await Location.instance.enableBackgroundMode();

    //init location service
    await Location.instance.requestService();

    //capture location stream and subscribe before the one-shot fix, so a
    //failed first read (e.g. location services disabled) doesn't stop updates
    _locationStream = Location.instance.onLocationChanged;
    _locationStream.listen(
      (l) async {
        try {
          await _updateArea(l);
          //location became available after a failed startup
          initalized = true;
          initializationError = null;
        } catch (e) {
          LogService.err(
            'Unable to update area: $e',
            src: 'Geolocation Controller',
          );
        }
      },
      onError: ((e) => LogService.err(
        'Unable to retrieve location',
        src: 'Geolocation Controller',
      )),
    );

    //get immediate location (best effort: a cached fix may already be usable)
    try {
      await _updateArea(await Location.instance.getLocation());
    } catch (e) {
      initializationError = e.toString();
      LogService.err(
        'Unable to get current location: $e',
        src: 'Geolocation Service',
        ex: e is Exception ? e : null,
      );
    }

    initalized = _areaData != null || _lastKnown != null;
  }

  //function to push an update to the location i
  static Future<void> forceUpdate() async {
    //manual get location
    final LocationData newLocation = await Location.instance.getLocation();

    //update class data
    await _updateArea(newLocation);
    initalized = true;
    initializationError = null;
  }

  //listen callback helper for updating the service when new data is recieved
  static Future<void> _updateArea(LocationData exactPos) async {
    //init new area var
    GeoData? newArea;

    //update last known location
    _lastKnown = exactPos;
    LogService.log(
      'Updated Location Recieved lat:${exactPos.latitude} lon:${exactPos.longitude}',
      src: 'Geolocation Service',
    );

    //init comparison coords
    final GeoCoordinates coords = GeoCoordinates(
      latitude: exactPos.latitude,
      longitude: exactPos.longitude,
    );

    //check if area needs updated
    if (_areaData == null) {
      newArea = await GeocoderPro.nominatim().getDataFromCoordinates(
        latitude: exactPos.latitude,
        longitude: exactPos.longitude,
        zoom: 13,
      );
    } else if (_areaData!.bounds != null) {
      if (!_areaData!.bounds!.contains(coords)) {
        newArea = await GeocoderPro.nominatim().getDataFromCoordinates(
          latitude: exactPos.latitude,
          longitude: exactPos.longitude,
          zoom: 13,
        );
      }
    } else if (_areaData!.coordinates.distanceTo(coords) > 4500) {
      newArea = await GeocoderPro.nominatim().getDataFromCoordinates(
        latitude: exactPos.latitude,
        longitude: exactPos.longitude,
        zoom: 13,
      );
    }

    //check if data recieved
    if (newArea != null) {
      //update area data
      _areaData = newArea;

      if (_areaData!.bounds != null) {
        LogService.log(
          'Updated area data recieved=${_areaData?.placeId} - $locale ${_areaData?.bounds?.northeast.latitude}, ${_areaData?.bounds?.northeast.latitude}, ${_areaData?.bounds?.southwest.latitude}, ${_areaData?.bounds?.southwest.latitude}',
          src: 'Geolocation Service',
        );
      } else {
        LogService.log(
          'Updated area data recieved=${_areaData!.placeId} - $locale',
        );
      }
    } else if (_areaData == null) {
      LogService.err(
        'Could not get updated area data. App will not function until new data recieved',
      );
    } else {
      if (_areaData!.bounds != null) {
        LogService.warn(
          'Could not get updated area data. falling back to previous=${_areaData?.placeId} - $locale ${_areaData?.bounds?.northeast.latitude}, ${_areaData?.bounds?.northeast.latitude}, ${_areaData?.bounds?.southwest.latitude}, ${_areaData?.bounds?.southwest.latitude}',
          src: 'Geolocation Service',
        );
      } else {
        LogService.warn(
          'Could not get updated area data. falling back to previous=${_areaData!.placeId} - $locale',
        );
      }
    }
  }

  ///getter to get the locale string specifying the area
  static String get locale {
    //get full address string
    final String? address = _areaData?.address;

    //check for no given address
    if (address == null || address.trim().isEmpty) {
      return 'Unknown, The Void';
    }

    //split address
    final List<String> addressPart = address.split(', ');

    //check split properly
    if (addressPart.isEmpty) {
      return 'Unknown, The Void';
    }

    //return locale string
    return addressPart.take(2).join(', ');
  }

  ///getter to get the lat/long pair of the area
  static Map<String, double?> get location => <String, double?>{
    'lat': _areaData?.latitude ?? _lastKnown?.latitude,
    'lon': _areaData?.longitude ?? _lastKnown?.longitude,
  };

  ///clears the cached location and area data. If used location should be requested again immedetlely
  static void clear() {
    _lastKnown = null;
    _areaData = null;
    initalized = false;
    initializationError = null;
  }
}
