import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/sanctions_service.dart';
import '../../theme/app_colors.dart';
import 'un_entity_details_page.dart';

class EntitiesPage extends StatefulWidget {
  const EntitiesPage({super.key});

  @override
  State<EntitiesPage> createState() => _EntitiesPageState();
}

class _EntitiesPageState extends State<EntitiesPage> {
  final SanctionsService _service = SanctionsService();

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allEntities = [];
  List<Map<String, dynamic>> _filteredEntities = [];

  static const int _pageSize = 50;

  int _currentOffset = 0;
  int _totalRecords = 0;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('🏢 [ENTITIES PAGE] initState');
    debugPrint('========================================');

    _scrollController.addListener(_onScroll);

    _loadEntities(refresh: true);
  }

  // ============================================================
  // DETECT WHEN USER REACHES THE BOTTOM
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMoreEntities();
    }
  }

  // ============================================================
  // LOAD ENTITIES
  // ============================================================

  Future<void> _loadEntities({bool refresh = false}) async {
    if (refresh && mounted) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _errorMessage = null;

        _currentOffset = 0;
        _hasMore = true;
      });
    }

    try {
      debugPrint('');
      debugPrint(
        '🔄 [ENTITIES] Loading '
        'offset=$_currentOffset limit=$_pageSize',
      );

      final Map<String, dynamic> response = await _service.getAllEntities(
        offset: _currentOffset,
        limit: _pageSize,
        language: 'ARAB',
      );

      final dynamic rawData = response['DATA'];

      final List<Map<String, dynamic>> newEntities;

      if (rawData is List) {
        newEntities = rawData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        newEntities = [];
      }

      final int totalRecords = _toInt(response['total_records']);

      if (!mounted) {
        return;
      }

      setState(() {
        if (refresh) {
          _allEntities = List<Map<String, dynamic>>.from(newEntities);
        } else {
          _allEntities.addAll(newEntities);
        }

        _totalRecords = totalRecords;

        _currentOffset = _allEntities.length;

        _hasMore = newEntities.isNotEmpty && _allEntities.length < totalRecords;

        _isLoading = false;
        _isLoadingMore = false;
      });

      // Reapply search after new data is loaded.
      _applySearch();

      debugPrint(
        '✅ [ENTITIES] Loaded now: '
        '${newEntities.length}',
      );

      debugPrint(
        '✅ [ENTITIES] Current loaded total: '
        '${_allEntities.length}',
      );

      debugPrint(
        '✅ [ENTITIES] Server total: '
        '$_totalRecords',
      );

      debugPrint('✅ [ENTITIES] Has more: $_hasMore');
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint('❌ [ENTITIES PAGE] Error: $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  // ============================================================
  // LOAD NEXT PAGE
  // ============================================================

  Future<void> _loadMoreEntities() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    debugPrint(
      '⬇️ [ENTITIES] Loading more '
      'from offset $_currentOffset',
    );

    setState(() {
      _isLoadingMore = true;
    });

    await _loadEntities();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _search(String value) {
    debugPrint('🔎 [ENTITIES] Search: "$value"');

    _applySearch();
  }

  void _applySearch() {
    final String query = _searchController.text.trim().toLowerCase();

    final List<Map<String, dynamic>> results = _allEntities.where((entity) {
      final String dataId = _text(entity['DATAID']).toLowerCase();

      final String name = _text(entity['FIRST_NAME']).toLowerCase();

      final String referenceNumber = _text(
        entity['REFERENCE_NUMBER'],
      ).toLowerCase();

      final String listType = _text(entity['UN_LIST_TYPE']).toLowerCase();

      final String comments = _text(entity['COMMENTS1']).toLowerCase();

      final String aliases = _entityAliases(entity).toLowerCase();

      final String addresses = _entityAddresses(entity).toLowerCase();

      return query.isEmpty ||
          dataId.contains(query) ||
          name.contains(query) ||
          referenceNumber.contains(query) ||
          listType.contains(query) ||
          comments.contains(query) ||
          aliases.contains(query) ||
          addresses.contains(query);
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _filteredEntities = results;
    });

    debugPrint(
      '🔎 [ENTITIES] Matching results: '
      '${results.length}',
    );
  }

  // ============================================================
  // OPEN DETAILS
  // ============================================================

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

    debugPrint('');
    debugPrint('👆 [ENTITIES] Opening entity ID: $dataId');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EntityDetailsPage(dataId: dataId, initialEntity: entity),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // PAGE UI
  // ============================================================

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
                        _applySearch();
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
          ),
        ),

        if (!_isLoading && _errorMessage == null)
          Expanded(child: _buildContent()),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  _loadEntities(refresh: true);
                },
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
        onRefresh: () {
          return _loadEntities(refresh: true);
        },
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
      onRefresh: () {
        return _loadEntities(refresh: true);
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),

        // Add one extra item while loading more.
        itemCount: _filteredEntities.length + (_isLoadingMore ? 1 : 0),

        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },

        itemBuilder: (context, index) {
          // Bottom loading indicator.
          if (index == _filteredEntities.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }

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
                      Text(
                        'Reference: '
                        '$referenceNumber',
                      ),

                    if (listType.isNotEmpty) Text('List: $listType'),

                    if (aliasesCount > 0)
                      Text(
                        'Aliases: '
                        '$aliasesCount',
                      ),

                    if (addressesCount > 0)
                      Text(
                        'Addresses: '
                        '$addressesCount',
                      ),
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

  // ============================================================
  // ENTITY HELPERS
  // ============================================================

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
