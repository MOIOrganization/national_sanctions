import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

class NationalEntityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> entity;

  const NationalEntityDetailsPage({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final String arabicName = _text(entity['ENTITY_NAME_IN_ARABIC']);

    final String englishName = _text(entity['ENTITY_NAME_IN_ENGLISH']);

    final String displayName = arabicName.isNotEmpty ? arabicName : englishName;

    return Scaffold(
      appBar: const Header(
        title: 'National Entity Details',
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
                      Icons.business,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    displayName.isEmpty ? 'Unnamed entity' : displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (englishName.isNotEmpty && englishName != displayName) ...[
                    const SizedBox(height: 6),
                    Text(
                      englishName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),

          _Section(
            title: 'Basic Information',
            icon: Icons.business_outlined,
            children: [
              _Row(label: 'ID', value: _text(entity['ID'])),
              _Row(label: 'List Serial', value: _text(entity['LS'])),
              _Row(
                label: 'Arabic Name',
                value: _text(entity['ENTITY_NAME_IN_ARABIC']),
              ),
              _Row(
                label: 'English Name',
                value: _text(entity['ENTITY_NAME_IN_ENGLISH']),
              ),
              _Row(
                label: 'Recorded Name',
                value: _text(entity['RECORDED_NAME']),
              ),
              _Row(
                label: 'Nickname / Alias',
                value: _text(entity['NICKNAME_OR_ALIAS']),
              ),
              _Row(label: 'Entity Type', value: _text(entity['ENTITY_TYPE'])),
              _Row(label: 'Legal Status', value: _text(entity['LEGAL_STATUS'])),
            ],
          ),

          _Section(
            title: 'Entity Information',
            icon: Icons.info_outline,
            children: [
              _Row(
                label: 'Description',
                value: _text(entity['ENTITY_DESCRIPTION']),
              ),
              _Row(label: 'Leadership', value: _text(entity['LEADERSHIP'])),
              _Row(label: 'Activity', value: _text(entity['ACTIVITY'])),
              _Row(
                label: 'Priority Level',
                value: _text(entity['PRIORITY_LEVEL']),
              ),
              _Row(label: 'Reasoning', value: _text(entity['REASONING'])),
              _Row(label: 'Notes', value: _text(entity['NOTES'])),
            ],
          ),

          _Section(
            title: 'Dates',
            icon: Icons.calendar_month_outlined,
            children: [
              _Row(label: 'Request Date', value: _date(entity['REQUEST_DATE'])),
              _Row(
                label: 'Classification Date',
                value: _date(entity['CLASSIFICATION_DATE']),
              ),
              _Row(
                label: 'Source Listing Date',
                value: _date(entity['SOURCE_LISTING_DATE']),
              ),
              _Row(
                label: 'Sentence Date',
                value: _date(entity['SENTESCE_DATE']),
              ),
              _Row(label: 'Created', value: _date(entity['CREATED'])),
              _Row(label: 'Updated', value: _date(entity['UPDATED'])),
            ],
          ),
        ],
      ),
    );
  }

  static String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String _date(dynamic value) {
    final String text = _text(value);

    if (text.isEmpty) return '';

    final DateTime? date = DateTime.tryParse(text);

    if (date == null) return text;

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
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
