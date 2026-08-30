import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class AppNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.public_outlined),
          selectedIcon: const Icon(Icons.public),
          label: l10n.un,
        ),
        NavigationDestination(
          icon: const Icon(Icons.account_balance_outlined),
          selectedIcon: const Icon(Icons.account_balance),
          label: l10n.national,
        ),
      ],
    );
  }
}
