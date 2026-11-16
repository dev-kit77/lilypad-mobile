///creates a Nominatim reverse-geocoding response.
Map<String, dynamic> nominatimResult({
  required int placeId,
  required String displayName,
  required double latitude,
  required double longitude,
  required String city,
  required String state,
  required String country,
  required String countryCode,
  required String postcode,
  required String houseNumber,
  required String road,
  required String suburb,
  required String county,
  List<double>? boundingBox,
}) => <String, dynamic>{
  'place_id': placeId,
  'lat': latitude.toString(),
  'lon': longitude.toString(),
  'display_name': displayName,
  if (boundingBox != null)
    'boundingbox': boundingBox.map((double d) => d.toString()).toList(),
  'address': <String, dynamic>{
    'house_number': houseNumber,
    'road': road,
    'suburb': suburb,
    'city': city,
    'county': county,
    'state': state,
    'postcode': postcode,
    'country': country,
    'country_code': countryCode.toLowerCase(),
  },
};

///Toronto, with bounding box around the city.
Map<String, dynamic> toronto({
  bool withBounds = true,
  String displayName = 'Toronto, Ontario, Canada',
}) => nominatimResult(
  placeId: 269367963,
  displayName: displayName,
  latitude: 43.6532,
  longitude: -79.3832,
  city: 'Toronto',
  state: 'Ontario',
  country: 'Canada',
  countryCode: 'CA',
  postcode: 'M5H 2N2',
  houseNumber: '100',
  road: 'King Street West',
  suburb: 'Downtown Toronto',
  county: 'Toronto Division',
  boundingBox: withBounds ? <double>[43.58, 43.85, -79.64, -79.11] : null,
);

///Vancouver with a bounding box around the city.
Map<String, dynamic> vancouver({bool withBounds = true}) => nominatimResult(
  placeId: 162443612,
  displayName: 'Vancouver, British Columbia, Canada',
  latitude: 49.2827,
  longitude: -123.1207,
  city: 'Vancouver',
  state: 'British Columbia',
  country: 'Canada',
  countryCode: 'CA',
  postcode: 'V6B 1A1',
  houseNumber: '800',
  road: 'West Georgia Street',
  suburb: 'Downtown Vancouver',
  county: 'Metro Vancouver Regional District',
  boundingBox: withBounds ? <double>[49.19, 49.31, -123.27, -123.02] : null,
);
