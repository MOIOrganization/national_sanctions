import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../services/sanctions_service.dart';
import '../session/session_controller.dart';
import '../theme/app_colors.dart';
import 'notification_popup.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({super.key});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  bool _isLoading = false;

  Future<void> _onPressed() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final SessionController session = SessionScope.read(context);
    final String? userId = session.userId;
    List<AppNotification> notifications = session.notifications;

    if (userId != null && userId.isNotEmpty) {
      try {
        notifications = await SanctionsService().getUserNotifications(
          userId: userId,
        );

        if (mounted) {
          session.setNotifications(notifications);
        }
      } catch (error) {
        debugPrint('[NOTIFICATIONS] bl_get_user_notification error: $error');
      }
    } else {
      debugPrint(
        '[NOTIFICATIONS] user_id is missing; skipping bl_get_user_notification',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    await showNotificationPopup(
      context: context,
      notifications: notifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SessionController session = SessionScope.of(context);
    final int visibleCount =
        session.unreadCount < 0 ? 0 : session.unreadCount;

    return IconButton(
      tooltip: l10n.notifications,
      onPressed: _isLoading ? null : _onPressed,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onPrimary,
              ),
            )
          : Badge(
              isLabelVisible: visibleCount > 0,
              backgroundColor: AppColors.secondary,
              textColor: AppColors.onPrimary,
              label: Text(visibleCount > 99 ? '99+' : '$visibleCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
    );
  }
}
