import 'package:equatable/equatable.dart';

class AppMessage extends Equatable {
  const AppMessage({
    required this.id,
    required this.title,
    required this.text,
    required this.audioUrl,
    required this.createdAt,
    required this.userMetadata,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String title;
  final String text;
  final String? audioUrl;
  final DateTime createdAt;
  final Map<String, dynamic> userMetadata;
  final double? latitude;
  final double? longitude;

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      audioUrl: json['audioUrl']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      userMetadata:
          (json['userMetadata'] as Map?)?.cast<String, dynamic>() ?? const {},
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    text,
    audioUrl,
    createdAt,
    userMetadata,
    latitude,
    longitude,
  ];
}
