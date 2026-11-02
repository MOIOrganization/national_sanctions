import 'dart:convert';

/// Parses Mawaeid HTML-wrapped JSON and SOAP/XML payloads without [eval].
class MawaeidResponseParser {
  const MawaeidResponseParser();

  /// Unwraps HTML if present and returns the inner payload text.
  String unwrapPayload(String rawResponse) {
    final String trimmed = rawResponse.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    final RegExpMatch? bodyMatch = RegExp(
      r'<body[^>]*>([\s\S]*?)</body>',
      caseSensitive: false,
    ).firstMatch(trimmed);

    if (bodyMatch != null) {
      return (bodyMatch.group(1) ?? '').trim();
    }

    return trimmed;
  }

  /// Parses a JSON object/list payload. Returns null when the text is not JSON.
  dynamic tryParseJson(String payload) {
    final String trimmed = payload.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    if (!(trimmed.startsWith('[') || trimmed.startsWith('{'))) {
      return null;
    }

    try {
      return jsonDecode(trimmed);
    } on FormatException {
      return null;
    }
  }

  Map<String, dynamic>? firstJsonRecord(dynamic decoded) {
    if (decoded is List && decoded.isNotEmpty) {
      final dynamic first = decoded.first;

      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }

      return null;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return null;
  }

  String readField(Map<String, dynamic> record, List<String> keys) {
    for (final String key in keys) {
      if (!record.containsKey(key)) {
        continue;
      }

      final String value = record[key]?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  /// SOAP/XML may be wrapped as `[<xml>...]` which is not valid JSON.
  String extractXml(String payload) {
    String text = payload.trim();

    if (text.isEmpty) {
      return '';
    }

    if (text.startsWith('[') && text.endsWith(']') && text.contains('<')) {
      text = text.substring(1, text.length - 1).trim();
    }

    final dynamic decoded = tryParseJson(payload);

    if (decoded is List && decoded.isNotEmpty && decoded.first is String) {
      text = decoded.first.toString().trim();
    }

    return text;
  }

  bool containsPersonNameInformation(String xml) {
    return RegExp(
      r'<([A-Za-z0-9._-]+:)?PersonNameInformation[\s>]',
      caseSensitive: false,
    ).hasMatch(xml);
  }

  String xmlTag(String xml, String tagName) {
    final String escaped = RegExp.escape(tagName);
    final RegExp pattern = RegExp(
      '<(?:[A-Za-z0-9._-]+:)?$escaped(?:\\s[^>]*)?>([\\s\\S]*?)</(?:[A-Za-z0-9._-]+:)?$escaped>',
      caseSensitive: false,
    );

    final RegExpMatch? match = pattern.firstMatch(xml);

    if (match == null) {
      return '';
    }

    return _decodeXmlValue(match.group(1) ?? '');
  }

  String soapMessage(String xml) {
    final String message = xmlTag(xml, 'message');

    if (message.isNotEmpty) {
      return message;
    }

    return xmlTag(xml, 'faultstring');
  }

  MawaeidCprVerificationError? cprVerificationError(String xml) {
    final String message = soapMessage(xml);
    final String combined = '$message\n$xml';
    final String normalized = combined.toLowerCase();

    if (combined.contains('NO_RECORD_FOUND') ||
        normalized.contains('no_record_found') ||
        normalized.contains('no record found')) {
      return MawaeidCprVerificationError.invalidCpr;
    }

    if (RegExp(r'under\s*age', caseSensitive: false).hasMatch(combined)) {
      return MawaeidCprVerificationError.underAge;
    }

    final String specific = message.toLowerCase();

    if (specific.contains('block')) {
      return MawaeidCprVerificationError.invalidBlock;
    }

    if (specific.contains('date') ||
        specific.contains('expiry') ||
        specific.contains('expdt')) {
      return MawaeidCprVerificationError.invalidExpiry;
    }

    if (normalized.contains('unmarshalling error')) {
      return MawaeidCprVerificationError.invalidExpiry;
    }

    return null;
  }

  MawaeidPersonInfo parsePersonInfo(String xml) {
    return MawaeidPersonInfo(
      englishFullName: xmlTag(xml, 'EnglishFullName'),
      arabicFullName: xmlTag(xml, 'ArabicFullName'),
      age: xmlTag(xml, 'Age'),
      isClearingAgent: xmlTag(xml, 'IsClearingAgent'),
      isDisabled: xmlTag(xml, 'IsDisabled'),
    );
  }

  String _decodeXmlValue(String raw) {
    String value = raw.trim();

    final RegExpMatch? cdata = RegExp(
      r'<!\[CDATA\[([\s\S]*?)\]\]>',
    ).firstMatch(value);

    if (cdata != null) {
      value = (cdata.group(1) ?? '').trim();
    }

    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

enum MawaeidCprVerificationError {
  invalidCpr,
  invalidExpiry,
  invalidBlock,
  underAge,
}

class MawaeidPersonInfo {
  const MawaeidPersonInfo({
    required this.englishFullName,
    required this.arabicFullName,
    required this.age,
    required this.isClearingAgent,
    required this.isDisabled,
  });

  final String englishFullName;
  final String arabicFullName;
  final String age;
  final String isClearingAgent;
  final String isDisabled;

  String get paramSafeArabicName => _stripSeparators(arabicFullName);

  String get paramSafeEnglishName => _stripSeparators(englishFullName);

  String _stripSeparators(String value) {
    return value.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
