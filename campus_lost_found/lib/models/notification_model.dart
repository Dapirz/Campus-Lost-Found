class NotificationModel {
  final int id;
  final String type;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }

  NotificationModel copyWith({
    int? id,
    String? type,
    String? message,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
