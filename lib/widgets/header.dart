import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'directional_chevron.dart';
import 'language_toggle.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showLogout;
  final VoidCallback? onLogout;

  const Header({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showLogout = false,
    this.onLogout,
  });

  Future<void> _confirmLogout(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logOut),
          content: Text(l10n.logOutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.logOut),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onLogout?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.maybePop(context),
              icon: const DirectionalBackIcon(),
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.heading.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        const LanguageToggleButton(),
        if (showLogout && onLogout != null)
          IconButton(
            tooltip: l10n.logOut,
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
