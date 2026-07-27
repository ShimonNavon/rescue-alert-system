import 'package:rescue_app/domain/services/api/rest_api_models.dart';

class UserDetails {
  final int id;
  final String username;
  final String role;
  final String email;
  final double? latitude;
  final double? longitude;

  UserDetails({
    required this.id,
    required this.username,
    required this.role,
    required this.email,
    this.latitude,
    this.longitude,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  UserCoordinate get coordinates {
    return UserCoordinate(
      id: id,
      latitude: (latitude != null) ? (latitude ?? 0) : 0.0,
      longitude: (longitude != null) ? (longitude ?? 0) : 0.0,
      username: username,
      role: role,
    );
  }
}
