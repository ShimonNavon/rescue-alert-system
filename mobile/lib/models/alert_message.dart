class AlertMessage {
  final int id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final String priority;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlertMessage({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.priority,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertMessage.fromJson(Map<String, dynamic> json) {
    return AlertMessage(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String,
      priority: json['priority'] as String,
      location: json['location'] != null ? json['location'] as String : '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isCritical => status.toLowerCase() == 'critical';
}
