import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenSanctions;

  const HomePage({super.key, required this.onOpenSanctions});

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
              Icon(Icons.policy_outlined, color: Colors.white, size: 42),
              SizedBox(height: 18),
              Text(
                'National Sanctions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Search individuals and entities included in official sanctions lists.',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quick Access',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onOpenSanctions,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE8EEF5),
                    child: Icon(Icons.person_search, color: AppColors.primary),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Sanctions List',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Search by name, nationality or reference number.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 17),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9D8A6)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.secondary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Information should always be verified against the official source before making a legal or compliance decision.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
