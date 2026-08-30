import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models.dart';
import '../../services/sanctions_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/display_names.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/sanctions_list_row.dart';
import '../../widgets/sanctions_list_shell.dart';
import '../../widgets/search_field.dart';
import 'un_person_details_page.dart';

class IndividualsPage extends StatefulWidget {
  const IndividualsPage({super.key});

  @override
  State<IndividualsPage> createState() => _IndividualsPageState();
}

class _IndividualsPageState extends State<IndividualsPage> {
  final SanctionsService _service = SanctionsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Individual> _allIndividuals = [];
  List<Individual> _filteredIndividuals = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  int _totalRecords = 0;
  int _currentOffset = 0;

  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadIndividuals(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMoreIndividuals();
    }
  }

  Future<void> _loadIndividuals({bool refresh = false}) async {
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
        '🔄 [INDIVIDUALS] Loading offset=$_currentOffset limit=$_pageSize',
      );

      final IndividualResponse response = await _service.getAllIndividuals(
        offset: _currentOffset,
        limit: _pageSize,
        language: 'ARAB',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (refresh) {
          _allIndividuals = response.individuals;
        } else {
          _allIndividuals.addAll(response.individuals);
        }

        _totalRecords = response.totalRecords;
        _currentOffset = _allIndividuals.length;
        _hasMore =
            response.individuals.isNotEmpty &&
            _allIndividuals.length < response.totalRecords;
        _isLoading = false;
        _isLoadingMore = false;
      });

      _applySearch();
    } catch (error, stackTrace) {
      debugPrint('❌ [INDIVIDUALS] Error: $error');
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

  Future<void> _loadMoreIndividuals() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _loadIndividuals();
  }

  void _applySearch() {
    final String query = _searchController.text.trim().toLowerCase();

    final List<Individual> results = _allIndividuals.where((individual) {
      if (query.isEmpty) {
        return true;
      }

      final String aliases = individual.aliases
          .map((alias) => alias.name)
          .join(' ')
          .toLowerCase();

      final String designations = individual.designations.join(' ').toLowerCase();

      return individual.dataId.toString().contains(query) ||
          individual.fullName.toLowerCase().contains(query) ||
          individual.originalScriptName.toLowerCase().contains(query) ||
          individual.referenceNumber.toLowerCase().contains(query) ||
          individual.unListType.toLowerCase().contains(query) ||
          individual.nationality.toLowerCase().contains(query) ||
          aliases.contains(query) ||
          designations.contains(query);
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _filteredIndividuals = results;
    });
  }

  String? _resultCountLabel(AppLocalizations l10n) {
    if (_isLoading || _errorMessage != null) {
      return null;
    }

    if (_searchController.text.trim().isEmpty) {
      return l10n.showingCount(_allIndividuals.length, _totalRecords);
    }

    return l10n.matchesCount(
      _filteredIndividuals.length,
      _allIndividuals.length,
      _totalRecords,
    );
  }

  void _openDetails(Individual individual) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonDetailsPage(
          dataId: individual.dataId,
          initialIndividual: individual,
        ),
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
      return LoadingState(message: l10n.loadingIndividuals);
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: l10n.unableToLoadIndividuals,
        onRetry: () => _loadIndividuals(refresh: true),
      );
    }

    if (_filteredIndividuals.isEmpty) {
      final bool searching = _searchController.text.trim().isNotEmpty;

      return RefreshIndicator(
        onRefresh: () => _loadIndividuals(refresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: constraints.maxHeight,
                  child: EmptyState(
                    icon: Icons.person_search_outlined,
                    title: l10n.noResultsFound,
                    message: searching
                        ? l10n.noMatchesLoaded
                        : l10n.noIndividualsAvailable,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadIndividuals(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        itemCount: _filteredIndividuals.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == _filteredIndividuals.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final Individual individual = _filteredIndividuals[index];
          final names = DisplayNames.resolve(
            fallback: l10n.unnamedIndividual,
            first: individual.originalScriptName,
            second: individual.fullName,
          );

          return SanctionsListRow(
            leadingIcon: Icons.person_outline,
            primaryName: names.primary,
            secondaryName: names.secondary,
            identifier: individual.referenceNumber.isEmpty
                ? null
                : individual.referenceNumber,
            chips: [
              individual.unListType,
              individual.nationality,
            ],
            onTap: () => _openDetails(individual),
          );
        },
      ),
    );
  }
}
