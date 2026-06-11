enum Role { manager, emergencyDispatcher, user }

extension RoleX on Role {
  String get apiValue {
    switch (this) {
      case Role.manager:
        return 'manager';
      case Role.emergencyDispatcher:
        return 'emergency_dispatcher';
      case Role.user:
        return 'user';
    }
  }
}
