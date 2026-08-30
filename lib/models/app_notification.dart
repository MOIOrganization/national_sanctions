class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime? timestamp;
  final bool isRead;
  final String? type;
  final Object? actionData;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.timestamp,
    this.isRead = false,
    this.type,
    this.actionData,
  });
}
