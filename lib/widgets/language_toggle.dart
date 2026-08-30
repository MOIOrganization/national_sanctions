import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocaleController localeController = LocaleScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return TextButton(
      onPressed: localeController.toggle,
      child: Text(
        localeController.isArabic ? l10n.switchToEnglish : l10n.switchToArabic,
        style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}
