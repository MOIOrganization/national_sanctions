enum NotificationDegree {
  high,
  medium,
  low,
  unknown;

  static NotificationDegree fromApi(dynamic value) {
    switch (value?.toString().trim().toUpperCase()) {
      case 'H':
        return NotificationDegree.high;
      case 'M':
        return NotificationDegree.medium;
      case 'L':
        return NotificationDegree.low;
      default:
        return NotificationDegree.unknown;
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime? timestamp;
  final NotificationDegree degree;
  final bool isVisible;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.timestamp,
    this.degree = NotificationDegree.unknown,
    this.isVisible = true,
  });

  static List<AppNotification> listFromResponse(Map<String, dynamic> json) {
    final dynamic data = json['DATA'];
    final List<AppNotification> notifications = [];

    if (data is List) {
      for (int index = 0; index < data.length; index++) {
        final dynamic item = data[index];

        if (item is! Map) {
          continue;
        }

        final AppNotification notification = AppNotification.fromApi(
          Map<String, dynamic>.from(item),
          index: index,
        );

        if (notification.isVisible) {
          notifications.add(notification);
        }
      }
    } else if (data is Map) {
      final AppNotification notification = AppNotification.fromApi(
        Map<String, dynamic>.from(data),
        index: 0,
      );

      if (notification.isVisible) {
        notifications.add(notification);
      }
    }

    notifications.sort((a, b) {
      final DateTime aDate = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bDate = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return notifications;
  }

  factory AppNotification.fromApi(
    Map<String, dynamic> json, {
    required int index,
  }) {
    final String id = _text(json['ID'] ?? index + 1);
    final String title = _text(json['NOTIFY_TITLE']);
    final String text = _text(json['NOTIFY_TEXT']);
    final String showFlag = _text(json['SHOW_FLAG']).toUpperCase();

    return AppNotification(
      id: id.isEmpty ? '${index + 1}' : id,
      title: title.isNotEmpty ? title : text,
      message: text.isNotEmpty ? text : title,
      timestamp: _date(json['FROM_DATE'] ?? json['CREATED']),
      degree: NotificationDegree.fromApi(json['NOTIFY_DEGREE']),
      isVisible: showFlag.isEmpty || showFlag == 'Y',
    );
  }

  String formattedDateTime() {
    final DateTime? date = timestamp;

    if (date == null) {
      return '';
    }

    final DateTime local = date.toLocal();
    final String day = local.day.toString().padLeft(2, '0');
    final String month = local.month.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/${local.year}  $hour:$minute';
  }

  static String _text(dynamic value) {
    if (value == null) {
      return '';
    }

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }

  static DateTime? _date(dynamic value) {
    final String text = _text(value);

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}
