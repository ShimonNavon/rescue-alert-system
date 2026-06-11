import '../enums/role.dart';

class Permissions {
  const Permissions._();

  static bool canManageUsers(Role role) => role == Role.manager;

  static bool canCreateEvent(Role role) =>
      role == Role.manager || role == Role.emergencyDispatcher;

  static bool canEditEvent(Role role) =>
      role == Role.manager || role == Role.emergencyDispatcher;

  static bool canDeleteEvent(Role role) =>
      role == Role.manager || role == Role.emergencyDispatcher;

  static bool canAssignUsersToEvent(Role role) =>
      role == Role.manager || role == Role.emergencyDispatcher;

  static bool canChangeEventStatus(Role role) =>
      role == Role.manager || role == Role.emergencyDispatcher;

  static bool canSeeAllEvents(Role role) =>
      role == Role.manager || role == Role.emergencyDispatcher;

  static bool canAcceptOrDeclineEvents(Role role) => role == Role.user;
}
