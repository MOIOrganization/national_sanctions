import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class SanctionsListShell extends StatelessWidget {
  final Widget search;
  final Widget body;

  const SanctionsListShell({
    super.key,
    required this.search,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.sm,
          ),
          child: search,
        ),
        Expanded(child: body),
      ],
    );
  }
}
