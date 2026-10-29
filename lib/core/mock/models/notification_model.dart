class NotificationModel {
  final String id;
  final String type; // 'order_update' | 'promo' | 'new_arrival'
  final String title;
  final String body;
  final String? imageUrl;
  final String? deepLink;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.deepLink,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      deepLink: json['deepLink'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'deepLink': deepLink,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}
