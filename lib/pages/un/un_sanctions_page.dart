import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.public, color: Colors.white, size: 42),
              SizedBox(height: 18),
              Text(
                'United Nations Sanctions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Search individuals and entities included in official United Nations sanctions lists.',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Search',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 14),

        _SanctionsCard(
          icon: Icons.person_search_outlined,
          title: 'Individuals',
          description:
              'Search individuals by ID, name, nationality or reference number.',
          onTap: onOpenIndividuals,
        ),

        const SizedBox(height: 12),

        _SanctionsCard(
          icon: Icons.business_outlined,
          title: 'Entities',
          description:
              'Search companies, organisations and other listed entities.',
          onTap: onOpenEntities,
        ),
      ],
    );
  }
}

class _SanctionsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _SanctionsCard({
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
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFE8EEF5),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
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
              const Icon(Icons.arrow_forward_ios, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}
