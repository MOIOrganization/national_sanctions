import '../models.dart';

class SanctionsService {
  Future<List<SanctionRecord>> getSanctionRecords() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const [
      SanctionRecord(
        id: '1',
        name: 'Sample Person One',
        type: 'Individual',
        nationality: 'Not specified',
        dateOfBirth: 'Not specified',
        listedOn: '10 January 2024',
        referenceNumber: 'UN-SAMPLE-001',
        reason:
            'Sample record for application development. Replace this text with official information.',
        source: 'United Nations Sanctions List',
      ),
      SanctionRecord(
        id: '2',
        name: 'Sample Entity',
        type: 'Entity',
        nationality: 'Not applicable',
        dateOfBirth: 'Not applicable',
        listedOn: '15 February 2024',
        referenceNumber: 'UN-SAMPLE-002',
        reason: 'Sample entity record for application development and testing.',
        source: 'United Nations Sanctions List',
      ),
    ];
  }
}
