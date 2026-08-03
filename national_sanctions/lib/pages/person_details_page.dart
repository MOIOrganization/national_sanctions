import 'package:flutter/material.dart';

import '../models.dart';
import '../theme/app_colors.dart';
import '../widgets/header.dart';

class PersonDetailsPage extends StatelessWidget {
  final Individual individual;

  const PersonDetailsPage({super.key, required this.individual});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Individual Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            individual.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('Reference: ${individual.referenceNumber}'),
          Text('List type: ${individual.unListType}'),
          Text('Nationality: ${individual.nationality}'),
          const SizedBox(height: 16),
          if (individual.comments.isNotEmpty) ...[
            const Text(
              'Comments',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(individual.comments),
          ],
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _DetailsRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
