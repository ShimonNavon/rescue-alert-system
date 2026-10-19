class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role,
    required this.isStaff,
  });

  final int id;
  final String username;
  final String email;
  final String name;
  final String? role;
  final bool isStaff;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String?,
      isStaff: json['is_staff'] as bool? ?? false,
    );
  }
}
