import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/sanctions_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';

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

  Individual? _individual;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _individual = widget.initialIndividual;
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Individual result = await _service.getIndividualById(
        dataId: widget.dataId,
        language: 'ARAB',
      );

      if (!mounted) return;

      setState(() {
        _individual = result;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('❌ [INDIVIDUAL DETAILS] $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Individual Details', showBackButton: true),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Loading full individual details...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
                color: AppColors.warning,
              ),
              const SizedBox(height: 14),
              const Text(
                'Unable to load full details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loadFullDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final Individual individual = _individual!;
    final Map<String, dynamic> data = individual.rawData;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileCard(individual),
        const SizedBox(height: 14),

        _DetailsSection(
          title: 'Basic information',
          icon: Icons.badge_outlined,
          children: [
            _DetailRow(label: 'Data ID', value: _value(data['DATAID'])),
            _DetailRow(label: 'Version', value: _value(data['VERSIONNUM'])),
            _DetailRow(label: 'First name', value: _value(data['FIRST_NAME'])),
            _DetailRow(
              label: 'Second name',
              value: _value(data['SECOND_NAME']),
            ),
            _DetailRow(label: 'Third name', value: _value(data['THIRD_NAME'])),
            _DetailRow(
              label: 'Fourth name',
              value: _value(data['FOURTH_NAME']),
            ),
            _DetailRow(
              label: 'Original-script name',
              value: _value(data['NAME_ORIGINAL_SCRIPT']),
            ),
            _DetailRow(
              label: 'UN list type',
              value: _value(data['UN_LIST_TYPE']),
            ),
            _DetailRow(
              label: 'Reference number',
              value: _value(data['REFERENCE_NUMBER']),
            ),
            _DetailRow(
              label: 'Source file ID',
              value: _value(data['SOURCE_FILE_ID']),
            ),
            _DetailRow(
              label: 'Created date',
              value: _value(data['CREATED_DATE']),
            ),
            _DetailRow(
              label: 'Last updated date',
              value: _value(data['LAST_UPDATED_DATE']),
              showDivider: false,
            ),
          ],
        ),

        _buildAttributes(data['ATTR_VALUES']),
        _buildAliases(data['ALIASES']),
        _buildDatesOfBirth(data['DOBS']),
        _buildPlacesOfBirth(data['POBS']),
        _buildAddresses(data['ADDRESSES']),
        _buildDocuments(data['DOCUMENTS']),
        _buildInterpol(data),

        if (_hasValue(data['COMMENTS1']))
          _DetailsSection(
            title: 'Comments and listing information',
            icon: Icons.description_outlined,
            children: [
              Text(
                _value(data['COMMENTS1']),
                style: const TextStyle(
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProfileCard(Individual individual) {
    return Card(
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
              individual.fullName.isEmpty
                  ? 'Unnamed individual'
                  : individual.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (individual.originalScriptName.isNotEmpty &&
                individual.originalScriptName != individual.fullName) ...[
              const SizedBox(height: 6),
              Text(
                individual.originalScriptName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              individual.referenceNumber,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAliases(dynamic rawAliases) {
    final aliases = _mapList(rawAliases);

    if (aliases.isEmpty) return const SizedBox.shrink();

    return _DetailsSection(
      title: 'Aliases',
      icon: Icons.people_outline,
      children: [
        for (int index = 0; index < aliases.length; index++)
          _NestedCard(
            title: 'Alias ${index + 1}',
            rows: {
              'Sequence': aliases[index]['ALIAS_SEQ'],
              'Quality': aliases[index]['QUALITY'],
              'Alias name': aliases[index]['ALIAS_NAME'],
            },
          ),
      ],
    );
  }

  Widget _buildDatesOfBirth(dynamic rawDates) {
    final dates = _mapList(rawDates);

    if (dates.isEmpty) return const SizedBox.shrink();

    return _DetailsSection(
      title: 'Dates of birth',
      icon: Icons.cake_outlined,
      children: [
        for (int index = 0; index < dates.length; index++)
          _NestedCard(title: 'Date of birth ${index + 1}', rows: dates[index]),
      ],
    );
  }

  Widget _buildPlacesOfBirth(dynamic rawPlaces) {
    final places = _mapList(rawPlaces);

    if (places.isEmpty) return const SizedBox.shrink();

    return _DetailsSection(
      title: 'Places of birth',
      icon: Icons.location_on_outlined,
      children: [
        for (int index = 0; index < places.length; index++)
          _NestedCard(
            title: 'Place of birth ${index + 1}',
            rows: places[index],
          ),
      ],
    );
  }

  Widget _buildAddresses(dynamic rawAddresses) {
    final addresses = _mapList(rawAddresses);

    final usefulAddresses = addresses.where((address) {
      return address.entries.any(
        (entry) => entry.key != 'ADDR_SEQ' && _hasValue(entry.value),
      );
    }).toList();

    if (usefulAddresses.isEmpty) {
      return const SizedBox.shrink();
    }

    return _DetailsSection(
      title: 'Addresses',
      icon: Icons.home_outlined,
      children: [
        for (int index = 0; index < usefulAddresses.length; index++)
          _NestedCard(
            title: 'Address ${index + 1}',
            rows: usefulAddresses[index],
          ),
      ],
    );
  }

  Widget _buildDocuments(dynamic rawDocuments) {
    final documents = _mapList(rawDocuments);

    if (documents.isEmpty) return const SizedBox.shrink();

    return _DetailsSection(
      title: 'Documents',
      icon: Icons.article_outlined,
      children: [
        for (int index = 0; index < documents.length; index++)
          _NestedCard(title: 'Document ${index + 1}', rows: documents[index]),
      ],
    );
  }

  Widget _buildAttributes(dynamic rawAttributes) {
    final attributes = _mapList(rawAttributes);

    if (attributes.isEmpty) return const SizedBox.shrink();

    return _DetailsSection(
      title: 'Attributes',
      icon: Icons.list_alt_outlined,
      children: [
        for (int index = 0; index < attributes.length; index++)
          _NestedCard(
            title: _value(attributes[index]['ATTR_NAME']) == 'Not specified'
                ? 'Attribute ${index + 1}'
                : _value(attributes[index]['ATTR_NAME']),
            rows: {
              'Sequence': attributes[index]['VALUE_SEQ'],
              'Value': attributes[index]['ATTR_VALUE'],
            },
          ),
      ],
    );
  }

  Widget _buildInterpol(Map<String, dynamic> data) {
    if (!_hasValue(data['HAS_INTERPOL_LINK']) &&
        !_hasValue(data['INTERPOL_LINK'])) {
      return const SizedBox.shrink();
    }

    return _DetailsSection(
      title: 'Interpol information',
      icon: Icons.public_outlined,
      children: [
        _DetailRow(
          label: 'Has Interpol link',
          value: _value(data['HAS_INTERPOL_LINK']),
        ),
        _DetailRow(
          label: 'Interpol link',
          value: _value(data['INTERPOL_LINK']),
          showDivider: false,
        ),
      ],
    );
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static bool _hasValue(dynamic value) {
    if (value == null) return false;

    final text = value.toString().trim();

    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  static String _value(dynamic value) {
    if (!_hasValue(value)) return 'Not specified';

    return value.toString().trim();
  }
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailsSection({
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    if (value == 'Not specified') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
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

class _NestedCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> rows;

  const _NestedCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final usefulRows = rows.entries.where((entry) {
      if (entry.value == null) return false;

      final value = entry.value.toString().trim();

      return value.isNotEmpty && value.toLowerCase() != 'null';
    }).toList();

    if (usefulRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          for (final entry in usefulRows)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      _formatKey(entry.key),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _formatKey(String key) {
    return key
        .toLowerCase()
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
