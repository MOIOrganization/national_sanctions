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

  @override
  void initState() {
    super.initState();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('📄 [SANCTIONS PAGE] initState called');
    debugPrint('📄 [SANCTIONS PAGE] Starting API loading');
    debugPrint('========================================');

    _loadIndividuals();
  }

  Future<void> _loadIndividuals() async {
    debugPrint('');
    debugPrint('🔄 [SANCTIONS PAGE] _loadIndividuals started');

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      debugPrint('🔄 [SANCTIONS PAGE] Calling getAllIndividuals...');

      final IndividualResponse response = await _service.getAllIndividuals(
        offset: 0,
        // limit: 1000,
        limit: 50,
        language: 'ARAB',
      );

      debugPrint('✅ [SANCTIONS PAGE] API call completed');

      debugPrint(
        '✅ [SANCTIONS PAGE] '
        'Total on server: ${response.totalRecords}',
      );

      debugPrint(
        '✅ [SANCTIONS PAGE] '
        'Received now: ${response.individuals.length}',
      );

      if (!mounted) {
        debugPrint('⚠️ [SANCTIONS PAGE] Widget is no longer mounted');

        return;
      }

      setState(() {
        _allIndividuals = response.individuals;
        _filteredIndividuals = response.individuals;
        _totalRecords = response.totalRecords;
        _isLoading = false;
      });

      debugPrint('✅ [SANCTIONS PAGE] State updated successfully');
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint('❌ [SANCTIONS PAGE] Loading failed');
      debugPrint('❌ [SANCTIONS PAGE] Error: $error');
      debugPrint('❌ [SANCTIONS PAGE] Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
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
      onRefresh: _loadIndividuals,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filteredIndividuals.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          final Individual individual = _filteredIndividuals[index];

          if (index < 3) {
            debugPrint(
              '🪪 [SANCTIONS PAGE] Building card '
              '$index: ${individual.fullName}',
            );
          }

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
                      Text(
                        'Reference: '
                        '${individual.referenceNumber}',
                      ),
                    if (individual.unListType.isNotEmpty)
                      Text('List: ${individual.unListType}'),
                    if (individual.nationality.isNotEmpty)
                      Text(
                        'Nationality: '
                        '${individual.nationality}',
                      ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                debugPrint('');
                debugPrint('👆 [SANCTIONS PAGE] Record pressed');
                debugPrint(
                  '👆 [SANCTIONS PAGE] '
                  'Data ID: ${individual.dataId}',
                );
                debugPrint(
                  '👆 [SANCTIONS PAGE] '
                  'Name: ${individual.fullName}',
                );
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
