import 'package:flutter/material.dart';

import '../models.dart';
import '../services/sanctions_service.dart';
import '../theme/app_colors.dart';
import 'person_details_page.dart';

class SanctionsPage extends StatefulWidget {
  const SanctionsPage({super.key});

  @override
  State<SanctionsPage> createState() => _SanctionsPageState();
}

class _SanctionsPageState extends State<SanctionsPage> {
  final SanctionsService _service = SanctionsService();
  final TextEditingController _searchController = TextEditingController();

  List<SanctionRecord> _allRecords = [];
  List<SanctionRecord> _filteredRecords = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await _service.getSanctionRecords();

      if (!mounted) return;

      setState(() {
        _allRecords = records;
        _filteredRecords = records;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to load sanctions records.';
        _isLoading = false;
      });
    }
  }

  void _search(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _allRecords;
        return;
      }

      _filteredRecords = _allRecords.where((record) {
        return record.name.toLowerCase().contains(query) ||
            record.nationality.toLowerCase().contains(query) ||
            record.referenceNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: const InputDecoration(
              hintText: 'Search name or reference number',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_filteredRecords.isEmpty) {
      return const Center(child: Text('No matching records found.'));
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        itemCount: _filteredRecords.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final record = _filteredRecords[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  record.type == 'Individual'
                      ? Icons.person_outline
                      : Icons.business_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                record.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  '${record.type}\nReference: ${record.referenceNumber}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonDetailsPage(record: record),
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
