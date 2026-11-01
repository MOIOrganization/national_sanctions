// import 'package:flutter/material.dart';

// import '../../l10n/app_localizations.dart';
// import '../../models.dart';
// import '../../services/sanctions_service.dart';
// import '../../theme/app_spacing.dart';
// import '../../utils/display_names.dart';
// import '../../widgets/empty_state.dart';
// import '../../widgets/error_state.dart';
// import '../../widgets/loading_state.dart';
// import '../../widgets/sanctions_list_row.dart';
// import '../../widgets/sanctions_list_shell.dart';
// import '../../widgets/search_field.dart';
// import 'un_person_details_page.dart';

// class IndividualsPage extends StatefulWidget {
//   const IndividualsPage({super.key});

//   @override
//   State<IndividualsPage> createState() => _IndividualsPageState();
// }

// class _IndividualsPageState extends State<IndividualsPage> {
//   final SanctionsService _service = SanctionsService();
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   List<Individual> _allIndividuals = [];
//   List<Individual> _filteredIndividuals = [];

//   bool _isLoading = true;
//   bool _isLoadingMore = false;
//   bool _hasMore = true;
//   String? _errorMessage;

//   int _totalRecords = 0;
//   int _currentOffset = 0;

//   static const int _pageSize = 50;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _loadIndividuals(refresh: true);
//   }

//   void _onScroll() {
//     if (!_scrollController.hasClients) {
//       return;
//     }

//     final ScrollPosition position = _scrollController.position;

//     if (position.pixels >= position.maxScrollExtent - 250) {
//       _loadMoreIndividuals();
//     }
//   }

//   Future<void> _loadIndividuals({bool refresh = false}) async {
//     if (refresh && mounted) {
//       setState(() {
//         _isLoading = true;
//         _isLoadingMore = false;
//         _errorMessage = null;
//         _currentOffset = 0;
//         _hasMore = true;
//       });
//     }

//     try {
//       debugPrint(
//         '🔄 [INDIVIDUALS] Loading offset=$_currentOffset limit=$_pageSize',
//       );

//       final IndividualResponse response = await _service.getAllIndividuals(
//         offset: _currentOffset,
//         limit: _pageSize,
//         language: 'ARAB',
//       );

//       if (!mounted) {
//         return;
//       }

//       setState(() {
//         if (refresh) {
//           _allIndividuals = response.individuals;
//         } else {
//           _allIndividuals.addAll(response.individuals);
//         }

//         _totalRecords = response.totalRecords;
//         _currentOffset = _allIndividuals.length;
//         _hasMore =
//             response.individuals.isNotEmpty &&
//             _allIndividuals.length < response.totalRecords;
//         _isLoading = false;
//         _isLoadingMore = false;
//       });

//       _applySearch();
//     } catch (error, stackTrace) {
//       debugPrint('❌ [INDIVIDUALS] Error: $error');
//       debugPrintStack(stackTrace: stackTrace);

//       if (!mounted) {
//         return;
//       }

//       setState(() {
//         _errorMessage = error.toString();
//         _isLoading = false;
//         _isLoadingMore = false;
//       });
//     }
//   }

//   Future<void> _loadMoreIndividuals() async {
//     if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
//       return;
//     }

//     setState(() {
//       _isLoadingMore = true;
//     });

//     await _loadIndividuals();
//   }

//   void _applySearch() {
//     final String query = _searchController.text.trim().toLowerCase();

//     final List<Individual> results = _allIndividuals.where((individual) {
//       if (query.isEmpty) {
//         return true;
//       }

//       final String aliases = individual.aliases
//           .map((alias) => alias.name)
//           .join(' ')
//           .toLowerCase();

//       final String designations = individual.designations.join(' ').toLowerCase();

//       return individual.dataId.toString().contains(query) ||
//           individual.fullName.toLowerCase().contains(query) ||
//           individual.originalScriptName.toLowerCase().contains(query) ||
//           individual.referenceNumber.toLowerCase().contains(query) ||
//           individual.unListType.toLowerCase().contains(query) ||
//           individual.nationality.toLowerCase().contains(query) ||
//           aliases.contains(query) ||
//           designations.contains(query);
//     }).toList();

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _filteredIndividuals = results;
//     });
//   }

//   String? _resultCountLabel(AppLocalizations l10n) {
//     if (_isLoading || _errorMessage != null) {
//       return null;
//     }

//     if (_searchController.text.trim().isEmpty) {
//       return l10n.showingCount(_allIndividuals.length, _totalRecords);
//     }

//     return l10n.matchesCount(
//       _filteredIndividuals.length,
//       _allIndividuals.length,
//       _totalRecords,
//     );
//   }

//   void _openDetails(Individual individual) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PersonDetailsPage(
//           dataId: individual.dataId,
//           initialIndividual: individual,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AppLocalizations l10n = AppLocalizations.of(context);

//     return SanctionsListShell(
//       search: SearchField(
//         controller: _searchController,
//         hintText: l10n.searchByNameIdReference,
//         onChanged: (_) => _applySearch(),
//         onClear: () {
//           _searchController.clear();
//           _applySearch();
//         },
//         resultCountLabel: _resultCountLabel(l10n),
//       ),
//       body: _buildContent(l10n),
//     );
//   }

//   Widget _buildContent([AppLocalizations? localizations]) {
//     final AppLocalizations l10n =
//         localizations ?? AppLocalizations.of(context);

//     if (_isLoading) {
//       return LoadingState(message: l10n.loadingIndividuals);
//     }

//     if (_errorMessage != null) {
//       return ErrorState(
//         title: l10n.unableToLoadIndividuals,
//         onRetry: () => _loadIndividuals(refresh: true),
//       );
//     }

//     if (_filteredIndividuals.isEmpty) {
//       final bool searching = _searchController.text.trim().isNotEmpty;

//       return RefreshIndicator(
//         onRefresh: () => _loadIndividuals(refresh: true),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               children: [
//                 SizedBox(
//                   height: constraints.maxHeight,
//                   child: EmptyState(
//                     icon: Icons.person_search_outlined,
//                     title: l10n.noResultsFound,
//                     message: searching
//                         ? l10n.noMatchesLoaded
//                         : l10n.noIndividualsAvailable,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () => _loadIndividuals(refresh: true),
//       child: ListView.separated(
//         controller: _scrollController,
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.fromLTRB(
//           AppSpacing.page,
//           AppSpacing.xs,
//           AppSpacing.page,
//           AppSpacing.xl,
//         ),
//         itemCount: _filteredIndividuals.length + (_isLoadingMore ? 1 : 0),
//         separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
//         itemBuilder: (context, index) {
//           if (index == _filteredIndividuals.length) {
//             return const Padding(
//               padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
//               child: Center(child: CircularProgressIndicator()),
//             );
//           }

//           final Individual individual = _filteredIndividuals[index];
//           final names = DisplayNames.resolve(
//             fallback: l10n.unnamedIndividual,
//             first: individual.originalScriptName,
//             second: individual.fullName,
//           );

//           return SanctionsListRow(
//             leadingIcon: Icons.person_outline,
//             primaryName: names.primary,
//             secondaryName: names.secondary,
//             identifier: individual.referenceNumber.isEmpty
//                 ? null
//                 : individual.referenceNumber,
//             chips: [
//               individual.unListType,
//               individual.nationality,
//             ],
//             onTap: () => _openDetails(individual),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:async';

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

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String? _errorMessage;

  int _totalRecords = 0;
  int _currentOffset = 0;

  static const int _pageSize = 50;

  // Search settings
  String _matchMode = 'ANY';
  String _activeSearch = '';

  Timer? _searchDebounce;

  // Used to ignore outdated API responses
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _loadIndividuals(refresh: true);
  }

  // ============================================================
  // 1. CONVERT SEARCH TEXT TO API FORMAT
  // ============================================================

  String _formatSearchText(String value) {
    final String trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    // Example:
    // Mohammad Ali Iraq
    // becomes:
    // Mohammad||Ali||Iraq

    return trimmed
        .split(RegExp(r'(?:\s*\|\|\s*|\s+)'))
        .where((word) => word.isNotEmpty)
        .join('||');
  }

  // ============================================================
  // 2. SEARCH WHEN USER TYPES
  // ============================================================

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    // Invalidate previous requests immediately
    _requestVersion++;

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      _loadIndividuals(refresh: true);
    });
  }

  // ============================================================
  // 3. CHANGE MATCH MODE
  // ============================================================

  void _changeMatchMode(String mode) {
    if (_matchMode == mode) return;

    _searchDebounce?.cancel();

    setState(() {
      _matchMode = mode;
    });

    _loadIndividuals(refresh: true);
  }

  // ============================================================
  // 4. SCROLL PAGINATION
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final ScrollPosition position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMoreIndividuals();
    }
  }

  // ============================================================
  // 5. LOAD INDIVIDUALS FROM SEARCH API
  // ============================================================

  Future<void> _loadIndividuals({bool refresh = false}) async {
    if (!refresh && (_isLoading || !_hasMore)) {
      return;
    }

    final int requestId;

    if (refresh) {
      requestId = ++_requestVersion;

      _activeSearch = _formatSearchText(_searchController.text);

      if (mounted) {
        setState(() {
          _isLoading = true;
          _isLoadingMore = false;
          _errorMessage = null;

          _currentOffset = 0;
          _totalRecords = 0;
          _hasMore = true;

          _allIndividuals = [];
        });
      }

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    } else {
      requestId = _requestVersion;
    }

    final int offset = _currentOffset;
    final String searchText = _activeSearch;
    final String matchMode = _matchMode;

    try {
      debugPrint('');
      debugPrint('===================================');
      debugPrint('🔎 [UN INDIVIDUALS SEARCH]');
      debugPrint('Search: $searchText');
      debugPrint('Match mode: $matchMode');
      debugPrint('Offset: $offset');
      debugPrint('Limit: $_pageSize');
      debugPrint('===================================');

      final IndividualResponse response = await _service.searchIndividuals(
        searchText: searchText,
        matchMode: matchMode,
        offset: offset,
        limit: _pageSize,
      );

      // Ignore results from an outdated search
      if (!mounted || requestId != _requestVersion) {
        debugPrint('⚠️ [UN INDIVIDUALS] Ignoring outdated response');
        return;
      }

      setState(() {
        if (refresh) {
          _allIndividuals = response.individuals;
        } else {
          _allIndividuals.addAll(response.individuals);
        }

        _totalRecords = response.totalRecords;

        // Advance by actual number received
        _currentOffset = offset + response.individuals.length;

        _hasMore =
            response.individuals.isNotEmpty && _currentOffset < _totalRecords;

        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });

      debugPrint(
        '✅ [UN INDIVIDUALS] '
        'Loaded: ${_allIndividuals.length} '
        'of $_totalRecords',
      );

      // If the page is not scrollable yet, try loading
      // the next batch automatically.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            requestId != _requestVersion ||
            !_scrollController.hasClients) {
          return;
        }

        final position = _scrollController.position;

        if (_hasMore && position.maxScrollExtent <= 250) {
          _loadMoreIndividuals();
        }
      });
    } catch (error, stackTrace) {
      debugPrint('❌ [UN INDIVIDUALS] Error: $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || requestId != _requestVersion) {
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
  // 6. LOAD NEXT 50 RECORDS
  // ============================================================

  Future<void> _loadMoreIndividuals() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _loadIndividuals();
  }

  // ============================================================
  // 7. RESULT COUNT
  // ============================================================

  String? _resultCountLabel(AppLocalizations l10n) {
    if (_isLoading) {
      return null;
    }

    return l10n.showingCount(_allIndividuals.length, _totalRecords);
  }

  // ============================================================
  // 8. OPEN INDIVIDUAL DETAILS
  // ============================================================

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

  // ============================================================
  // 9. DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();

    _requestVersion++;

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // 10. MAIN PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SanctionsListShell(
      search: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SEARCH FIELD
          SearchField(
            controller: _searchController,
            hintText: l10n.searchByNameIdReference,
            onChanged: _onSearchChanged,
            onClear: () {
              _searchController.clear();
              _searchDebounce?.cancel();
              _loadIndividuals(refresh: true);
            },
            resultCountLabel: _resultCountLabel(l10n),
          ),

          // MATCH MODE
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              4,
              AppSpacing.page,
              10,
            ),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 18),

                const SizedBox(width: 10),

                const Text(
                  'Match:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),

                const SizedBox(width: 12),

                ChoiceChip(
                  label: const Text('ANY'),
                  selected: _matchMode == 'ANY',
                  onSelected: (_) {
                    _changeMatchMode('ANY');
                  },
                ),

                const SizedBox(width: 8),

                ChoiceChip(
                  label: const Text('ALL'),
                  selected: _matchMode == 'ALL',
                  onSelected: (_) {
                    _changeMatchMode('ALL');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildContent(l10n),
    );
  }

  // ============================================================
  // 11. BUILD CONTENT
  // ============================================================

  Widget _buildContent(AppLocalizations l10n) {
    if (_isLoading) {
      return LoadingState(message: l10n.loadingIndividuals);
    }

    if (_errorMessage != null && _allIndividuals.isEmpty) {
      return ErrorState(
        title: l10n.unableToLoadIndividuals,
        onRetry: () => _loadIndividuals(refresh: true),
      );
    }

    if (_allIndividuals.isEmpty) {
      final bool searching = _searchController.text.trim().isNotEmpty;

      return LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: EmptyState(
                  icon: Icons.person_search_outlined,
                  title: l10n.noResultsFound,
                  message: searching
                      ? 'No matching individuals found.'
                      : l10n.noIndividualsAvailable,
                ),
              ),
            ],
          );
        },
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      itemCount:
          _allIndividuals.length +
          ((_isLoadingMore || _errorMessage != null) ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        // PAGINATION FOOTER
        if (index == _allIndividuals.length) {
          if (_errorMessage != null) {
            return Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });

                  _loadMoreIndividuals();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry loading more'),
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final Individual individual = _allIndividuals[index];

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
          chips: [individual.unListType, individual.nationality],
          onTap: () => _openDetails(individual),
        );
      },
    );
  }
}
