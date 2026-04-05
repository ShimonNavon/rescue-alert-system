import 'package:equatable/equatable.dart';

class UserGroup extends Equatable {
  const UserGroup({
    required this.id,
    required this.name,
    required this.memberCount,
  });

  final String id;
  final String name;
  final int memberCount;

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, memberCount];
}
