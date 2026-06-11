enum EventStatus { opened, assigned, userArrivedOnSpot, solved, closed }

extension EventStatusX on EventStatus {
  String get apiValue {
    switch (this) {
      case EventStatus.opened:
        return 'opened';
      case EventStatus.assigned:
        return 'assigned';
      case EventStatus.userArrivedOnSpot:
        return 'user_arrived_on_spot';
      case EventStatus.solved:
        return 'solved';
      case EventStatus.closed:
        return 'closed';
    }
  }
}
