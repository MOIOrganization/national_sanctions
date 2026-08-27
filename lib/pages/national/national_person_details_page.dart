import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class NationalPersonDetailsPage extends StatelessWidget {
  final Map<String, dynamic> person;

  const NationalPersonDetailsPage({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final String name = _findPersonName(person);

    return Scaffold(
      appBar: const Header(
        title: 'National Person Details',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (_text(person['ID']).isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      'ID: ${person['ID']}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_outlined, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        'Person Information',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ..._buildFields(person),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildFields(Map<String, dynamic> data) {
    final List<Widget> rows = [];

    for (final entry in data.entries) {
      final dynamic value = entry.value;

      if (value == null) continue;

      if (value is List || value is Map) {
        continue;
      }

      final String text = value.toString().trim();

      if (text.isEmpty || text.toLowerCase() == 'null') {
        continue;
      }

      rows.add(
        _PersonRow(label: _formatKey(entry.key), value: _formatValue(text)),
      );
    }

    return rows;
  }

  static String _findPersonName(Map<String, dynamic> person) {
    final values = [
      person['PERSON_NAME_IN_ARABIC'],
      person['NAME_IN_ARABIC'],
      person['FULL_NAME_ARABIC'],
      person['PERSON_NAME_IN_ENGLISH'],
      person['NAME_IN_ENGLISH'],
      person['FULL_NAME_ENGLISH'],
      person['RECORDED_NAME'],
      person['FIRST_NAME'],
    ];

    for (final value in values) {
      final text = _text(value);

      if (text.isNotEmpty) {
        return text;
      }
    }

    return 'Unnamed person';
  }

  static String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String _formatKey(String key) {
    return key
        .toLowerCase()
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}'
                    '${word.substring(1)}',
        )
        .join(' ');
  }

  static String _formatValue(String value) {
    final DateTime? date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _PersonRow extends StatelessWidget {
  final String label;
  final String value;

  const _PersonRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
