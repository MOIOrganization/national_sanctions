import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'directional_chevron.dart';

class SanctionsListRow extends StatelessWidget {
  final IconData leadingIcon;
  final String primaryName;
  final String? secondaryName;
  final String? identifier;
  final List<String> chips;
  final List<String> metadata;
  final VoidCallback? onTap;

  const SanctionsListRow({
    super.key,
    this.leadingIcon = Icons.person_outline,
    required this.primaryName,
    this.secondaryName,
    this.identifier,
    this.chips = const [],
    this.metadata = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> visibleChips = chips
        .map((chip) => chip.trim())
        .where((chip) => chip.isNotEmpty)
        .take(2)
        .toList();

    final List<String> visibleMetadata = metadata
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Card(
      child: InkWell(
        borderRadius: AppRadius.border,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.border,
                ),
                child: Icon(
                  leadingIcon,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryName,
                      style: AppTextStyles.subheading,
                    ),
                    if (secondaryName != null &&
                        secondaryName!.trim().isNotEmpty &&
                        secondaryName!.trim() != primaryName) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        secondaryName!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    if (identifier != null && identifier!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        identifier!,
                        style: AppTextStyles.caption,
                      ),
                    ],
                    if (visibleChips.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final String chip in visibleChips)
                            _SanctionsChip(label: chip),
                        ],
                      ),
                    ],
                    for (final String item in visibleMetadata) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(item, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: DirectionalChevron(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SanctionsChip extends StatelessWidget {
  final String label;

  const _SanctionsChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.border,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
