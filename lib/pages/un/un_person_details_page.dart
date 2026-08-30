import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models.dart';
import '../../services/sanctions_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/detail_fields.dart';
import '../../utils/display_names.dart';
import '../../widgets/details_section.dart';
import '../../widgets/error_state.dart';
import '../../widgets/header.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/record_profile_card.dart';

class PersonDetailsPage extends StatefulWidget {
  final int dataId;
  final Individual initialIndividual;

  const PersonDetailsPage({
    super.key,
    required this.dataId,
    required this.initialIndividual,
  });

  @override
  State<PersonDetailsPage> createState() => _PersonDetailsPageState();
}

class _PersonDetailsPageState extends State<PersonDetailsPage> {
  final SanctionsService _service = SanctionsService();

  late Individual _individual;
  bool _isRefreshing = true;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    _individual = widget.initialIndividual;
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });

    try {
      final Individual result = await _service.getIndividualById(
        dataId: widget.dataId,
        language: 'ARAB',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _individual = result;
        _isRefreshing = false;
      });
    } catch (error, stackTrace) {
      debugPrint('❌ [INDIVIDUAL DETAILS] $error');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: AppLocalizations.of(context).individualDetails,
        showBackButton: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_individual.fullName.isEmpty &&
        _individual.originalScriptName.isEmpty &&
        _isRefreshing) {
      return LoadingState(
        message: AppLocalizations.of(context).loadingIndividualDetails,
      );
    }

    if (_individual.fullName.isEmpty &&
        _individual.originalScriptName.isEmpty &&
        _refreshError != null &&
        !_isRefreshing) {
      return ErrorState(
        title: AppLocalizations.of(context).unableToLoadIndividualDetails,
        onRetry: _loadFullDetails,
      );
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final names = DisplayNames.resolve(
      fallback: l10n.unnamedIndividual,
      first: _individual.originalScriptName,
      second: _individual.fullName,
    );

    return RefreshIndicator(
      onRefresh: _loadFullDetails,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          RecordProfileCard(
            icon: Icons.person,
            primaryName: names.primary,
            secondaryName: names.secondary,
            identifier: _individual.referenceNumber,
          ),
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: LinearProgressIndicator(),
            ),
          if (_refreshError != null && !_isRefreshing)
            DetailsRefreshBanner(
              message: AppLocalizations.of(context).unableToRefreshRecord,
              onRetry: _loadFullDetails,
            ),
          DetailsSectionBlock(
            title: l10n.identity,
            icon: Icons.badge_outlined,
            rows: [
              DetailRow(
                label: l10n.originalScriptName,
                value: _individual.originalScriptName,
              ),
              DetailRow(label: l10n.firstName, value: _individual.firstName),
              DetailRow(label: l10n.secondName, value: _individual.secondName),
              DetailRow(label: l10n.thirdName, value: _individual.thirdName),
              DetailRow(label: l10n.fourthName, value: _individual.fourthName),
              DetailRow(label: l10n.listType, value: _individual.unListType),
              DetailRow(
                label: l10n.referenceNumber,
                value: _individual.referenceNumber,
              ),
              for (final String designation in _individual.designations)
                DetailRow(label: l10n.designation, value: designation),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.nationality,
            icon: Icons.flag_outlined,
            rows: [
              for (final IndividualAttribute attribute
                  in _nationalityAttributes)
                DetailRow(label: l10n.nationality, value: attribute.value),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.dateOfBirth,
            icon: Icons.cake_outlined,
            rows: [
              for (
                int index = 0;
                index < _individual.datesOfBirth.length;
                index++
              )
                ..._dateOfBirthRows(_individual.datesOfBirth[index], index),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.placeOfBirth,
            icon: Icons.location_on_outlined,
            rows: [
              for (
                int index = 0;
                index < _individual.placesOfBirth.length;
                index++
              )
                DetailRow(
                  label: _individual.placesOfBirth.length == 1
                      ? l10n.placeOfBirth
                      : l10n.placeOfBirthN(index + 1),
                  value: DetailFields.joinParts([
                    _individual.placesOfBirth[index].city,
                    _individual.placesOfBirth[index].stateProvince,
                    _individual.placesOfBirth[index].country,
                  ]),
                ),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.documents,
            icon: Icons.article_outlined,
            rows: [
              for (int index = 0; index < _individual.documents.length; index++)
                ..._documentRows(_individual.documents[index], index),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.aliases,
            icon: Icons.people_outline,
            rows: [
              for (int index = 0; index < _individual.aliases.length; index++)
                ..._aliasRows(_individual.aliases[index], index),
            ],
          ),
          DetailsSectionBlock(
            title: l10n.addresses,
            icon: Icons.home_outlined,
            rows: [
              for (int index = 0; index < _individual.addresses.length; index++)
                DetailRow(
                  label: _individual.addresses.length == 1
                      ? l10n.address
                      : l10n.addressN(index + 1),
                  value: DetailFields.joinParts([
                    _individual.addresses[index].address,
                    _individual.addresses[index].city,
                    _individual.addresses[index].stateProvince,
                    _individual.addresses[index].country,
                    _individual.addresses[index].note,
                  ]),
                ),
            ],
          ),
          _interpolSection(),
          DetailsSectionBlock(
            title: l10n.listingInformation,
            icon: Icons.description_outlined,
            rows: [
              DetailRow(label: l10n.comments, value: _individual.comments),
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

  List<IndividualAttribute> get _nationalityAttributes {
    return _individual.attributes
        .where(
          (attribute) =>
              attribute.name.toUpperCase() == 'NATIONALITY' &&
              attribute.value.trim().isNotEmpty,
        )
        .toList();
  }

  List<Widget> _dateOfBirthRows(IndividualDateOfBirth date, int index) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String label = _individual.datesOfBirth.length == 1
        ? l10n.dateOfBirth
        : l10n.dateOfBirthN(index + 1);

    return [
      DetailRow(label: label, value: date.displayValue),
      DetailRow(label: l10n.type, value: date.typeOfDate),
    ];
  }

  List<Widget> _documentRows(IndividualDocument document, int index) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String label = document.type.isNotEmpty
        ? document.type
        : (_individual.documents.length == 1
              ? l10n.document
              : l10n.documentN(index + 1));

    return [
      DetailRow(label: label, value: document.number),
      DetailRow(label: l10n.countryOfIssue, value: document.countryOfIssue),
      DetailRow(label: l10n.note, value: document.note),
    ];
  }

  List<Widget> _aliasRows(IndividualAlias alias, int index) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String label = _individual.aliases.length == 1
        ? l10n.alias
        : l10n.aliasN(index + 1);

    return [
      DetailRow(label: label, value: alias.name),
      DetailRow(label: l10n.quality, value: alias.quality),
    ];
  }

  Widget _interpolSection() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String link = _individual.interpolLink;
    final bool hasLinkFlag = _individual.hasInterpolLink.trim().isNotEmpty;

    if (link.isEmpty && !hasLinkFlag) {
      return const SizedBox.shrink();
    }

    if (DetailFields.isHttpUrl(link)) {
      return DetailsSectionBlock(
        title: l10n.interpol,
        icon: Icons.public_outlined,
        rows: [
          DetailRow(
            label: l10n.interpolNotice,
            value: link,
            isLink: true,
            onValueTap: () => DetailFields.openExternalUrl(link),
          ),
        ],
      );
    }

    if (link.isNotEmpty) {
      return DetailsSectionBlock(
        title: l10n.interpol,
        icon: Icons.public_outlined,
        rows: [DetailRow(label: l10n.interpolNotice, value: link)],
      );
    }

    return const SizedBox.shrink();
  }

  List<Widget> _additionalRows() {
    final List<Widget> rows = [];
    final Set<String> handledAttributeNames = {'NATIONALITY', 'DESIGNATION'};

    for (final IndividualAttribute attribute in _individual.attributes) {
      if (handledAttributeNames.contains(attribute.name.toUpperCase())) {
        continue;
      }

      if (attribute.value.isEmpty) {
        continue;
      }

      rows.add(
        DetailRow(
          label: attribute.name.isEmpty
              ? AppLocalizations.of(context).detail
              : attribute.name,
          value: attribute.value,
        ),
      );
    }

    const Set<String> handledRawKeys = {
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
      'DOBS',
      'POBS',
      'DOCUMENTS',
      'ATTR_VALUES',
    };

    for (final MapEntry<String, dynamic> entry in _individual.rawData.entries) {
      if (handledRawKeys.contains(entry.key) ||
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
        label: AppLocalizations.of(context).created,
        value: DetailFields.date(_individual.createdDate?.toIso8601String()),
      ),
    );
    rows.add(
      DetailRow(
        label: AppLocalizations.of(context).lastUpdated,
        value: DetailFields.date(
          _individual.lastUpdatedDate?.toIso8601String(),
        ),
      ),
    );
    rows.add(
      DetailRow(
        label: AppLocalizations.of(context).recordId,
        value: _individual.dataId.toString(),
      ),
    );

    return rows;
  }
}
