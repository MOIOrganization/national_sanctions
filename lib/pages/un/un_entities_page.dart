import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/sanctions_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/display_names.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/sanctions_list_row.dart';
import '../../widgets/sanctions_list_shell.dart';
import '../../widgets/search_field.dart';
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
      final Map<String, dynamic> response = await _service.getAllEntities(
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

    final List<Map<String, dynamic>> results = _allEntities.where((entity) {
      if (query.isEmpty) {
        return true;
      }

      return _text(entity['DATAID']).toLowerCase().contains(query) ||
          _text(entity['FIRST_NAME']).toLowerCase().contains(query) ||
          _text(entity['NAME_ORIGINAL_SCRIPT']).toLowerCase().contains(query) ||
          _text(entity['REFERENCE_NUMBER']).toLowerCase().contains(query) ||
          _text(entity['UN_LIST_TYPE']).toLowerCase().contains(query) ||
          _text(entity['COMMENTS1']).toLowerCase().contains(query) ||
          _entityAliases(entity).toLowerCase().contains(query) ||
          _entityAddresses(entity).toLowerCase().contains(query);
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

  void _openEntityDetails(Map<String, dynamic> entity) {
    final int dataId = _toInt(entity['DATAID']);

    if (dataId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidRecordId),
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

  String? _entityCountry(Map<String, dynamic> entity) {
    final dynamic addresses = entity['ADDRESSES'];

    if (addresses is! List) {
      return null;
    }

    for (final dynamic item in addresses) {
      if (item is! Map) {
        continue;
      }

      final String country = _text(item['COUNTRY']);

      if (country.isNotEmpty) {
        return country;
      }
    }

    return null;
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

    return SanctionsListShell(
      search: SearchField(
        controller: _searchController,
        hintText: l10n.searchByNameIdReference,
        onChanged: (_) => _applySearch(),
        onClear: () {
          _searchController.clear();
          _applySearch();
        },
        resultCountLabel: _resultCountLabel(l10n),
      ),
      body: _buildContent(l10n),
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

          final Map<String, dynamic> entity = _filteredEntities[index];
          final names = DisplayNames.resolve(
            fallback: l10n.unnamedEntity,
            first: _text(entity['NAME_ORIGINAL_SCRIPT']),
            second: _text(entity['FIRST_NAME']),
          );
          final String? country = _entityCountry(entity);

          return SanctionsListRow(
            leadingIcon: Icons.business_outlined,
            primaryName: names.primary,
            secondaryName: names.secondary,
            identifier: _text(entity['REFERENCE_NUMBER']).isEmpty
                ? null
                : _text(entity['REFERENCE_NUMBER']),
            chips: [_text(entity['UN_LIST_TYPE'])],
            metadata: [
              if (country != null) country,
            ],
            onTap: () => _openEntityDetails(entity),
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
