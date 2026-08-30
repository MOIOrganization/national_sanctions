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
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;

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

      if (!mounted) {
        return;
      }

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
    } catch (error, stackTrace) {
      debugPrint('❌ [NATIONAL PERSONS] $error');
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

  Future<void> _loadMorePersons() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _errorMessage != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await _loadPersons();
  }

  void _applySearch() {
    final String query = _searchController.text.trim().toLowerCase();

    final results = _allPersons.where((person) {
      if (query.isEmpty) {
        return true;
      }

      final String searchable = person.entries
          .where((entry) => entry.value is! List && entry.value is! Map)
          .map((entry) => entry.value?.toString() ?? '')
          .join(' ')
          .toLowerCase();

      return searchable.contains(query);
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _filteredPersons = results;
    });
  }

  String? _resultCountLabel(AppLocalizations l10n) {
    if (_isLoading || _errorMessage != null) {
      return null;
    }

    if (_searchController.text.trim().isEmpty) {
      return l10n.showingCount(_allPersons.length, _totalRecords);
    }

    return l10n.matchesCount(
      _filteredPersons.length,
      _allPersons.length,
      _totalRecords,
    );
  }

  String _firstText(Map<String, dynamic> data, List<String> keys) {
    for (final String key in keys) {
      final String text = _text(data[key]);

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: Header(title: l10n.nationalPersons, showBackButton: true),
      body: SanctionsListShell(
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
      ),
    );
  }

  Widget _buildContent([AppLocalizations? localizations]) {
    final AppLocalizations l10n =
        localizations ?? AppLocalizations.of(context);

    if (_isLoading) {
      return LoadingState(message: l10n.loadingPersons);
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: l10n.unableToLoadPersons,
        onRetry: () => _loadPersons(refresh: true),
      );
    }

    if (_filteredPersons.isEmpty) {
      final bool searching = _searchController.text.trim().isNotEmpty;

      return RefreshIndicator(
        onRefresh: () => _loadPersons(refresh: true),
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
                        : l10n.noPersonsAvailable,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPersons(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        itemCount: _filteredPersons.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == _filteredPersons.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final person = _filteredPersons[index];
          final names = DisplayNames.resolve(
            fallback: l10n.unnamedPerson,
            first: _firstText(person, [
              'PERSON_NAME_IN_ARABIC',
              'NAME_IN_ARABIC',
              'FULL_NAME_ARABIC',
            ]),
            second: _firstText(person, [
              'PERSON_NAME_IN_ENGLISH',
              'NAME_IN_ENGLISH',
              'FULL_NAME_ENGLISH',
              'RECORDED_NAME',
              'FIRST_NAME',
            ]),
          );

          return SanctionsListRow(
            leadingIcon: Icons.person_outline,
            primaryName: names.primary,
            secondaryName: names.secondary,
            identifier: _text(person['ID']).isEmpty ? null : _text(person['ID']),
            chips: [
              _firstText(person, [
                'NATIONALITY',
                'NATIONALITY_IN_ARABIC',
                'NATIONALITY_IN_ENGLISH',
              ]),
            ],
            onTap: () => _openDetails(person),
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
