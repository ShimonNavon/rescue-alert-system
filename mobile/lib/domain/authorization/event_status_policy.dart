import '../enums/event_status.dart';

class EventStatusPolicy {
  const EventStatusPolicy._();

  static bool canTransition({
    required EventStatus from,
    required EventStatus to,
  }) {
    if (from == to) return true;

    switch (from) {
      case EventStatus.opened:
        return to == EventStatus.assigned;
      case EventStatus.assigned:
        return to == EventStatus.userArrivedOnSpot;
      case EventStatus.userArrivedOnSpot:
        return to == EventStatus.solved;
      case EventStatus.solved:
        return to == EventStatus.closed;
      case EventStatus.closed:
        return false;
    }
  }
}
