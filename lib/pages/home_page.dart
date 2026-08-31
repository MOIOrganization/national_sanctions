import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/destination_card.dart';
import '../widgets/hub_hero.dart';
import '../widgets/notice_banner.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenUnitedNations;
  final VoidCallback onOpenNationalSanctions;

  const HomePage({
    super.key,
    required this.onOpenUnitedNations,
    required this.onOpenNationalSanctions,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double logoWidth = constraints.maxWidth.clamp(0.0, 160.0);

            return Center(
              child: Image.asset(
                'asset/images/home_logo.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        HubHero(
          icon: Icons.policy_outlined,
          title: l10n.officialLookup,
          subtitle: l10n.searchUnAndNational,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.selectAList, style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.md),
        DestinationCard(
          icon: Icons.public,
          title: l10n.unitedNations,
          description: l10n.unDescription,
          onTap: onOpenUnitedNations,
        ),
        const SizedBox(height: AppSpacing.md),
        DestinationCard(
          icon: Icons.account_balance_outlined,
          title: l10n.nationalList,
          description: l10n.nationalDescription,
          onTap: onOpenNationalSanctions,
        ),
        const SizedBox(height: AppSpacing.lg),
        NoticeBanner(message: l10n.officialSourceDisclaimer),
      ],
    );
  }
}
