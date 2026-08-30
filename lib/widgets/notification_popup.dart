import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'notification_empty_state.dart';

Future<void> showNotificationPopup({
  required BuildContext context,
  List<AppNotification> notifications = const [],
  ValueChanged<AppNotification>? onNotificationTap,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return NotificationPopup(
        notifications: notifications,
        onClose: () => Navigator.pop(dialogContext),
        onNotificationTap: (notification) {
          Navigator.pop(dialogContext);
          onNotificationTap?.call(notification);
        },
      );
    },
  );
}

class NotificationPopup extends StatelessWidget {
  final List<AppNotification> notifications;
  final VoidCallback onClose;
  final ValueChanged<AppNotification>? onNotificationTap;

  const NotificationPopup({
    super.key,
    this.notifications = const [],
    required this.onClose,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double maxWidth = screenWidth < 400 ? screenWidth - 32 : 360;

    return Dialog(
      alignment: AlignmentDirectional.topStart,
      insetPadding: EdgeInsets.only(
        top:
            MediaQuery.paddingOf(context).top +
            kToolbarHeight +
            AppSpacing.xs,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.notifications,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const ColoredBox(
              color: AppColors.secondary,
              child: SizedBox(height: 2, width: double.infinity),
            ),
            if (notifications.isEmpty)
              const NotificationEmptyState()
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                  itemBuilder: (context, index) {
                    final AppNotification notification = notifications[index];

                    return _NotificationTile(
                      notification: notification,
                      onTap: () => onNotificationTap?.call(notification),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationTile({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!notification.isRead) ...[
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 8, color: AppColors.secondary),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: AppTextStyles.subheading),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.message,
                    style: AppTextStyles.body.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
