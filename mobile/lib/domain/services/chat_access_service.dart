import '../authorization/permissions.dart';
import '../enums/role.dart';
import '../models/rescue_event.dart';

class ChatAccessService {
  const ChatAccessService._();

  static bool canOpenEventChat({
    required Role role,
    required String userId,
    required RescueEvent event,
  }) {
    if (Permissions.canSeeAllEvents(role)) return true;
    return event.assignedUserIds.contains(userId);
  }
}
