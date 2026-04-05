import 'package:equatable/equatable.dart';

class UserLocation extends Equatable {
  const UserLocation({
    required this.userId,
    required this.userName,
    required this.role,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  final String userId;
  final String userName;
  final String role;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Unknown',
      role: json['role']?.toString() ?? 'responder',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    userId,
    userName,
    role,
    latitude,
    longitude,
    updatedAt,
  ];
}
