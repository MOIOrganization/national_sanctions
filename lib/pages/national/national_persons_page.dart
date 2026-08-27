import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/sanctions_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/header.dart';
import 'national_person_details_page.dart';

class NationalPersonsPage extends StatefulWidget {
  const NationalPersonsPage({super.key});

  @override
  State<NationalPersonsPage> createState() => _NationalPersonsPageState();
}

class _NationalPersonsPageState extends State<NationalPersonsPage> {
  final SanctionsService _service = SanctionsService();

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allPersons = [];
  List<Map<String, dynamic>> _filteredPersons = [];

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

    _loadPersons(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMorePersons();
    }
  }

  Future<void> _loadPersons({bool refresh = false}) async {
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
        '🔄 [NATIONAL PERSONS] '
        'offset=$_currentOffset limit=$_pageSize',
      );

      final Map<String, dynamic> response = await _service.getNationalPersons(
        offset: _currentOffset,
        limit: _pageSize,
        language: 'ARAB',
      );

      final dynamic rawData = response['DATA'];

      final List<Map<String, dynamic>> newPersons = rawData is List
          ? rawData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : [];

      final int totalRecords = _toInt(response['total_records']);

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _allPersons = List<Map<String, dynamic>>.from(newPersons);
        } else {
          _allPersons.addAll(newPersons);
        }

        _totalRecords = totalRecords;
        _currentOffset = _allPersons.length;

        _hasMore = newPersons.isNotEmpty && _allPersons.length < totalRecords;

        _isLoading = false;
        _isLoadingMore = false;
      });

      _applySearch();

      debugPrint(
        '✅ [NATIONAL PERSONS] '
        '${_allPersons.length}/$_totalRecords loaded',
      );
    } catch (error, stackTrace) {
      debugPrint('❌ [NATIONAL PERSONS] $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMorePersons() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _loadPersons();
  }

  void _search(String value) {
    _applySearch();
  }

  void _applySearch() {
    final String query = _searchController.text.trim().toLowerCase();

    final results = _allPersons.where((person) {
      // Search all simple fields because we don't
      // yet have the exact person response structure.
      final String searchable = person.entries
          .where((entry) => entry.value is! List && entry.value is! Map)
          .map((entry) => entry.value?.toString() ?? '')
          .join(' ')
          .toLowerCase();

      return query.isEmpty || searchable.contains(query);
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredPersons = results;
    });
  }

  String _personName(Map<String, dynamic> person) {
    final possibleNames = [
      person['PERSON_NAME_IN_ARABIC'],
      person['NAME_IN_ARABIC'],
      person['FULL_NAME_ARABIC'],
      person['PERSON_NAME_IN_ENGLISH'],
      person['NAME_IN_ENGLISH'],
      person['FULL_NAME_ENGLISH'],
      person['RECORDED_NAME'],
      person['FIRST_NAME'],
    ];

    for (final value in possibleNames) {
      final String text = _text(value);

      if (text.isNotEmpty) {
        return text;
      }
    }

    return 'Unnamed person';
  }

  void _openDetails(Map<String, dynamic> person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NationalPersonDetailsPage(person: person),
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
      appBar: const Header(title: 'National Persons', showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by ID or name',
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
                  'Showing '
                  '${_filteredPersons.length} '
                  'loaded of $_totalRecords persons',
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
                  _loadPersons(refresh: true);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredPersons.isEmpty) {
      return const Center(child: Text('No matching persons found.'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadPersons(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filteredPersons.length + (_isLoadingMore ? 1 : 0),

        separatorBuilder: (_, __) => const SizedBox(height: 10),

        itemBuilder: (context, index) {
          if (index == _filteredPersons.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final person = _filteredPersons[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
              ),

              title: Text(
                _personName(person),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_text(person['ID']).isNotEmpty)
                      Text('ID: ${person['ID']}'),

                    if (_text(person['RECORDED_NAME']).isNotEmpty)
                      Text(
                        'Recorded name: '
                        '${person['RECORDED_NAME']}',
                      ),
                  ],
                ),
              ),

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () => _openDetails(person),
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
