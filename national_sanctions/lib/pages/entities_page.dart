import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/sanctions_service.dart';
import '../theme/app_colors.dart';
import 'entity_details_page.dart';

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
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> response = await _service.getAllEntities(
        offset: 0,
        limit: 50,
        // limit: 1000,
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

      if (!mounted) return;

      setState(() {
        _allEntities = entities;
        _filteredEntities = entities;
        _totalRecords = _toInt(response['total_records']);
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('❌ [ENTITIES PAGE] Error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _search(String value) {
    final String query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredEntities = List<Map<String, dynamic>>.from(_allEntities);

        return;
      }

      _filteredEntities = _allEntities.where((entity) {
        final String dataId = _text(entity['DATAID']).toLowerCase();

        final String name = _text(entity['FIRST_NAME']).toLowerCase();

        final String referenceNumber = _text(
          entity['REFERENCE_NUMBER'],
        ).toLowerCase();

        final String listType = _text(entity['UN_LIST_TYPE']).toLowerCase();

        final String comments = _text(entity['COMMENTS1']).toLowerCase();

        final String aliases = _entityAliases(entity).toLowerCase();

        final String addresses = _entityAddresses(entity).toLowerCase();

        return dataId.contains(query) ||
            name.contains(query) ||
            referenceNumber.contains(query) ||
            listType.contains(query) ||
            comments.contains(query) ||
            aliases.contains(query) ||
            addresses.contains(query);
      }).toList();
    });
  }

  void _openEntityDetails(Map<String, dynamic> entity) {
    final int dataId = _toInt(entity['DATAID']);

    if (dataId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This entity does not have a valid data ID.'),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EntityDetailsPage(dataId: dataId, initialEntity: entity),
      ),
    );
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
              hintText: 'Search by ID, entity or reference number',
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

          final int dataId = _toInt(entity['DATAID']);

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
                    if (dataId != 0) Text('ID: $dataId'),
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
            _text(address['STATE_PROVINCE']),
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
