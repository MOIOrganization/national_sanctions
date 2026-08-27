import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models.dart';

class SanctionsService {
  static const String _baseUrl =
      'https://barq.interior.gov.bh/MobUNApiGateway/api';

  static const Duration _timeout = Duration(seconds: 30);

  String? _sessionId;

  // ============================================================
  // 1. GET SESSION ID
  // ============================================================

  Future<String> getSessionId() async {
    final Uri url = Uri.parse('$_baseUrl/mob_get_session_id');

    debugPrint('');
    debugPrint('==============================================');
    debugPrint('🟦 [SESSION API] URL: $url');
    debugPrint('🟦 [SESSION API] Header session_id: 1');
    debugPrint('🟦 [SESSION API] Body: {}');

    final http.Response response = await http
        .post(
          url,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'session_id': '1',
          },
          body: '{}',
        )
        .timeout(_timeout);

    debugPrint('🟨 [SESSION API] Status: ${response.statusCode}');

    debugPrint('🟨 [SESSION API] Response: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SanctionsApiException(
        message: 'Unable to retrieve session ID',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const SanctionsApiException(
        message: 'Unexpected session response format',
      );
    }

    final dynamic data = decoded['DATA'];

    if (data is! List || data.isEmpty) {
      throw const SanctionsApiException(
        message: 'Session response DATA is empty',
      );
    }

    final dynamic firstItem = data.first;

    if (firstItem is! Map) {
      throw const SanctionsApiException(
        message: 'Invalid session response record',
      );
    }

    final String sessionId = firstItem['SESSION_ID']?.toString().trim() ?? '';

    if (sessionId.isEmpty) {
      throw const SanctionsApiException(message: 'SESSION_ID was not returned');
    }

    _sessionId = sessionId;

    debugPrint('✅ [SESSION API] Session received: $sessionId');

    return sessionId;
  }

  // ============================================================
  // CHECK OR CREATE SESSION
  // ============================================================

  Future<String> _ensureSessionId() async {
    final String? savedSessionId = _sessionId;

    if (savedSessionId != null && savedSessionId.isNotEmpty) {
      debugPrint('🟩 [SESSION] Using existing session ID: $savedSessionId');

      return savedSessionId;
    }

    debugPrint('🟧 [SESSION] No session ID found. Requesting a new one...');

    return getSessionId();
  }

  // ============================================================
  // SESSION HEADERS
  // ============================================================

  Map<String, String> _headersWithSession(String sessionId) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': sessionId,
      'session_id': sessionId,
    };
  }

  // ============================================================
  // 2. LOGIN
  // ============================================================

  Future<Map<String, dynamic>> login({
    required String cpr,
    required String blockNo,
    required String expireDate,
  }) async {
    final Map<String, dynamic> responseJson = await _postWithSession(
      endpoint: 'mob_un_login',
      requestName: 'LOGIN',
      body: {
        'cpr': cpr,
        'block_no': blockNo,
        'expire_date': expireDate,
      },
    );

    if (_isLoginFailure(responseJson)) {
      throw SanctionsApiException(
        message: _loginErrorMessage(responseJson),
        responseBody: jsonEncode(responseJson),
      );
    }

    debugPrint('✅ [LOGIN] Login completed successfully');

    return responseJson;
  }

  bool _isLoginFailure(Map<String, dynamic> responseJson) {
    final String status = _firstNonEmptyString([
      responseJson['STATUS'],
      responseJson['status'],
      responseJson['RESULT'],
      responseJson['result'],
    ]).toUpperCase();

    if (status.isNotEmpty &&
        (status == '0' ||
            status == 'ERROR' ||
            status == 'FAILED' ||
            status == 'FAIL' ||
            status == 'FALSE')) {
      return true;
    }

    final String message = _firstNonEmptyString([
      responseJson['MESSAGE'],
      responseJson['message'],
      responseJson['ERROR'],
      responseJson['error'],
    ]).toLowerCase();

    if (message.contains('invalid') ||
        message.contains('failed') ||
        message.contains('not found') ||
        message.contains('incorrect')) {
      return true;
    }

    return false;
  }

  String _loginErrorMessage(Map<String, dynamic> responseJson) {
    final String message = _firstNonEmptyString([
      responseJson['MESSAGE'],
      responseJson['message'],
      responseJson['ERROR'],
      responseJson['error'],
    ]);

    if (message.isNotEmpty) {
      return message;
    }

    return 'Login details could not be verified.';
  }

  String _firstNonEmptyString(List<dynamic> values) {
    for (final dynamic value in values) {
      final String text = value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  // ============================================================
  // 3. GET ALL INDIVIDUALS
  // ============================================================

  Future<IndividualResponse> getAllIndividuals({
    int offset = 0,
    int limit = 50,
    // int limit = 1000,
    String language = 'ARAB',
  }) async {
    final Map<String, dynamic> responseJson = await _postWithSession(
      endpoint: 'mob_bl_individuals_get_all',
      requestName: 'GET ALL INDIVIDUALS',
      body: {
        'offset': offset.toString(),
        'limit': limit.toString(),
        'lang': language,
      },
    );

    final IndividualResponse result = IndividualResponse.fromJson(responseJson);

    debugPrint(
      '✅ [GET ALL INDIVIDUALS] Total records: '
      '${result.totalRecords}',
    );

    debugPrint(
      '✅ [GET ALL INDIVIDUALS] Returned records: '
      '${result.individuals.length}',
    );

    for (final Individual individual in result.individuals.take(5)) {
      debugPrint(
        '👤 ID: ${individual.dataId}'
        ' | Name: ${individual.fullName}'
        ' | Reference: ${individual.referenceNumber}',
      );
    }

    return result;
  }

  // ============================================================
  // 3. GET INDIVIDUAL BY ID
  // ============================================================

  Future<Individual> getIndividualById({
    required int dataId,
    String language = 'ARAB',
  }) async {
    final Map<String, dynamic> responseJson = await _postWithSession(
      endpoint: 'mob_bl_individuals_get_by_id',
      requestName: 'GET INDIVIDUAL BY ID',
      body: {'dataid': dataId.toString(), 'lang': language},
    );

    final dynamic data = responseJson['DATA'];

    if (data is! Map) {
      throw const SanctionsApiException(
        message: 'Individual DATA was not returned',
      );
    }

    final Individual individual = Individual.fromJson(
      Map<String, dynamic>.from(data),
    );

    debugPrint(
      '✅ [GET INDIVIDUAL BY ID] Loaded: '
      '${individual.fullName}',
    );

    return individual;
  }

  // ============================================================
  // 4. GET ALL ENTITIES
  //
  // The API endpoint uses "entites", not "entities".
  // This method currently returns the JSON response directly.
  // ============================================================

  Future<Map<String, dynamic>> getAllEntities({
    int offset = 0,
    // int limit = 1000,
    int limit = 50,
    String language = 'ARAB',
  }) async {
    final Map<String, dynamic> responseJson = await _postWithSession(
      endpoint: 'mob_bl_entites_get_all',
      requestName: 'GET ALL ENTITIES',
      body: {
        'offset': offset.toString(),
        'limit': limit.toString(),
        'lang': language,
      },
    );

    final dynamic data = responseJson['DATA'];

    final int recordCount = data is List ? data.length : 0;

    debugPrint(
      '✅ [GET ALL ENTITIES] Total records: '
      '${responseJson['total_records']}',
    );

    debugPrint(
      '✅ [GET ALL ENTITIES] Returned records: '
      '$recordCount',
    );

    return responseJson;
  }

  // ============================================================
  // 5. GET ENTITY BY ID
  //
  // The API endpoint uses "entites", not "entities".
  // This method currently returns the entity DATA as JSON.
  // ============================================================

  Future<Map<String, dynamic>> getEntityById({
    required int dataId,
    String language = 'ARAB',
  }) async {
    final Map<String, dynamic> responseJson = await _postWithSession(
      endpoint: 'mob_bl_entites_get_by_id',
      requestName: 'GET ENTITY BY ID',
      body: {'dataid': dataId.toString(), 'lang': language},
    );

    final dynamic data = responseJson['DATA'];

    if (data is! Map) {
      throw const SanctionsApiException(
        message: 'Entity DATA was not returned',
      );
    }

    final Map<String, dynamic> entity = Map<String, dynamic>.from(data);

    debugPrint(
      '✅ [GET ENTITY BY ID] Loaded: '
      '${entity['FIRST_NAME'] ?? 'Unknown entity'}',
    );

    return entity;
  }

  // ============================================================
  // 6. GET NATIONAL LIST PERSONS
  // ============================================================

  Future<Map<String, dynamic>> getNationalPersons({
    int offset = 0,
    int limit = 50,
    String language = 'ARAB',
  }) async {
    final Map<String, dynamic> responseJson = await _postWithSession(
      endpoint: 'bl_get_nl_persons',
      requestName: 'GET NATIONAL PERSONS',
      body: {
        'offset': offset.toString(),
        'limit': limit.toString(),
        'lang': language,
      },
    );

    final dynamic data = responseJson['DATA'];

    final int recordCount = data is List ? data.length : 0;

    debugPrint(
      '✅ [GET NATIONAL PERSONS] Total records: '
      '${responseJson['total_records']}',
    );

    debugPrint(
      '✅ [GET NATIONAL PERSONS] Returned records: '
      '$recordCount',
    );

    if (data is List) {
      for (final item in data.take(5)) {
        if (item is Map) {
          debugPrint(
            '👤 [NATIONAL PERSON] '
            'ID=${item['ID']} '
            '| Name=${item['PERSON_NAME_IN_ARABIC'] ?? item['PERSON_NAME_IN_ENGLISH'] ?? ''}',
          );
        }
      }
    }

    return responseJson;
  }

  // ============================================================
  // 7. GET NATIONAL LIST ENTITIES
  // ============================================================

  Future<Map<String, dynamic>> getNationalEntities({
    int offset = 0,
    int limit = 50,
    String language = 'ARAB',
  }) async {
    final Map<String, dynamic> responseJson = await _postWithSession(
      endpoint: 'bl_get_nl_entities',
      requestName: 'GET NATIONAL ENTITIES',
      body: {
        'offset': offset.toString(),
        'limit': limit.toString(),
        'lang': language,
      },
    );

    final dynamic data = responseJson['DATA'];

    final int recordCount = data is List ? data.length : 0;

    debugPrint(
      '✅ [GET NATIONAL ENTITIES] Total records: '
      '${responseJson['total_records']}',
    );

    debugPrint(
      '✅ [GET NATIONAL ENTITIES] Returned records: '
      '$recordCount',
    );

    if (data is List) {
      for (final item in data.take(5)) {
        if (item is Map) {
          debugPrint(
            '🏢 [NATIONAL ENTITY] '
            'ID=${item['ID']} '
            '| Arabic=${item['ENTITY_NAME_IN_ARABIC'] ?? ''} '
            '| English=${item['ENTITY_NAME_IN_ENGLISH'] ?? ''}',
          );
        }
      }
    }

    return responseJson;
  }

  // ============================================================
  // COMMON POST REQUEST
  // ============================================================

  Future<Map<String, dynamic>> _postWithSession({
    required String endpoint,
    required String requestName,
    required Map<String, dynamic> body,
    bool allowSessionRetry = true,
  }) async {
    final String sessionId = await _ensureSessionId();

    final Uri url = Uri.parse('$_baseUrl/$endpoint');

    debugPrint('');
    debugPrint('==============================================');
    debugPrint('🟦 [$requestName] Starting request');
    debugPrint('🟦 [$requestName] Method: POST');
    debugPrint('🟦 [$requestName] URL: $url');
    debugPrint('🟦 [$requestName] Session ID: $sessionId');
    debugPrint('🟦 [$requestName] Body: ${jsonEncode(body)}');

    try {
      final http.Response response = await http
          .post(
            url,
            headers: _headersWithSession(sessionId),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      debugPrint('🟨 [$requestName] Status: ${response.statusCode}');

      debugPrint(
        '🟨 [$requestName] Response length: '
        '${response.body.length}',
      );

      debugPrint('🟨 [$requestName] Response: ${response.body}');

      if ((response.statusCode == 401 || response.statusCode == 403) &&
          allowSessionRetry) {
        debugPrint(
          '🟧 [$requestName] Session rejected. '
          'Requesting a new session...',
        );

        _sessionId = null;

        await getSessionId();

        return _postWithSession(
          endpoint: endpoint,
          requestName: '$requestName RETRY',
          body: body,
          allowSessionRetry: false,
        );
      }

      if (!_isSuccessful(response.statusCode)) {
        throw SanctionsApiException(
          message: '$requestName failed',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      final dynamic decoded = _decodeResponse(
        response.body,
        requestName: requestName,
      );

      if (decoded is! Map<String, dynamic>) {
        throw SanctionsApiException(
          message: 'Unexpected $requestName response format',
        );
      }

      debugPrint('✅ [$requestName] Request completed');
      debugPrint('==============================================');
      debugPrint('');

      return decoded;
    } catch (error, stackTrace) {
      debugPrint('❌ [$requestName] Error: $error');
      debugPrint('❌ [$requestName] Stack trace: $stackTrace');

      rethrow;
    }
  }

  // ============================================================
  // JSON DECODER
  // ============================================================

  dynamic _decodeResponse(String responseBody, {required String requestName}) {
    try {
      return jsonDecode(responseBody);
    } on FormatException catch (error) {
      debugPrint('❌ [$requestName] JSON parsing error: $error');

      throw SanctionsApiException(
        message: '$requestName returned invalid JSON',
        responseBody: responseBody,
      );
    }
  }

  // ============================================================
  // STATUS CHECK
  // ============================================================

  bool _isSuccessful(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // ============================================================
  // CLEAR SESSION
  // ============================================================

  void clearSession() {
    debugPrint('🧹 [SESSION] Session ID cleared');

    _sessionId = null;
  }
}

// ============================================================
// CUSTOM API EXCEPTION
// ============================================================

class SanctionsApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const SanctionsApiException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    final List<String> details = [message];

    if (statusCode != null) {
      details.add('HTTP status: $statusCode');
    }

    if (responseBody != null && responseBody!.trim().isNotEmpty) {
      details.add('Response: $responseBody');
    }

    return details.join('\n');
  }
}
