import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'national_persons_page.dart';
import 'national_entities_page.dart';

class NationalSanctionsPage extends StatelessWidget {
  const NationalSanctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // ============================================================
        // HEADER CARD
        // ============================================================
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
                Icons.account_balance_outlined,
                color: Colors.white,
                size: 42,
              ),
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
                'Search persons and entities included in the national sanctions list.',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ============================================================
        // TITLE
        // ============================================================
        const Text(
          'Search National List',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // ============================================================
        // PERSONS
        // ============================================================
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NationalPersonsPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE8EEF5),
                    child: Icon(
                      Icons.person_search_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Persons',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Search persons included in the national sanctions list.',
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

        const SizedBox(height: 12),

        // ============================================================
        // ENTITIES
        // ============================================================
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NationalEntitiesPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE8EEF5),
                    child: Icon(
                      Icons.business_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Search entities included in the national sanctions list.',
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

        const SizedBox(height: 18),

        // ============================================================
        // INFORMATION
        // ============================================================
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
                  'Select persons or entities to search the national sanctions records.',
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
