import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../utils/detail_fields.dart';
import '../../utils/display_names.dart';
import '../../widgets/details_section.dart';
import '../../widgets/header.dart';
import '../../widgets/record_profile_card.dart';

class NationalEntityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> entity;

  const NationalEntityDetailsPage({super.key, required this.entity});

  static const Set<String> _handledKeys = {
    'ID',
    'LS',
    'ENTITY_NAME_IN_ARABIC',
    'ENTITY_NAME_IN_ENGLISH',
    'RECORDED_NAME',
    'NICKNAME_OR_ALIAS',
    'ALIAS',
    'ALIASES',
    'ALSO_KNOWN_AS',
    'ENTITY_TYPE',
    'LEGAL_STATUS',
    'ENTITY_DESCRIPTION',
    'LEADERSHIP',
    'ACTIVITY',
    'PRIORITY_LEVEL',
    'REASONING',
    'NOTES',
    'REQUEST_DATE',
    'CLASSIFICATION_DATE',
    'SOURCE_LISTING_DATE',
    'SENTESCE_DATE',
    'SENTENCE_DATE',
    'CREATED',
    'CREATED_BY',
    'UPDATED',
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String arabicName = DetailFields.text(
      entity['ENTITY_NAME_IN_ARABIC'],
    );
    final String englishName = DetailFields.text(
      entity['ENTITY_NAME_IN_ENGLISH'],
    );
    final names = DisplayNames.resolve(
      fallback: l10n.unnamedEntity,
      first: arabicName,
      second: englishName.isNotEmpty
          ? englishName
          : DetailFields.text(entity['RECORDED_NAME']),
    );

    return Scaffold(
      appBar: Header(title: l10n.nationalEntityDetails, showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          RecordProfileCard(
            icon: Icons.business,
            primaryName: names.primary,
            secondaryName: names.secondary,
            identifier: DetailFields.text(entity['ID']),
          ),
          DetailsSectionBlock(
            title: l10n.identity,
            icon: Icons.business_outlined,
            rows: [
              DetailRow(label: l10n.arabicName, value: arabicName),
              DetailRow(label: l10n.englishName, value: englishName),
              DetailRow(
                label: l10n.recordedName,
                value: DetailFields.text(entity['RECORDED_NAME']),
              ),
              DetailRow(label: l10n.id, value: DetailFields.text(entity['ID'])),
              DetailRow(
                label: l10n.listSerial,
                value: DetailFields.text(entity['LS']),
              ),
              DetailRow(
                label: l10n.entityType,
                value: DetailFields.text(entity['ENTITY_TYPE']),
              ),
              DetailRow(
                label: l10n.legalStatus,
                value: DetailFields.text(entity['LEGAL_STATUS']),
              ),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.aliases,
            icon: Icons.people_outline,
            rows: [
              DetailRow(
                label: l10n.nicknameAlias,
                value: DetailFields.text(entity['NICKNAME_OR_ALIAS']),
              ),
              DetailRow(
                label: l10n.alias,
                value: DetailFields.text(entity['ALIAS']),
              ),
              DetailRow(
                label: l10n.alsoKnownAs,
                value: DetailFields.text(entity['ALSO_KNOWN_AS']),
              ),
              ..._aliasRows(entity['ALIASES'], l10n),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.listingInformation,
            icon: Icons.info_outline,
            rows: [
              DetailRow(
                label: l10n.description,
                value: DetailFields.text(entity['ENTITY_DESCRIPTION']),
              ),
              DetailRow(
                label: l10n.leadership,
                value: DetailFields.text(entity['LEADERSHIP']),
              ),
              DetailRow(
                label: l10n.activity,
                value: DetailFields.text(entity['ACTIVITY']),
              ),
              DetailRow(
                label: l10n.priorityLevel,
                value: DetailFields.text(entity['PRIORITY_LEVEL']),
              ),
              DetailRow(
                label: l10n.reasoning,
                value: DetailFields.text(entity['REASONING']),
              ),
              DetailRow(
                label: l10n.notes,
                value: DetailFields.text(entity['NOTES']),
              ),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.dates,
            icon: Icons.calendar_month_outlined,
            rows: [
              DetailRow(
                label: l10n.requestDate,
                value: DetailFields.date(entity['REQUEST_DATE']),
              ),
              DetailRow(
                label: l10n.classificationDate,
                value: DetailFields.date(entity['CLASSIFICATION_DATE']),
              ),
              DetailRow(
                label: l10n.sourceListingDate,
                value: DetailFields.date(entity['SOURCE_LISTING_DATE']),
              ),
              DetailRow(
                label: l10n.sentenceDate,
                value: DetailFields.date(
                  DetailFields.text(entity['SENTENCE_DATE']).isNotEmpty
                      ? entity['SENTENCE_DATE']
                      : entity['SENTESCE_DATE'],
                ),
              ),
              DetailRow(
                label: l10n.created,
                value: DetailFields.date(entity['CREATED']),
              ),
              DetailRow(
                label: l10n.updated,
                value: DetailFields.date(entity['UPDATED']),
              ),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.additionalInformation,
            icon: Icons.more_horiz,
            rows: _additionalRows(),
          ),
        ],
      ),
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
        final String name = [
          DetailFields.text(item['ALIAS_NAME']),
          DetailFields.text(item['NAME']),
          DetailFields.text(item['NICKNAME']),
          DetailFields.text(item['VALUE']),
        ].firstWhere((value) => value.isNotEmpty, orElse: () => '');

        if (name.isNotEmpty) {
          rows.add(DetailRow(label: l10n.aliasN(index + 1), value: name));
        }
        continue;
      }

      final String text = DetailFields.text(item);

      if (text.isNotEmpty) {
        rows.add(DetailRow(label: l10n.aliasN(index + 1), value: text));
      }
    }

    return rows;
  }

  List<Widget> _additionalRows() {
    final List<Widget> rows = [];

    for (final MapEntry<String, dynamic> entry in entity.entries) {
      if (_handledKeys.contains(entry.key) ||
          DetailFields.sequenceKeys.contains(entry.key)) {
        continue;
      }

      final String value = _formatUnknown(entry.value);

      if (value.isEmpty) {
        continue;
      }

      rows.add(
        DetailRow(label: DetailFields.humanizeKey(entry.key), value: value),
      );
    }

    return rows;
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
        if (DetailFields.sequenceKeys.contains(entry.key.toString())) {
          continue;
        }

        final String nested = _formatUnknown(entry.value);

        if (nested.isEmpty) {
          continue;
        }

        parts.add('${DetailFields.humanizeKey(entry.key.toString())}: $nested');
      }

      return parts.join('\n');
    }

    return DetailFields.date(value);
  }
}
