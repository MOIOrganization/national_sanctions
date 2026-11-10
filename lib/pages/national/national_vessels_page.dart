import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/sanctions_service.dart';
import '../../session/session_controller.dart';
import '../../session/store_review_account.dart';
import '../../theme/app_spacing.dart';
import '../../utils/display_names.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/header.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/sanctions_list_row.dart';
import '../../widgets/sanctions_list_shell.dart';
import '../../widgets/search_field.dart';

class NationalVesselsPage extends StatefulWidget {
  const NationalVesselsPage({super.key});

  @override
  State<NationalVesselsPage> createState() => _NationalVesselsPageState();
}

class _NationalVesselsPageState extends State<NationalVesselsPage> {
  final SanctionsService _service = SanctionsService();

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allVessels = [];
  List<Map<String, dynamic>> _filteredVessels = [];

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
    _loadVessels(refresh: true);
  }

  // ============================================================
  // SCROLL PAGINATION
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMoreVessels();
    }
  }

  // ============================================================
  // LOAD VESSELS
  // ============================================================

  Future<void> _loadVessels({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _errorMessage = null;
        _currentOffset = 0;
        _hasMore = true;
      });
    }

    try {
      final bool reviewUser = StoreReviewAccount.isReviewUser(
        SessionScope.read(context).userId,
      );

      // Review users must not call the live API.
      // No sample-vessel method was provided, so use
      // an empty response until sample data is added.
      final Map<String, dynamic> response = reviewUser
          ? <String, dynamic>{
              'total_records': 0,
              'DATA': <Map<String, dynamic>>[],
            }
          : await _service.getNationalVessels(
              offset: _currentOffset,
              limit: _pageSize,
              language: 'ARAB',
            );

      final dynamic rawData = response['DATA'];

      final List<Map<String, dynamic>> newVessels = rawData is List
          ? rawData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : [];

      final int totalRecords = _toInt(response['total_records']);

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _allVessels = newVessels;
        } else {
          _allVessels.addAll(newVessels);
        }

        _totalRecords = totalRecords;
        _currentOffset = _allVessels.length;

        _hasMore = newVessels.isNotEmpty && _allVessels.length < totalRecords;

        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });

      _applySearch();

      debugPrint(
        '✅ [NATIONAL VESSELS] '
        'Loaded ${_allVessels.length} '
        'of $_totalRecords',
      );
    } catch (error, stackTrace) {
      debugPrint('❌ [NATIONAL VESSELS] $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> _loadMoreVessels() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _loadVessels();
  }

  // ============================================================
  // LOCAL SEARCH
  // ============================================================

  void _applySearch() {
    final String query = _searchController.text.trim().toLowerCase();

    final results = _allVessels.where((vessel) {
      if (query.isEmpty) return true;

      return _text(vessel['NAME_AR']).toLowerCase().contains(query) ||
          _text(vessel['NAME_EN']).toLowerCase().contains(query) ||
          _text(vessel['IMO_NO']).toLowerCase().contains(query);
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredVessels = results;
    });
  }

  // ============================================================
  // RESULT COUNT
  // ============================================================

  String? _resultCountLabel(AppLocalizations l10n) {
    if (_isLoading || _errorMessage != null) {
      return null;
    }

    if (_searchController.text.trim().isEmpty) {
      return l10n.showingCount(_allVessels.length, _totalRecords);
    }

    return l10n.matchesCount(
      _filteredVessels.length,
      _allVessels.length,
      _totalRecords,
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
  // PAGE DESIGN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const Header(title: 'National Vessels', showBackButton: true),
      body: SanctionsListShell(
        search: SearchField(
          controller: _searchController,
          hintText: 'Search by vessel name or IMO number',
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

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const LoadingState(message: 'Loading vessels...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Unable to load vessels',
        onRetry: () => _loadVessels(refresh: true),
      );
    }

    if (_filteredVessels.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadVessels(refresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: EmptyState(
                    icon: Icons.directions_boat_outlined,
                    title: l10n.noResultsFound,
                    message: _searchController.text.trim().isNotEmpty
                        ? l10n.noMatchesLoaded
                        : 'No vessels available.',
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadVessels(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        itemCount: _filteredVessels.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == _filteredVessels.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final vessel = _filteredVessels[index];

          final names = DisplayNames.resolve(
            fallback: 'Unnamed vessel',
            first: _text(vessel['NAME_AR']),
            second: _text(vessel['NAME_EN']),
          );

          final String imo = _text(vessel['IMO_NO']);

          return IgnorePointer(
            child: SanctionsListRow(
              leadingIcon: Icons.directions_boat_outlined,
              primaryName: names.primary,
              secondaryName: names.secondary,
              identifier: imo.isEmpty ? null : 'IMO: $imo',
              chips: const [],
              onTap: null,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
