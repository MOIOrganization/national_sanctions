import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/sanctions_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/display_names.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/header.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/sanctions_list_row.dart';
import '../../widgets/sanctions_list_shell.dart';
import '../../widgets/search_field.dart';
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
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;

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

      _applySearch();
    } catch (error, stackTrace) {
      debugPrint('❌ [NATIONAL ENTITIES] $error');
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

  Future<void> _loadMoreEntities() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _loadEntities();
  }

  void _applySearch() {
    final String query = _searchController.text.trim().toLowerCase();

    final results = _allEntities.where((entity) {
      if (query.isEmpty) {
        return true;
      }

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

      return searchable.contains(query);
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _filteredEntities = results;
    });
  }

  String? _resultCountLabel(AppLocalizations l10n) {
    if (_isLoading || _errorMessage != null) {
      return null;
    }

    if (_searchController.text.trim().isEmpty) {
      return l10n.showingCount(_allEntities.length, _totalRecords);
    }

    return l10n.matchesCount(
      _filteredEntities.length,
      _allEntities.length,
      _totalRecords,
    );
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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: Header(title: l10n.nationalEntitiesTitle, showBackButton: true),
      body: SanctionsListShell(
        search: SearchField(
          controller: _searchController,
          hintText: l10n.searchByNameIdRecorded,
          onChanged: (_) => _applySearch(),
          onClear: () {
            _searchController.clear();
            _applySearch();
          },
          resultCountLabel: _resultCountLabel(l10n),
        ),
        body: _buildContent(l10n),
      ),
    );
  }

  Widget _buildContent([AppLocalizations? localizations]) {
    final AppLocalizations l10n =
        localizations ?? AppLocalizations.of(context);

    if (_isLoading) {
      return LoadingState(message: l10n.loadingEntities);
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: l10n.unableToLoadEntities,
        onRetry: () => _loadEntities(refresh: true),
      );
    }

    if (_filteredEntities.isEmpty) {
      final bool searching = _searchController.text.trim().isNotEmpty;

      return RefreshIndicator(
        onRefresh: () => _loadEntities(refresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: EmptyState(
                    icon: Icons.business_outlined,
                    title: l10n.noResultsFound,
                    message: searching
                        ? l10n.noMatchesLoaded
                        : l10n.noEntitiesAvailable,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadEntities(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        itemCount: _filteredEntities.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == _filteredEntities.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final entity = _filteredEntities[index];
          final names = DisplayNames.resolve(
            fallback: l10n.unnamedEntity,
            first: _text(entity['ENTITY_NAME_IN_ARABIC']),
            second: _text(entity['ENTITY_NAME_IN_ENGLISH']).isNotEmpty
                ? _text(entity['ENTITY_NAME_IN_ENGLISH'])
                : _text(entity['RECORDED_NAME']),
          );

          return SanctionsListRow(
            leadingIcon: Icons.business_outlined,
            primaryName: names.primary,
            secondaryName: names.secondary,
            identifier: _text(entity['ID']).isEmpty ? null : _text(entity['ID']),
            chips: [_text(entity['ENTITY_TYPE'])],
            onTap: () => _openDetails(entity),
          );
        },
      ),
    );
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
