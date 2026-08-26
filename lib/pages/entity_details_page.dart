import 'package:flutter/material.dart';

import '../services/sanctions_service.dart';
import '../theme/app_colors.dart';
import '../widgets/header.dart';

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

  Map<String, dynamic>? _entity;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _entity = widget.initialEntity;
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> result = await _service.getEntityById(
        dataId: widget.dataId,
        language: 'ARAB',
      );

      if (!mounted) return;

      setState(() {
        _entity = result;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('❌ [ENTITY DETAILS] Error: $error');
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
      appBar: const Header(title: 'Entity Details', showBackButton: true),
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
            Text('Loading full entity details...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 54,
                color: AppColors.warning,
              ),
              const SizedBox(height: 14),
              const Text(
                'Unable to load entity details',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SelectableText(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
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

    final Map<String, dynamic> entity = _entity!;

    final String name = _value(
      entity['FIRST_NAME'],
      fallback: 'Unnamed entity',
    );

    return RefreshIndicator(
      onRefresh: _loadFullDetails,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(entity, name),
          const SizedBox(height: 14),

          _EntityDetailsSection(
            title: 'Basic information',
            icon: Icons.business_outlined,
            children: [
              _EntityDetailRow(
                label: 'Data ID',
                value: _value(entity['DATAID']),
              ),
              _EntityDetailRow(
                label: 'Version number',
                value: _value(entity['VERSIONNUM']),
              ),
              _EntityDetailRow(
                label: 'Entity name',
                value: _value(entity['FIRST_NAME']),
              ),
              _EntityDetailRow(
                label: 'Second name',
                value: _value(entity['SECOND_NAME']),
              ),
              _EntityDetailRow(
                label: 'Third name',
                value: _value(entity['THIRD_NAME']),
              ),
              _EntityDetailRow(
                label: 'Fourth name',
                value: _value(entity['FOURTH_NAME']),
              ),
              _EntityDetailRow(
                label: 'Original-script name',
                value: _value(entity['NAME_ORIGINAL_SCRIPT']),
              ),
              _EntityDetailRow(
                label: 'UN list type',
                value: _value(entity['UN_LIST_TYPE']),
              ),
              _EntityDetailRow(
                label: 'Reference number',
                value: _value(entity['REFERENCE_NUMBER']),
              ),
              _EntityDetailRow(
                label: 'Source file ID',
                value: _value(entity['SOURCE_FILE_ID']),
              ),
              _EntityDetailRow(
                label: 'Created date',
                value: _value(entity['CREATED_DATE']),
              ),
              _EntityDetailRow(
                label: 'Last updated date',
                value: _value(entity['LAST_UPDATED_DATE']),
                showDivider: false,
              ),
            ],
          ),

          _buildAliases(entity),
          _buildAddresses(entity),
          _buildAttributes(entity),
          _buildInterpolInformation(entity),

          if (_hasValue(entity['COMMENTS1']))
            _EntityDetailsSection(
              title: 'Comments and listing information',
              icon: Icons.description_outlined,
              children: [
                SelectableText(
                  _value(entity['COMMENTS1']),
                  style: const TextStyle(
                    height: 1.7,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

          _buildAdditionalFields(entity),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> entity, String name) {
    return Card(
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
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (_hasValue(entity['REFERENCE_NUMBER'])) ...[
              const SizedBox(height: 7),
              Text(
                _value(entity['REFERENCE_NUMBER']),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAliases(Map<String, dynamic> entity) {
    final List<Map<String, dynamic>> aliases = _convertList(entity['ALIASES']);

    if (aliases.isEmpty) {
      return const SizedBox.shrink();
    }

    return _EntityDetailsSection(
      title: 'Aliases',
      icon: Icons.people_outline,
      children: [
        for (int index = 0; index < aliases.length; index++)
          _EntityNestedCard(
            title: 'Alias ${index + 1}',
            values: aliases[index],
          ),
      ],
    );
  }

  Widget _buildAddresses(Map<String, dynamic> entity) {
    final List<Map<String, dynamic>> addresses = _convertList(
      entity['ADDRESSES'],
    );

    final List<Map<String, dynamic>> usefulAddresses = addresses.where((
      address,
    ) {
      return address.entries.any(
        (entry) => entry.key != 'ADDR_SEQ' && _hasValue(entry.value),
      );
    }).toList();

    if (usefulAddresses.isEmpty) {
      return const SizedBox.shrink();
    }

    return _EntityDetailsSection(
      title: 'Addresses',
      icon: Icons.location_on_outlined,
      children: [
        for (int index = 0; index < usefulAddresses.length; index++)
          _EntityNestedCard(
            title: 'Address ${index + 1}',
            values: usefulAddresses[index],
          ),
      ],
    );
  }

  Widget _buildAttributes(Map<String, dynamic> entity) {
    final List<Map<String, dynamic>> attributes = _convertList(
      entity['ATTR_VALUES'],
    );

    if (attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return _EntityDetailsSection(
      title: 'Attributes',
      icon: Icons.list_alt_outlined,
      children: [
        for (int index = 0; index < attributes.length; index++)
          _EntityNestedCard(
            title: _hasValue(attributes[index]['ATTR_NAME'])
                ? _value(attributes[index]['ATTR_NAME'])
                : 'Attribute ${index + 1}',
            values: {
              'VALUE_SEQ': attributes[index]['VALUE_SEQ'],
              'ATTR_VALUE': attributes[index]['ATTR_VALUE'],
            },
          ),
      ],
    );
  }

  Widget _buildInterpolInformation(Map<String, dynamic> entity) {
    final bool hasInterpolData =
        _hasValue(entity['HAS_INTERPOL_LINK']) ||
        _hasValue(entity['INTERPOL_LINK']);

    if (!hasInterpolData) {
      return const SizedBox.shrink();
    }

    return _EntityDetailsSection(
      title: 'Interpol information',
      icon: Icons.public_outlined,
      children: [
        _EntityDetailRow(
          label: 'Has Interpol link',
          value: _value(entity['HAS_INTERPOL_LINK']),
        ),
        _EntityDetailRow(
          label: 'Interpol link',
          value: _value(entity['INTERPOL_LINK']),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildAdditionalFields(Map<String, dynamic> entity) {
    const Set<String> handledKeys = {
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

    final Map<String, dynamic> additionalFields = {};

    for (final MapEntry<String, dynamic> entry in entity.entries) {
      if (handledKeys.contains(entry.key)) {
        continue;
      }

      if (!_hasValue(entry.value)) {
        continue;
      }

      if (entry.value is List || entry.value is Map) {
        continue;
      }

      additionalFields[entry.key] = entry.value;
    }

    if (additionalFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return _EntityDetailsSection(
      title: 'Additional information',
      icon: Icons.info_outline,
      children: additionalFields.entries.map((entry) {
        return _EntityDetailRow(
          label: _formatKey(entry.key),
          value: _value(entry.value),
        );
      }).toList(),
    );
  }

  static List<Map<String, dynamic>> _convertList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static bool _hasValue(dynamic value) {
    if (value == null) {
      return false;
    }

    final String text = value.toString().trim();

    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  static String _value(dynamic value, {String fallback = 'Not specified'}) {
    if (!_hasValue(value)) {
      return fallback;
    }

    return value.toString().trim();
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

class _EntityDetailsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _EntityDetailsSection({
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

class _EntityDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _EntityDetailRow({
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

class _EntityNestedCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> values;

  const _EntityNestedCard({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, dynamic>> usefulValues = values.entries.where((
      entry,
    ) {
      if (entry.value == null) {
        return false;
      }

      final String value = entry.value.toString().trim();

      return value.isNotEmpty && value.toLowerCase() != 'null';
    }).toList();

    if (usefulValues.isEmpty) {
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
          for (final entry in usefulValues)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 135,
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
