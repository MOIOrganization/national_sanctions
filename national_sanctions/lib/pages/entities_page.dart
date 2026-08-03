import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/sanctions_service.dart';
import '../theme/app_colors.dart';

class EntitiesPage extends StatefulWidget {
  const EntitiesPage({super.key});

  @override
  State<EntitiesPage> createState() => _EntitiesPageState();
}

class _EntitiesPageState extends State<EntitiesPage> {
  final SanctionsService _service = SanctionsService();

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allEntities = [];
  List<Map<String, dynamic>> _filteredEntities = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _totalRecords = 0;

  @override
  void initState() {
    super.initState();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('🏢 [ENTITIES PAGE] Page opened');
    debugPrint('🏢 [ENTITIES PAGE] Loading entities');
    debugPrint('========================================');

    _loadEntities();
  }

  Future<void> _loadEntities() async {
    debugPrint('🔄 [ENTITIES PAGE] _loadEntities started');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Map<String, dynamic> response = await _service.getAllEntities(
        offset: 0,
        limit: 50,
        language: 'ARAB',
      );

      final dynamic rawData = response['DATA'];

      final List<Map<String, dynamic>> entities;

      if (rawData is List) {
        entities = rawData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        entities = [];
      }

      final int totalRecords = _toInt(response['total_records']);

      debugPrint('✅ [ENTITIES PAGE] Total records: $totalRecords');

      debugPrint(
        '✅ [ENTITIES PAGE] Records received: '
        '${entities.length}',
      );

      for (final entity in entities.take(5)) {
        debugPrint(
          '🏢 [ENTITY] '
          'ID=${entity['DATAID']} '
          '| Name=${entity['FIRST_NAME']} '
          '| Reference=${entity['REFERENCE_NUMBER']}',
        );
      }

      if (!mounted) return;

      setState(() {
        _allEntities = entities;
        _filteredEntities = entities;
        _totalRecords = totalRecords;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('❌ [ENTITIES PAGE] Error: $error');
      debugPrint('❌ [ENTITIES PAGE] Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _search(String value) {
    final String query = value.trim().toLowerCase();

    debugPrint('🔎 [ENTITIES PAGE] Search query: "$query"');

    setState(() {
      if (query.isEmpty) {
        _filteredEntities = List<Map<String, dynamic>>.from(_allEntities);

        return;
      }

      _filteredEntities = _allEntities.where((entity) {
        final String name = _text(entity['FIRST_NAME']).toLowerCase();

        final String referenceNumber = _text(
          entity['REFERENCE_NUMBER'],
        ).toLowerCase();

        final String listType = _text(entity['UN_LIST_TYPE']).toLowerCase();

        final String comments = _text(entity['COMMENTS1']).toLowerCase();

        final String aliases = _entityAliases(entity).toLowerCase();

        final String addresses = _entityAddresses(entity).toLowerCase();

        return name.contains(query) ||
            referenceNumber.contains(query) ||
            listType.contains(query) ||
            comments.contains(query) ||
            aliases.contains(query) ||
            addresses.contains(query);
      }).toList();
    });

    debugPrint(
      '🔎 [ENTITIES PAGE] Matches: '
      '${_filteredEntities.length}',
    );
  }

  Future<void> _openEntityDetails(Map<String, dynamic> entity) async {
    final int dataId = _toInt(entity['DATAID']);

    debugPrint('');
    debugPrint('👆 [ENTITIES PAGE] Entity pressed');
    debugPrint('👆 [ENTITIES PAGE] Data ID: $dataId');
    debugPrint(
      '👆 [ENTITIES PAGE] Name: '
      '${_text(entity['FIRST_NAME'])}',
    );

    if (dataId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This entity does not have a valid data ID.'),
        ),
      );

      return;
    }

    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      final Map<String, dynamic> fullEntity = await _service.getEntityById(
        dataId: dataId,
        language: 'ARAB',
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EntityDetailsPage(entity: fullEntity),
        ),
      );
    } catch (error) {
      debugPrint('❌ [ENTITIES PAGE] Details error: $error');

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load entity details: $error')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Search entity or reference number',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
          ),
        ),
        if (!_isLoading && _errorMessage == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing ${_filteredEntities.length} '
                    'of $_totalRecords entities',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _loadEntities,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Loading entities...'),
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
              const Icon(Icons.error_outline, size: 54, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Unable to load entities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SelectableText(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadEntities,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredEntities.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadEntities,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Icon(
              Icons.business_outlined,
              size: 55,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Center(child: Text('No matching entities found.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEntities,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filteredEntities.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          final Map<String, dynamic> entity = _filteredEntities[index];

          final String name = _text(entity['FIRST_NAME']);

          final String referenceNumber = _text(entity['REFERENCE_NUMBER']);

          final String listType = _text(entity['UN_LIST_TYPE']);

          final int aliasesCount = _listLength(entity['ALIASES']);

          final int addressesCount = _listLength(entity['ADDRESSES']);

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                name.isEmpty ? 'Unnamed entity' : name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (referenceNumber.isNotEmpty)
                      Text('Reference: $referenceNumber'),
                    if (listType.isNotEmpty) Text('List: $listType'),
                    if (aliasesCount > 0) Text('Aliases: $aliasesCount'),
                    if (addressesCount > 0) Text('Addresses: $addressesCount'),
                  ],
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _openEntityDetails(entity);
              },
            ),
          );
        },
      ),
    );
  }

  String _entityAliases(Map<String, dynamic> entity) {
    final dynamic aliases = entity['ALIASES'];

    if (aliases is! List) {
      return '';
    }

    return aliases
        .whereType<Map>()
        .map((alias) => _text(alias['ALIAS_NAME']))
        .where((name) => name.isNotEmpty)
        .join(' ');
  }

  String _entityAddresses(Map<String, dynamic> entity) {
    final dynamic addresses = entity['ADDRESSES'];

    if (addresses is! List) {
      return '';
    }

    return addresses
        .whereType<Map>()
        .map((address) {
          return [
            _text(address['STREET']),
            _text(address['CITY']),
            _text(address['COUNTRY']),
          ].where((value) => value.isNotEmpty).join(' ');
        })
        .join(' ');
  }

  int _listLength(dynamic value) {
    return value is List ? value.length : 0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}

class EntityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> entity;

  const EntityDetailsPage({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final String name = entity['FIRST_NAME']?.toString().trim() ?? '';

    final String reference =
        entity['REFERENCE_NUMBER']?.toString().trim() ?? '';

    final String listType = entity['UN_LIST_TYPE']?.toString().trim() ?? '';

    final String comments = entity['COMMENTS1']?.toString().trim() ?? '';

    final List<Map<String, dynamic>> aliases = _convertList(entity['ALIASES']);

    final List<Map<String, dynamic>> addresses = _convertList(
      entity['ADDRESSES'],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Entity Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                    child: const Icon(
                      Icons.business,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name.isEmpty ? 'Unnamed entity' : name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _EntityDetailRow(label: 'Reference', value: reference),
                  _EntityDetailRow(
                    label: 'List type',
                    value: listType,
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),
          if (comments.isNotEmpty) ...[
            const SizedBox(height: 12),
            _EntitySection(
              title: 'Comments',
              child: Text(comments, style: const TextStyle(height: 1.6)),
            ),
          ],
          if (aliases.isNotEmpty) ...[
            const SizedBox(height: 12),
            _EntitySection(
              title: 'Aliases',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: aliases.map((alias) {
                  final String aliasName =
                      alias['ALIAS_NAME']?.toString().trim() ?? '';

                  final String quality =
                      alias['QUALITY']?.toString().trim() ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      quality.isEmpty ? aliasName : '$aliasName\n$quality',
                      style: const TextStyle(height: 1.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (addresses.isNotEmpty) ...[
            const SizedBox(height: 12),
            _EntitySection(
              title: 'Addresses',
              child: Column(
                children: addresses.map((address) {
                  final String street =
                      address['STREET']?.toString().trim() ?? '';

                  final String city = address['CITY']?.toString().trim() ?? '';

                  final String country =
                      address['COUNTRY']?.toString().trim() ?? '';

                  final String displayAddress = [
                    street,
                    city,
                    country,
                  ].where((value) => value.isNotEmpty).join(', ');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            displayAddress,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
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
}

class _EntitySection extends StatelessWidget {
  final String title;
  final Widget child;

  const _EntitySection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Not available' : value,
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
