import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../theme/app_colors.dart';
import 'notification_popup.dart';

class NotificationButton extends StatelessWidget {
  final int unreadCount;
  final List<AppNotification> notifications;
  final ValueChanged<AppNotification>? onNotificationTap;

  const NotificationButton({
    super.key,
    this.unreadCount = 0,
    this.notifications = const [],
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int visibleCount = unreadCount < 0 ? 0 : unreadCount;

    return IconButton(
      tooltip: l10n.notifications,
      onPressed: () {
        showNotificationPopup(
          context: context,
          notifications: notifications,
          onNotificationTap: onNotificationTap,
        );
      },
      icon: Badge(
        isLabelVisible: visibleCount > 0,
        backgroundColor: AppColors.secondary,
        textColor: AppColors.onPrimary,
        label: Text(visibleCount > 99 ? '99+' : '$visibleCount'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
