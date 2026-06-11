class JwtTokens {
  const JwtTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory JwtTokens.fromJson(Map<String, dynamic> json) {
    return JwtTokens(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'access': access,
      'refresh': refresh,
    };
  }
}

class UserCoordinate {
  const UserCoordinate({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.username,
    this.role,
  });

  final int id;
  final double latitude;
  final double longitude;
  final String? username;
  final String? role;

  factory UserCoordinate.fromJson(Map<String, dynamic> json) {
    return UserCoordinate(
      id: (json['id'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      username: json['username'] as String?,
      role: json['role'] as String?,
    );
  }
}
