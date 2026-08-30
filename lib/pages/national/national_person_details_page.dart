import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/display_names.dart';
import '../../widgets/details_section.dart';
import '../../widgets/header.dart';

class NationalPersonDetailsPage extends StatelessWidget {
  final Map<String, dynamic> person;

  const NationalPersonDetailsPage({super.key, required this.person});

  static const Set<String> _handledKeys = {
    'ID',
    'LS',
    'PERSON_NAME_IN_ARABIC',
    'NAME_IN_ARABIC',
    'FULL_NAME_ARABIC',
    'PERSON_NAME_IN_ENGLISH',
    'NAME_IN_ENGLISH',
    'FULL_NAME_ENGLISH',
    'RECORDED_NAME',
    'FIRST_NAME',
    'SECOND_NAME',
    'THIRD_NAME',
    'FOURTH_NAME',
    'NATIONALITY',
    'NATIONALITY_IN_ARABIC',
    'NATIONALITY_IN_ENGLISH',
    'DATE_OF_BIRTH',
    'DOB',
    'BIRTH_DATE',
    'PLACE_OF_BIRTH',
    'POB',
    'CITY_OF_BIRTH',
    'COUNTRY_OF_BIRTH',
    'GENDER',
    'SEX',
    'PASSPORT',
    'PASSPORT_NUMBER',
    'NATIONAL_ID',
    'NATIONAL_ID_NUMBER',
    'CPR',
    'CPR_NUMBER',
    'IDENTITY_NUMBER',
    'DOCUMENT_NUMBER',
    'NICKNAME_OR_ALIAS',
    'ALIAS',
    'ALIASES',
    'ALSO_KNOWN_AS',
    'PRIORITY_LEVEL',
    'REASONING',
    'NOTES',
    'DESCRIPTION',
    'PERSON_DESCRIPTION',
    'REQUEST_DATE',
    'CLASSIFICATION_DATE',
    'SOURCE_LISTING_DATE',
    'SENTESCE_DATE',
    'SENTENCE_DATE',
    'CREATED',
    'UPDATED',
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String arabicName = _first([
      person['PERSON_NAME_IN_ARABIC'],
      person['NAME_IN_ARABIC'],
      person['FULL_NAME_ARABIC'],
    ]);
    final String englishName = _first([
      person['PERSON_NAME_IN_ENGLISH'],
      person['NAME_IN_ENGLISH'],
      person['FULL_NAME_ENGLISH'],
    ]);
    final names = DisplayNames.resolve(
      fallback: l10n.unnamedPerson,
      first: arabicName,
      second: englishName.isNotEmpty
          ? englishName
          : _first([person['RECORDED_NAME'], person['FIRST_NAME']]),
    );

    return Scaffold(
      appBar: Header(title: l10n.nationalPersonDetails, showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          _buildProfileCard(names.primary, names.secondary),
          _section(
            title: l10n.identity,
            icon: Icons.badge_outlined,
            rows: [
              DetailRow(label: l10n.arabicName, value: arabicName),
              DetailRow(label: l10n.englishName, value: englishName),
              DetailRow(
                label: l10n.recordedName,
                value: _text(person['RECORDED_NAME']),
              ),
              DetailRow(label: l10n.id, value: _text(person['ID'])),
              DetailRow(label: l10n.listSerial, value: _text(person['LS'])),
              DetailRow(
                label: l10n.nationality,
                value: _first([
                  person['NATIONALITY'],
                  person['NATIONALITY_IN_ARABIC'],
                  person['NATIONALITY_IN_ENGLISH'],
                ]),
              ),
              DetailRow(
                label: l10n.dateOfBirth,
                value: _date(
                  _first([
                    person['DATE_OF_BIRTH'],
                    person['DOB'],
                    person['BIRTH_DATE'],
                  ]),
                ),
              ),
              DetailRow(
                label: l10n.placeOfBirth,
                value: _first([
                  person['PLACE_OF_BIRTH'],
                  person['POB'],
                  person['CITY_OF_BIRTH'],
                  person['COUNTRY_OF_BIRTH'],
                ]),
              ),
              DetailRow(
                label: l10n.gender,
                value: _first([person['GENDER'], person['SEX']]),
              ),
              DetailRow(
                label: l10n.firstName,
                value: _text(person['FIRST_NAME']),
              ),
              DetailRow(
                label: l10n.secondName,
                value: _text(person['SECOND_NAME']),
              ),
              DetailRow(
                label: l10n.thirdName,
                value: _text(person['THIRD_NAME']),
              ),
              DetailRow(
                label: l10n.fourthName,
                value: _text(person['FOURTH_NAME']),
              ),
            ],
          ),
          _section(
            title: l10n.identification,
            icon: Icons.fingerprint_outlined,
            rows: [
              DetailRow(
                label: l10n.passport,
                value: _first([person['PASSPORT'], person['PASSPORT_NUMBER']]),
              ),
              DetailRow(
                label: l10n.nationalId,
                value: _first([
                  person['NATIONAL_ID'],
                  person['NATIONAL_ID_NUMBER'],
                  person['IDENTITY_NUMBER'],
                ]),
              ),
              DetailRow(
                label: l10n.cpr,
                value: _first([person['CPR'], person['CPR_NUMBER']]),
              ),
              DetailRow(
                label: l10n.documentNumber,
                value: _text(person['DOCUMENT_NUMBER']),
              ),
            ],
          ),
          _section(
            title: l10n.aliases,
            icon: Icons.people_outline,
            rows: [
              DetailRow(
                label: l10n.nicknameAlias,
                value: _text(person['NICKNAME_OR_ALIAS']),
              ),
              DetailRow(label: l10n.alias, value: _text(person['ALIAS'])),
              DetailRow(
                label: l10n.alsoKnownAs,
                value: _text(person['ALSO_KNOWN_AS']),
              ),
              ..._aliasRows(person['ALIASES'], l10n),
            ],
          ),
          _section(
            title: l10n.listingInformation,
            icon: Icons.info_outline,
            rows: [
              DetailRow(
                label: l10n.priorityLevel,
                value: _text(person['PRIORITY_LEVEL']),
              ),
              DetailRow(
                label: l10n.reasoning,
                value: _text(person['REASONING']),
              ),
              DetailRow(label: l10n.notes, value: _text(person['NOTES'])),
              DetailRow(
                label: l10n.description,
                value: _first([
                  person['DESCRIPTION'],
                  person['PERSON_DESCRIPTION'],
                ]),
              ),
            ],
          ),
          _section(
            title: l10n.dates,
            icon: Icons.calendar_month_outlined,
            rows: [
              DetailRow(
                label: l10n.requestDate,
                value: _date(person['REQUEST_DATE']),
              ),
              DetailRow(
                label: l10n.classificationDate,
                value: _date(person['CLASSIFICATION_DATE']),
              ),
              DetailRow(
                label: l10n.sourceListingDate,
                value: _date(person['SOURCE_LISTING_DATE']),
              ),
              DetailRow(
                label: l10n.sentenceDate,
                value: _date(
                  _first([person['SENTENCE_DATE'], person['SENTESCE_DATE']]),
                ),
              ),
              DetailRow(label: l10n.created, value: _date(person['CREATED'])),
              DetailRow(label: l10n.updated, value: _date(person['UPDATED'])),
            ],
          ),
          _section(
            title: l10n.additionalInformation,
            icon: Icons.more_horiz,
            rows: _additionalRows(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String primaryName, String? secondaryName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              primaryName,
              textAlign: TextAlign.center,
              style: AppTextStyles.display,
            ),
            if (secondaryName != null && secondaryName.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                secondaryName,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
              ),
            ],
            if (_text(person['ID']).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(person['ID'].toString(), style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> rows,
  }) {
    final List<Widget> visibleRows = rows.where((row) {
      if (row is DetailRow) {
        final String value = row.value.trim();
        return value.isNotEmpty && value.toLowerCase() != 'null';
      }
      return true;
    }).toList();

    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: DetailsSection(title: title, icon: icon, children: visibleRows),
    );
  }

  List<Widget> _aliasRows(dynamic rawAliases, AppLocalizations l10n) {
    if (rawAliases is! List || rawAliases.isEmpty) {
      return const [];
    }

    final List<Widget> rows = [];

    for (int index = 0; index < rawAliases.length; index++) {
      final dynamic item = rawAliases[index];

      if (item is Map) {
        final String name = _first([
          item['ALIAS_NAME'],
          item['NAME'],
          item['NICKNAME'],
          item['VALUE'],
        ]);

        if (name.isNotEmpty) {
          rows.add(DetailRow(label: l10n.aliasN(index + 1), value: name));
        }
        continue;
      }

      final String text = _text(item);

      if (text.isNotEmpty) {
        rows.add(DetailRow(label: l10n.aliasN(index + 1), value: text));
      }
    }

    return rows;
  }

  List<Widget> _additionalRows() {
    final List<Widget> rows = [];

    for (final MapEntry<String, dynamic> entry in person.entries) {
      if (_handledKeys.contains(entry.key)) {
        continue;
      }

      final String value = _formatUnknown(entry.value);

      if (value.isEmpty) {
        continue;
      }

      rows.add(DetailRow(label: _humanizeKey(entry.key), value: value));
    }

    return rows;
  }

  static String _first(List<dynamic> values) {
    for (final dynamic value in values) {
      final String text = _text(value);

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  static String _text(dynamic value) {
    if (value == null) {
      return '';
    }

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }

  static String _date(dynamic value) {
    final String text = _text(value);

    if (text.isEmpty) {
      return '';
    }

    final DateTime? date = DateTime.tryParse(text);

    if (date == null) {
      return text;
    }

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  static String _formatUnknown(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is List) {
      final List<String> parts = value
          .map(_formatUnknown)
          .where((item) => item.isNotEmpty)
          .toList();

      return parts.join('\n');
    }

    if (value is Map) {
      final List<String> parts = [];

      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        final String nested = _formatUnknown(entry.value);

        if (nested.isEmpty) {
          continue;
        }

        parts.add('${_humanizeKey(entry.key.toString())}: $nested');
      }

      return parts.join('\n');
    }

    return _date(value);
  }

  static String _humanizeKey(String key) {
    const Map<String, String> labels = {
      'CREATED_BY': 'Created by',
      'UPDATED_BY': 'Updated by',
      'NEED_FEEDBACK': 'Needs feedback',
      'INDIVIDUAL_OR_ENTITY': 'Record type',
      'REQ_ENTITY': 'Requesting entity',
    };

    final String mapped = labels[key] ?? '';

    if (mapped.isNotEmpty) {
      return mapped;
    }

    return key
        .toLowerCase()
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
