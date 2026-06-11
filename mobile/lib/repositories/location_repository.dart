import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/domain/services/location_service.dart';
import '../models/user_location.dart';

class LocationRepository {
  LocationRepository({
    required RestApiService apiClient,
    required LocationService locationService,
  })  : _apiClient = apiClient,
        _locationService = locationService;

  final RestApiService _apiClient;
  final LocationService _locationService;

  Future<void> publishCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      return;
    }
    await _apiClient.postCurrentLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<List<UserLocation>> getAllUserLocations() =>
      _apiClient.getAllUsersLocation();
}
