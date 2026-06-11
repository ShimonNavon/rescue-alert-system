import 'package:rxdart/rxdart.dart';

import '../../../domain/enums/role.dart';
import '../../../domain/models/geo_point.dart';
import '../../../domain/models/rescue_event.dart';
import '../../../domain/services/event_visibility_service.dart';

class EventBloc {
  EventBloc({required this.role, required this.userLocation});

  final Role role;
  final GeoPoint? userLocation;

  final BehaviorSubject<List<RescueEvent>> _allEvents$ =
      BehaviorSubject<List<RescueEvent>>.seeded(const <RescueEvent>[]);

  ValueStream<List<RescueEvent>> get visibleEvents$ => _allEvents$
      .map((all) {
        return EventVisibilityService.visibleEventsForUser(
          role: role,
          allEvents: all,
          userLocation: userLocation,
          nearbyRadiusKm: 50,
        );
      })
      .shareValueSeeded(const <RescueEvent>[]);

  void setAllEvents(List<RescueEvent> events) {
    _allEvents$.add(events);
  }

  void dispose() {
    _allEvents$.close();
  }
}
