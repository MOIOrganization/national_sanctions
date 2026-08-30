import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/sanctions_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/detail_fields.dart';
import '../../utils/display_names.dart';
import '../../widgets/details_section.dart';
import '../../widgets/error_state.dart';
import '../../widgets/header.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/record_profile_card.dart';

class EntityDetailsPage extends StatefulWidget {
  final int dataId;
  final Map<String, dynamic> initialEntity;

  const EntityDetailsPage({
    super.key,
    required this.dataId,
    required this.initialEntity,
  });

  @override
  State<EntityDetailsPage> createState() => _EntityDetailsPageState();
}

class _EntityDetailsPageState extends State<EntityDetailsPage> {
  final SanctionsService _service = SanctionsService();

  late Map<String, dynamic> _entity;
  bool _isRefreshing = true;
  String? _refreshError;

  static const Set<String> _handledKeys = {
    'DATAID',
    'VERSIONNUM',
    'FIRST_NAME',
    'SECOND_NAME',
    'THIRD_NAME',
    'FOURTH_NAME',
    'NAME_ORIGINAL_SCRIPT',
    'UN_LIST_TYPE',
    'REFERENCE_NUMBER',
    'COMMENTS1',
    'HAS_INTERPOL_LINK',
    'INTERPOL_LINK',
    'SOURCE_FILE_ID',
    'CREATED_DATE',
    'LAST_UPDATED_DATE',
    'ALIASES',
    'ADDRESSES',
    'ATTR_VALUES',
  };

  @override
  void initState() {
    super.initState();
    _entity = widget.initialEntity;
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });

    try {
      final Map<String, dynamic> result = await _service.getEntityById(
        dataId: widget.dataId,
        language: 'ARAB',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _entity = result;
        _isRefreshing = false;
      });
    } catch (error, stackTrace) {
      debugPrint('❌ [ENTITY DETAILS] Error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _refreshError = error.toString();
        _isRefreshing = false;
      });
    }
  }

  String get _entityName {
    return DetailFields.text(_entity['FIRST_NAME']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: AppLocalizations.of(context).entityDetails,
        showBackButton: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_entityName.isEmpty &&
        DetailFields.text(_entity['NAME_ORIGINAL_SCRIPT']).isEmpty &&
        _isRefreshing) {
      return LoadingState(
        message: AppLocalizations.of(context).loadingEntityDetails,
      );
    }

    if (_entityName.isEmpty &&
        DetailFields.text(_entity['NAME_ORIGINAL_SCRIPT']).isEmpty &&
        _refreshError != null &&
        !_isRefreshing) {
      return ErrorState(
        title: AppLocalizations.of(context).unableToLoadEntityDetails,
        onRetry: _loadFullDetails,
      );
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final names = DisplayNames.resolve(
      fallback: l10n.unnamedEntity,
      first: DetailFields.text(_entity['NAME_ORIGINAL_SCRIPT']),
      second: _entityName,
    );

    return RefreshIndicator(
      onRefresh: _loadFullDetails,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          RecordProfileCard(
            icon: Icons.business,
            primaryName: names.primary,
            secondaryName: names.secondary,
            identifier: DetailFields.text(_entity['REFERENCE_NUMBER']),
          ),
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: LinearProgressIndicator(),
            ),
          if (_refreshError != null && !_isRefreshing)
            DetailsRefreshBanner(
              message: l10n.unableToRefreshRecord,
              onRetry: _loadFullDetails,
            ),
          DetailsSectionBlock(
            title: l10n.identity,
            icon: Icons.business_outlined,
            rows: [
              DetailRow(
                label: l10n.originalScriptName,
                value: DetailFields.text(_entity['NAME_ORIGINAL_SCRIPT']),
              ),
              DetailRow(label: l10n.name, value: _entityName),
              DetailRow(
                label: l10n.secondName,
                value: DetailFields.text(_entity['SECOND_NAME']),
              ),
              DetailRow(
                label: l10n.thirdName,
                value: DetailFields.text(_entity['THIRD_NAME']),
              ),
              DetailRow(
                label: l10n.fourthName,
                value: DetailFields.text(_entity['FOURTH_NAME']),
              ),
              DetailRow(
                label: l10n.listType,
                value: DetailFields.text(_entity['UN_LIST_TYPE']),
              ),
              DetailRow(
                label: l10n.referenceNumber,
                value: DetailFields.text(_entity['REFERENCE_NUMBER']),
              ),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.aliases,
            icon: Icons.people_outline,
            rows: _aliasRows(),
          ),
          DetailsSectionBlock(
            title: l10n.addresses,
            icon: Icons.location_on_outlined,
            rows: _addressRows(),
          ),
          DetailsSectionBlock(
            title: l10n.otherDetails,
            icon: Icons.list_alt_outlined,
            rows: _attributeRows(),
          ),
          _interpolSection(),
          DetailsSectionBlock(
            title: l10n.listingInformation,
            icon: Icons.description_outlined,
            rows: [
              DetailRow(
                label: l10n.comments,
                value: DetailFields.text(_entity['COMMENTS1']),
              ),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.dates,
            icon: Icons.calendar_month_outlined,
            rows: [
              DetailRow(
                label: l10n.created,
                value: DetailFields.date(_entity['CREATED_DATE']),
              ),
              DetailRow(
                label: l10n.lastUpdated,
                value: DetailFields.date(_entity['LAST_UPDATED_DATE']),
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

  List<Widget> _aliasRows() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Map<String, dynamic>> aliases = DetailFields.mapList(
      _entity['ALIASES'],
    );
    final List<Widget> rows = [];

    for (int index = 0; index < aliases.length; index++) {
      final Map<String, dynamic> alias = aliases[index];
      final String name = DetailFields.text(alias['ALIAS_NAME']);
      final String quality = DetailFields.text(alias['QUALITY']);
      final String label = aliases.length == 1
          ? l10n.alias
          : l10n.aliasN(index + 1);

      if (name.isNotEmpty) {
        rows.add(DetailRow(label: label, value: name));
      }

      if (quality.isNotEmpty) {
        rows.add(DetailRow(label: l10n.quality, value: quality));
      }
    }

    return rows;
  }

  List<Widget> _addressRows() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Map<String, dynamic>> addresses = DetailFields.mapList(
      _entity['ADDRESSES'],
    );
    final List<Widget> rows = [];

    for (int index = 0; index < addresses.length; index++) {
      final Map<String, dynamic> address = addresses[index];
      final String value = DetailFields.joinParts([
        DetailFields.text(address['STREET']),
        DetailFields.text(address['ADDRESS']),
        DetailFields.text(address['CITY']),
        DetailFields.text(address['STATE_PROVINCE']),
        DetailFields.text(address['COUNTRY']),
        DetailFields.text(address['NOTE']),
      ]);

      if (value.isEmpty) {
        continue;
      }

      rows.add(
        DetailRow(
          label: addresses.length == 1
              ? l10n.address
              : l10n.addressN(index + 1),
          value: value,
        ),
      );
    }

    return rows;
  }

  List<Widget> _attributeRows() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Map<String, dynamic>> attributes = DetailFields.mapList(
      _entity['ATTR_VALUES'],
    );
    final List<Widget> rows = [];

    for (final Map<String, dynamic> attribute in attributes) {
      final String name = DetailFields.text(attribute['ATTR_NAME']);
      final String value = DetailFields.text(attribute['ATTR_VALUE']);

      if (value.isEmpty) {
        continue;
      }

      rows.add(
        DetailRow(label: name.isEmpty ? l10n.detail : name, value: value),
      );
    }

    return rows;
  }

  Widget _interpolSection() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String link = DetailFields.text(_entity['INTERPOL_LINK']);

    if (link.isEmpty) {
      return const SizedBox.shrink();
    }

    return DetailsSectionBlock(
      title: l10n.interpol,
      icon: Icons.public_outlined,
      rows: [
        DetailRow(
          label: l10n.interpolNotice,
          value: link,
          isLink: DetailFields.isHttpUrl(link),
          onValueTap: DetailFields.isHttpUrl(link)
              ? () => DetailFields.openExternalUrl(link)
              : null,
        ),
      ],
    );
  }

  List<Widget> _additionalRows() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Widget> rows = [];

    for (final MapEntry<String, dynamic> entry in _entity.entries) {
      if (_handledKeys.contains(entry.key) ||
          DetailFields.sequenceKeys.contains(entry.key)) {
        continue;
      }

      if (entry.value is List || entry.value is Map) {
        continue;
      }

      final String value = DetailFields.text(entry.value);

      if (value.isEmpty) {
        continue;
      }

      rows.add(
        DetailRow(label: DetailFields.humanizeKey(entry.key), value: value),
      );
    }

    rows.add(
      DetailRow(
        label: l10n.recordId,
        value: DetailFields.text(_entity['DATAID']),
      ),
    );
    rows.add(
      DetailRow(
        label: l10n.version,
        value: DetailFields.text(_entity['VERSIONNUM']),
      ),
    );

    return rows;
  }
}
