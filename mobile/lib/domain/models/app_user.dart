import '../enums/role.dart';
import 'geo_point.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.privateName,
    required this.surName,
    required this.email,
    required this.phoneNumber,
    required this.residenceAddress,
    required this.workAddress,
    required this.carType,
    required this.carPlateNumber,
    required this.role,
    this.currentLocation,
  });

  final String id;
  final String privateName;
  final String surName;
  final String email;
  final String phoneNumber;
  final String residenceAddress;
  final String workAddress;
  final String carType;
  final String carPlateNumber;
  final Role role;
  final GeoPoint? currentLocation;
}
