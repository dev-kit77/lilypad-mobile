import 'dart:async';

import 'package:geocoder_pro/geocoder_pro.dart';
import 'package:lilypad/services/log.dart';
import 'package:location/location.dart';

class GeolocationService {
  static PermissionStatus _enabled = PermissionStatus.denied;
  static late Stream<LocationData> _locationStream;
  static LocationData? _lastKnown;
  static GeoData? _areaData;

  GeolocationService._();

  //init function to start the location service
  static Future<void> init() async {
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

    //capture location stream
    _locationStream = Location.instance.onLocationChanged;

    //init callback subscription
    _locationStream.listen(
      (l) async => await _updateArea(l),
      onError: ((e) => LogService.err(
        'Unable to retrieve location',
        src: 'Geolocation Controller',
      )),
    );
  }

  //function to push an update to the location i
  static Future<void> forceUpdate() async {
    //manual get location
    final LocationData newLocation = await Location.instance.getLocation();

    //update class data
    await _updateArea(newLocation);
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
  }
}
