import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class DetailsSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;

  const DetailsSection({
    super.key,
    required this.title,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(title, style: AppTextStyles.heading),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;
  final VoidCallback? onValueTap;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isLink = false,
    this.onValueTap,
  });

  @override
  Widget build(BuildContext context) {
    final String trimmedValue = value.trim();

    if (trimmedValue.isEmpty || trimmedValue.toLowerCase() == 'null') {
      return const SizedBox.shrink();
    }

    final Widget valueText = SelectableText(
      trimmedValue,
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        color: isLink ? AppColors.primary : AppColors.text,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (isLink || onValueTap != null)
            GestureDetector(
              onTap: onValueTap,
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: trimmedValue));
              },
              child: valueText,
            )
          else
            valueText,
        ],
      ),
    );
  }
}

class DetailsSectionBlock extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> rows;

  const DetailsSectionBlock({
    super.key,
    required this.title,
    this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> visibleRows = rows.where((row) {
      if (row is DetailRow) {
        final String value = row.value.trim();
        return value.isNotEmpty && value.toLowerCase() != 'null';
      }

      return true;
    }).toList();

    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: DetailsSection(
        title: title,
        icon: icon,
        children: visibleRows,
      ),
    );
  }
}
