import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/sanctions_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import 'national_entity_details_page.dart';

class NationalEntitiesPage extends StatefulWidget {
  const NationalEntitiesPage({super.key});

  @override
  State<NationalEntitiesPage> createState() => _NationalEntitiesPageState();
}

class _NationalEntitiesPageState extends State<NationalEntitiesPage> {
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

    _scrollController.addListener(_onScroll);

    _loadEntities(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMoreEntities();
    }
  }

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
      debugPrint(
        '🔄 [NATIONAL ENTITIES] '
        'offset=$_currentOffset limit=$_pageSize',
      );

      final Map<String, dynamic> response = await _service.getNationalEntities(
        offset: _currentOffset,
        limit: _pageSize,
        language: 'ARAB',
      );

      final dynamic rawData = response['DATA'];

      final List<Map<String, dynamic>> newEntities = rawData is List
          ? rawData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : [];

      final int totalRecords = _toInt(response['total_records']);

      if (!mounted) return;

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

      _applySearch();

      debugPrint(
        '✅ [NATIONAL ENTITIES] '
        '${_allEntities.length}/$_totalRecords loaded',
      );
    } catch (error, stackTrace) {
      debugPrint('❌ [NATIONAL ENTITIES] $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreEntities() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _loadEntities();
  }

  void _search(String value) {
    _applySearch();
  }

  void _applySearch() {
    final String query = _searchController.text.trim().toLowerCase();

    final results = _allEntities.where((entity) {
      final String searchable = [
        _text(entity['ID']),
        _text(entity['ENTITY_NAME_IN_ARABIC']),
        _text(entity['ENTITY_NAME_IN_ENGLISH']),
        _text(entity['RECORDED_NAME']),
        _text(entity['NICKNAME_OR_ALIAS']),
        _text(entity['ENTITY_DESCRIPTION']),
        _text(entity['LEADERSHIP']),
        _text(entity['LEGAL_STATUS']),
        _text(entity['ENTITY_TYPE']),
        _text(entity['ACTIVITY']),
        _text(entity['NOTES']),
        _text(entity['REASONING']),
      ].join(' ').toLowerCase();

      return query.isEmpty || searchable.contains(query);
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredEntities = results;
    });
  }

  void _openDetails(Map<String, dynamic> entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NationalEntityDetailsPage(entity: entity),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'National Entities', showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by ID, name or recorded name',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing ${_filteredEntities.length} '
                  'loaded of $_totalRecords entities',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 52, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  _loadEntities(refresh: true);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredEntities.isEmpty) {
      return const Center(child: Text('No matching entities found.'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadEntities(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),

        itemCount: _filteredEntities.length + (_isLoadingMore ? 1 : 0),

        separatorBuilder: (_, __) => const SizedBox(height: 10),

        itemBuilder: (context, index) {
          if (index == _filteredEntities.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final entity = _filteredEntities[index];

          final String arabicName = _text(entity['ENTITY_NAME_IN_ARABIC']);

          final String englishName = _text(entity['ENTITY_NAME_IN_ENGLISH']);

          final String name = arabicName.isNotEmpty ? arabicName : englishName;

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
                    if (_text(entity['ID']).isNotEmpty)
                      Text('ID: ${entity['ID']}'),

                    if (_text(entity['RECORDED_NAME']).isNotEmpty)
                      Text(
                        'Recorded name: '
                        '${entity['RECORDED_NAME']}',
                      ),

                    if (_text(entity['ENTITY_TYPE']).isNotEmpty)
                      Text(
                        'Type: '
                        '${entity['ENTITY_TYPE']}',
                      ),
                  ],
                ),
              ),

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () => _openDetails(entity),
            ),
          );
        },
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
