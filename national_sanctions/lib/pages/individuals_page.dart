import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import '../services/sanctions_service.dart';
import '../theme/app_colors.dart';
import 'person_details_page.dart';

class IndividualsPage extends StatefulWidget {
  const IndividualsPage({super.key});

  @override
  State<IndividualsPage> createState() => _IndividualsPageState();
}

class _IndividualsPageState extends State<IndividualsPage> {
  final SanctionsService _service = SanctionsService();

  final TextEditingController _searchController = TextEditingController();

  List<Individual> _allIndividuals = [];
  List<Individual> _filteredIndividuals = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _totalRecords = 0;

  final ScrollController _scrollController = ScrollController();

  static const int _pageSize = 50;

  int _currentOffset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('📄 [SANCTIONS PAGE] initState called');
    debugPrint('📄 [SANCTIONS PAGE] Starting API loading');
    debugPrint('========================================');
    _scrollController.addListener(_onScroll);

    _loadIndividuals(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMoreIndividuals();
    }
  }

  Future<void> _loadIndividuals({bool refresh = false}) async {
    if (refresh) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _isLoadingMore = false;
          _errorMessage = null;
          _currentOffset = 0;
          _hasMore = true;
        });
      }
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

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _allIndividuals = response.individuals;
        } else {
          _allIndividuals.addAll(response.individuals);
        }

        _filteredIndividuals = List<Individual>.from(_allIndividuals);

        _totalRecords = response.totalRecords;

        _currentOffset = _allIndividuals.length;

        _hasMore =
            response.individuals.isNotEmpty &&
            _allIndividuals.length < response.totalRecords;

        _isLoading = false;
        _isLoadingMore = false;
      });

      if (_searchController.text.trim().isNotEmpty) {
        _search(_searchController.text);
      }

      debugPrint('✅ [INDIVIDUALS] Loaded ${response.individuals.length}');

      debugPrint('✅ [INDIVIDUALS] Current total: ${_allIndividuals.length}');

      debugPrint('✅ [INDIVIDUALS] Has more: $_hasMore');
    } catch (error, stackTrace) {
      debugPrint('❌ [INDIVIDUALS] Error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

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

    debugPrint('⬇️ [INDIVIDUALS] Loading more from offset $_currentOffset');

    setState(() {
      _isLoadingMore = true;
    });

    await _loadIndividuals();
  }

  void _search(String value) {
    final String query = value.trim().toLowerCase();

    debugPrint('🔎 [SANCTIONS PAGE] Search query: "$query"');

    setState(() {
      if (query.isEmpty) {
        _filteredIndividuals = List<Individual>.from(_allIndividuals);

        debugPrint(
          '🔎 [SANCTIONS PAGE] Search cleared. '
          'Showing ${_filteredIndividuals.length}',
        );

        return;
      }

      _filteredIndividuals = _allIndividuals.where((individual) {
        final String aliases = individual.aliases
            .map((alias) => alias.name)
            .join(' ')
            .toLowerCase();

        final String designations = individual.designations
            .join(' ')
            .toLowerCase();

        return individual.dataId.toString().contains(query) ||
            individual.fullName.toLowerCase().contains(query) ||
            individual.referenceNumber.toLowerCase().contains(query) ||
            individual.unListType.toLowerCase().contains(query) ||
            individual.nationality.toLowerCase().contains(query) ||
            aliases.contains(query) ||
            designations.contains(query);
      }).toList();

      debugPrint(
        '🔎 [SANCTIONS PAGE] '
        'Matching results: ${_filteredIndividuals.length}',
      );
    });
  }

  @override
  void dispose() {
    debugPrint('📄 [SANCTIONS PAGE] dispose called');

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🏗️ [SANCTIONS PAGE] build called '
      '| loading=$_isLoading '
      '| error=$_errorMessage '
      '| records=${_filteredIndividuals.length}',
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              _search(value);
            },
            decoration: InputDecoration(
              hintText: 'Search by ID, name or reference number',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        debugPrint(
                          '🧹 [SANCTIONS PAGE] '
                          'Clear search pressed',
                        );

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
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing ${_filteredIndividuals.length} '
                    'of $_totalRecords records',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _loadIndividuals,
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
    debugPrint(
      '🧱 [SANCTIONS PAGE] _buildContent '
      '| loading=$_isLoading '
      '| error=$_errorMessage',
    );

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Loading individuals...'),
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
                'Unable to load individuals',
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
                  debugPrint('🔁 [SANCTIONS PAGE] Try Again pressed');

                  _loadIndividuals();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredIndividuals.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadIndividuals,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Icon(
              Icons.person_search_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Center(child: Text('No matching individuals found.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadIndividuals(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filteredIndividuals.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          if (index == _filteredIndividuals.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final Individual individual = _filteredIndividuals[index];

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
                individual.fullName.isEmpty
                    ? 'Unnamed individual'
                    : individual.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (individual.referenceNumber.isNotEmpty)
                      Text('Reference: ${individual.referenceNumber}'),
                    if (individual.unListType.isNotEmpty)
                      Text('List: ${individual.unListType}'),
                  ],
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonDetailsPage(
                      dataId: individual.dataId,
                      initialIndividual: individual,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
