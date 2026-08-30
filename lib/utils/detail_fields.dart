import 'package:url_launcher/url_launcher.dart';

class DetailFields {
  DetailFields._();

  static const Set<String> sequenceKeys = {
    'ALIAS_SEQ',
    'ADDR_SEQ',
    'DOB_SEQ',
    'DOC_SEQ',
    'POB_SEQ',
    'VALUE_SEQ',
    'SOURCE_FILE_ID',
  };

  static bool hasValue(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is List || value is Map) {
      return true;
    }

    final String text = value.toString().trim();

    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

  static String text(dynamic value) {
    if (value == null) {
      return '';
    }

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }

  static String date(dynamic value) {
    final String raw = text(value);

    if (raw.isEmpty) {
      return '';
    }

    final DateTime? date = DateTime.tryParse(raw);

    if (date == null) {
      return raw;
    }

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  static String joinParts(List<String> parts) {
    return parts
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(', ');
  }

  static bool isHttpUrl(String value) {
    final Uri? uri = Uri.tryParse(value.trim());

    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static Future<void> openExternalUrl(String value) async {
    final Uri? uri = Uri.tryParse(value.trim());

    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String humanizeKey(String key) {
    const Map<String, String> labels = {
      'ALIAS_NAME': 'Name',
      'QUALITY': 'Quality',
      'DATE_VAL': 'Date',
      'TYPE_OF_DATE': 'Type',
      'FROM_YEAR': 'From year',
      'TO_YEAR': 'To year',
      'TYPE_OF_DOCUMENT': 'Type',
      'DOC_NUMBER': 'Number',
      'COUNTRY_OF_ISSUE': 'Country of issue',
      'STATE_PROVINCE': 'State / province',
      'ATTR_NAME': 'Name',
      'ATTR_VALUE': 'Value',
      'COMMENTS1': 'Comments',
      'NAME_ORIGINAL_SCRIPT': 'Original-script name',
      'UN_LIST_TYPE': 'List type',
      'REFERENCE_NUMBER': 'Reference number',
      'HAS_INTERPOL_LINK': 'Interpol notice',
      'INTERPOL_LINK': 'Interpol notice',
      'VERSIONNUM': 'Version',
      'DATAID': 'Record ID',
      'CREATED_DATE': 'Created',
      'LAST_UPDATED_DATE': 'Last updated',
      'LS': 'List serial',
      'SENTESCE_DATE': 'Sentence date',
      'SENTENCE_DATE': 'Sentence date',
      'NICKNAME_OR_ALIAS': 'Nickname / alias',
      'ENTITY_NAME_IN_ARABIC': 'Arabic name',
      'ENTITY_NAME_IN_ENGLISH': 'English name',
      'ENTITY_DESCRIPTION': 'Description',
      'ENTITY_TYPE': 'Entity type',
      'LEGAL_STATUS': 'Legal status',
      'RECORDED_NAME': 'Recorded name',
      'CREATED_BY': 'Created by',
      'UPDATED_BY': 'Updated by',
      'NEED_FEEDBACK': 'Needs feedback',
      'INDIVIDUAL_OR_ENTITY': 'Record type',
      'REQ_ENTITY': 'Requesting entity',
      'PRIORITY_LEVEL': 'Priority level',
      'SOURCE_LISTING_DATE': 'Source listing date',
      'CLASSIFICATION_DATE': 'Classification date',
      'REQUEST_DATE': 'Request date',
    };

    final String mapped = labels[key] ?? '';

    if (mapped.isNotEmpty) {
      return mapped;
    }

    return key
        .toLowerCase()
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static List<Map<String, dynamic>> mapList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
