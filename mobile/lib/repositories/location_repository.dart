import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/domain/services/location_service.dart';
import '../models/user_location.dart';

class LocationRepository {
  LocationRepository._internal()
      : _apiClient = RestApiService(),
        _locationService = LocationService();

  static final LocationRepository _instance = LocationRepository._internal();

  factory LocationRepository() => _instance;

  final RestApiService _apiClient;
  final LocationService _locationService;

  StreamSubscription<Position>? _positionSubscription;

  Future<void> startTracking() async {
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1000, // Notify only after moving 1000 meters
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: settings)
            .listen((Position position) async {
      await _apiClient.postCurrentLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      print(
        'Moved to ${position.latitude}, ${position.longitude}',
      );
    });
    // final position = await _locationService.startTracking();
    // if (position == null) {
    //   return;
    // }
  }

  void stopTracking() async {
    await _positionSubscription?.cancel();
    await _locationService.stopTracking();
  }

  Future<List<UserLocation>> getAllUserLocations() =>
      _apiClient.getAllUsersLocation();
}
