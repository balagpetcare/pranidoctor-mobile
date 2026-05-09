/// In-app notification row from GET `/api/notifications`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readRaw = json['readAt'];
    final createdRaw = json['createdAt'];
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      readAt: readRaw == null ? null : DateTime.tryParse(readRaw as String),
      createdAt: createdRaw is String
          ? DateTime.parse(createdRaw)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
