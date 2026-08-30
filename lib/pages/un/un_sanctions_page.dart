import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/notice_banner.dart';

class UnSanctionsPage extends StatelessWidget {
  final VoidCallback onOpenIndividuals;
  final VoidCallback onOpenEntities;

  const UnSanctionsPage({
    super.key,
    required this.onOpenIndividuals,
    required this.onOpenEntities,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Text(l10n.selectAList, style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.md),
        DestinationCard(
          icon: Icons.person_search_outlined,
          title: l10n.individuals,
          description: l10n.unIndividualsDescription,
          onTap: onOpenIndividuals,
        ),
        const SizedBox(height: AppSpacing.md),
        DestinationCard(
          icon: Icons.business_outlined,
          title: l10n.entities,
          description: l10n.unEntitiesDescription,
          onTap: onOpenEntities,
        ),
        const SizedBox(height: AppSpacing.lg),
        NoticeBanner(message: l10n.officialSourceDisclaimer),
      ],
    );
  }
}
