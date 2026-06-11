import '../enums/event_status.dart';
import 'event_customer_details.dart';
import 'geo_point.dart';

class RescueEvent {
  const RescueEvent({
    required this.id,
    required this.title,
    required this.detail,
    required this.location,
    required this.customerDetails,
    required this.status,
    required this.assignedUserIds,
    this.solvedByUserId,
    this.closedByUserId,
  });

  final String id;
  final String title;
  final String detail;
  final GeoPoint location;
  final EventCustomerDetails customerDetails;
  final EventStatus status;
  final List<String> assignedUserIds;
  final String? solvedByUserId;
  final String? closedByUserId;
}
