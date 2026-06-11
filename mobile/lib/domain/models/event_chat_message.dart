import 'app_user.dart';
import 'geo_point.dart';

class EventChatMessage {
  const EventChatMessage({
    required this.id,
    required this.eventId,
    required this.title,
    required this.message,
    required this.sender,
    required this.createdAt,
    this.pttVoiceMessageUrl,
    this.location,
  });

  final String id;
  final String eventId;
  final String title;
  final String message;
  final AppUser sender;
  final DateTime createdAt;
  final String? pttVoiceMessageUrl;
  final GeoPoint? location;
}
