import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // =========================================================
        // HEADER
        // =========================================================
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.policy_outlined,
                color: Colors.white,
                size: 42,
              ),
              SizedBox(height: 18),
              Text(
                'Sanctions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Search and review sanctions information.',
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // =========================================================
        // TITLE
        // =========================================================
        const Text(
          'Select Sanctions List',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        // =========================================================
        // UNITED NATIONS
        // =========================================================
        _SanctionsOptionCard(
          icon: Icons.public,
          title: 'United Nations Sanctions',
          description:
              'Search individuals and entities included in the official United Nations sanctions lists.',
          onTap: onOpenUnitedNations,
        ),

        const SizedBox(height: 14),

        // =========================================================
        // NATIONAL SANCTIONS
        // =========================================================
        _SanctionsOptionCard(
          icon: Icons.account_balance_outlined,
          title: 'National Sanctions',
          description:
              'View individuals and entities included in national sanctions lists.',
          onTap: onOpenNationalSanctions,
        ),

        const SizedBox(height: 20),

        // =========================================================
        // INFORMATION
        // =========================================================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE9D8A6),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.secondary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Information should always be verified against the official source before making a legal or compliance decision.',
                  style: TextStyle(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// SANCTIONS OPTION CARD
// ===============================================================

class _SanctionsOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _SanctionsOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios,
                size: 17,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}