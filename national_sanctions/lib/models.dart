class SanctionRecord {
  final String id;
  final String name;
  final String type;
  final String nationality;
  final String dateOfBirth;
  final String listedOn;
  final String referenceNumber;
  final String reason;
  final String source;

  const SanctionRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.nationality,
    required this.dateOfBirth,
    required this.listedOn,
    required this.referenceNumber,
    required this.reason,
    required this.source,
  });
}
