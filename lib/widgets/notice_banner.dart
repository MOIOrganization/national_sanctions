import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class NoticeBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const NoticeBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.noticeBackground,
        borderRadius: AppRadius.border,
        border: Border.all(color: AppColors.noticeBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}
