import 'package:equatable/equatable.dart';

class UserGroup extends Equatable {
  const UserGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
  });

  final String id;
  final String name;
  final String description;
  final int memberCount;

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, description, memberCount];
}
