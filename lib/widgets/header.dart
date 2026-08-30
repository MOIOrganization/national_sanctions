import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'account_drawer.dart';
import 'directional_chevron.dart';
import 'language_toggle.dart';
import 'notification_button.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final int unreadCount;
  final List<AppNotification> notifications;
  final ValueChanged<AppNotification>? onNotificationTap;

  const Header({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.unreadCount = 0,
    this.notifications = const [],
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: showBackButton ? 104 : 56,
      leading: Row(
        children: [
          if (showBackButton)
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.maybePop(context),
              icon: const DirectionalBackIcon(),
            ),
          NotificationButton(
            unreadCount: unreadCount,
            notifications: notifications,
            onNotificationTap: onNotificationTap,
          ),
        ],
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.heading.copyWith(color: AppColors.onPrimary),
      ),
      centerTitle: true,
      actions: [
        const LanguageToggleButton(),
        IconButton(
          tooltip: l10n.accountMenu,
          onPressed: () => showAccountDrawer(context: context),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
