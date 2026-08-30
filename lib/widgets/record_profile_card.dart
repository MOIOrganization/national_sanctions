import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class RecordProfileCard extends StatelessWidget {
  final IconData icon;
  final String primaryName;
  final String? secondaryName;
  final String? identifier;

  const RecordProfileCard({
    super.key,
    required this.icon,
    required this.primaryName,
    this.secondaryName,
    this.identifier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              primaryName,
              textAlign: TextAlign.center,
              style: AppTextStyles.display,
            ),
            if (secondaryName != null &&
                secondaryName!.trim().isNotEmpty &&
                secondaryName != primaryName) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                secondaryName!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
              ),
            ],
            if (identifier != null && identifier!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                identifier!,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DetailsRefreshBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DetailsRefreshBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.body,
                ),
              ),
              TextButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
