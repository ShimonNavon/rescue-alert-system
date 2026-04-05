import '../models/user_location.dart';
import '../services/api_client.dart';
import '../services/location_service.dart';

class LocationRepository {
  LocationRepository({
    required ApiClient apiClient,
    required LocationService locationService,
  }) : _apiClient = apiClient,
       _locationService = locationService;

  final ApiClient _apiClient;
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
