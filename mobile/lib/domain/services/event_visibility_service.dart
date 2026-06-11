import '../authorization/permissions.dart';
import '../enums/role.dart';
import '../models/geo_point.dart';
import '../models/rescue_event.dart';
import 'distance_service.dart';

class EventVisibilityService {
  const EventVisibilityService._();

  static List<RescueEvent> visibleEventsForUser({
    required Role role,
    required List<RescueEvent> allEvents,
    required GeoPoint? userLocation,
    double nearbyRadiusKm = 50,
  }) {
    if (Permissions.canSeeAllEvents(role)) return allEvents;

    if (role != Role.user || userLocation == null) {
      return const <RescueEvent>[];
    }

    return allEvents
        .where(
          (event) => DistanceService.isWithinRadiusKm(
            source: userLocation,
            target: event.location,
            radiusKm: nearbyRadiusKm,
          ),
        )
        .toList(growable: false);
  }
}
