import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/notice_banner.dart';
import 'national_entities_page.dart';
import 'national_persons_page.dart';

class NationalSanctionsPage extends StatelessWidget {
  const NationalSanctionsPage({super.key});

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
          title: l10n.persons,
          description: l10n.nationalPersonsDescription,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NationalPersonsPage()),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        DestinationCard(
          icon: Icons.business_outlined,
          title: l10n.entities,
          description: l10n.nationalEntitiesDescription,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NationalEntitiesPage()),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        NoticeBanner(message: l10n.officialSourceDisclaimer),
      ],
    );
  }
}
