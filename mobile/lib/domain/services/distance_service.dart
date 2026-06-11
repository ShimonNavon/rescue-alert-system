import 'dart:math' as math;

import '../models/geo_point.dart';

class DistanceService {
  const DistanceService._();

  static const double _earthRadiusKm = 6371.0;

  static double distanceInKm(GeoPoint a, GeoPoint b) {
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);

    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final haversine =
        math.pow(math.sin(dLat / 2), 2) +
        math.pow(math.sin(dLon / 2), 2) * math.cos(lat1) * math.cos(lat2);

    final c = 2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
    return _earthRadiusKm * c;
  }

  static bool isWithinRadiusKm({
    required GeoPoint source,
    required GeoPoint target,
    required double radiusKm,
  }) {
    return distanceInKm(source, target) <= radiusKm;
  }

  static double _degToRad(double value) => value * (math.pi / 180.0);
}
