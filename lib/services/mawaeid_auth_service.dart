import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'mawaeid_response_parser.dart';

export 'mawaeid_response_parser.dart'
    show MawaeidCprVerificationError, MawaeidPersonInfo;

class MawaeidAuthService {
  MawaeidAuthService({
    http.Client? client,
    MawaeidResponseParser parser = const MawaeidResponseParser(),
    Duration timeout = const Duration(seconds: 30),
    String? appVersion,
  }) : _client = client,
       _parser = parser,
       _timeout = timeout,
       _appVersion = appVersion ?? '1.0.0';

  static const String _baseUrl =
      'https://mob.mawaid.org:7011/apex/qms/promaw/ssnChk/';

  final http.Client? _client;
  final MawaeidResponseParser _parser;
  final Duration _timeout;
  final String _appVersion;

  /// Mawaeid transaction id for this authentication attempt only.
  /// This is not the application's signed-in session.
  String? _ssnId;

  // ============================================================
  // PUBLIC ORCHESTRATION
  // ============================================================

  Future<MawaeidAuthResult> authenticate({
    required String cpr,
    required String blockNo,
    required String expiryDisplayDate,
    required String mobile,
    String userId = '',
  }) async {
    final String expiry = formatExpiryForMawaeid(expiryDisplayDate);

    await bootstrapSession(userId: userId);

    await verifyCpr(
      cpr: cpr,
      blockNo: blockNo,
      expiry: expiry,
    );

    // Do not call INS_MOB_CUSTOMERS_MAWAEID_AGE_DISABILITY.
    // That Mawaeid procedure sends its own SMS OTP. After CPR
    // verification succeeds, the existing application OTP flow
    // (mob_un_login / un_chk_valid_otp) is the only OTP sender.
    return const MawaeidAuthResult(insertedStatus: '1');
  }

  // ============================================================
  // STEP 0 — SESSION BOOTSTRAP
  // ============================================================

  Future<String> bootstrapSession({String userId = ''}) async {
    debugPrint('[MAWAEID] Bootstrap started');

    final List<String> params = await _deviceParams(userId: userId);
    final dynamic decoded = await _callFunction(
      funcName: 'LOG_EXT_MOB_DATA',
      params: params,
    );

    final Map<String, dynamic>? record = _parser.firstJsonRecord(decoded);

    if (record == null) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.bootstrapFailed,
      );
    }

    final String inserted = _parser.readField(record, const ['P_INSERTED']);
    final String trxId = _parser.readField(record, const [
      'V_TRX_ID',
      'SSN_ID',
    ]);

    if (inserted != '1' || trxId.isEmpty) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.bootstrapFailed,
      );
    }

    _ssnId = trxId;
    debugPrint('[MAWAEID] Bootstrap completed');

    return trxId;
  }

  // ============================================================
  // STEP 2 — CPR VERIFICATION
  // ============================================================

  Future<MawaeidPersonInfo> verifyCpr({
    required String cpr,
    required String blockNo,
    required String expiry,
  }) async {
    final String ssnId = _requireSsnId();

    debugPrint('[MAWAEID] CPR verification started');

    final String payload = await _requestPayload(
      funcName: 'VERIFY_USER_CPR_AGE_AGENT_DISABILITY_CHK',
      params: [ssnId, cpr, blockNo, expiry],
    );

    final String xml = _parser.extractXml(payload);

    if (xml.isEmpty) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.malformedResponse,
      );
    }

    if (_parser.containsPersonNameInformation(xml)) {
      final MawaeidPersonInfo person = _parser.parsePersonInfo(xml);

      debugPrint('[MAWAEID] CPR verification completed');

      return person;
    }

    final MawaeidCprVerificationError? error = _parser.cprVerificationError(
      xml,
    );

    switch (error) {
      case MawaeidCprVerificationError.invalidCpr:
        throw const MawaeidAuthException(code: MawaeidAuthErrorCode.invalidCpr);
      case MawaeidCprVerificationError.invalidExpiry:
        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.invalidExpiry,
        );
      case MawaeidCprVerificationError.invalidBlock:
        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.invalidBlock,
        );
      case MawaeidCprVerificationError.underAge:
        throw const MawaeidAuthException(code: MawaeidAuthErrorCode.underAge);
      case null:
        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.malformedResponse,
        );
    }
  }

  // ============================================================
  // REGISTER / UPSERT (not used by login)
  //
  // This Mawaeid procedure sends an SMS OTP. Login must not call it.
  // The application OTP is sent only by mob_un_login.
  // ============================================================

  Future<MawaeidAuthResult> registerOrUpdateUser({
    required MawaeidPersonInfo person,
    required String mobile,
    required String cpr,
    required String blockNo,
    required String expiry,
  }) async {
    final String ssnId = _requireSsnId();
    final String mobileWithCountryCode = bahrainMobile(mobile);

    debugPrint('[MAWAEID] User registration started');

    final dynamic decoded = await _callFunction(
      funcName: 'INS_MOB_CUSTOMERS_MAWAEID_AGE_DISABILITY',
      params: [
        ssnId,
        person.paramSafeArabicName,
        person.paramSafeEnglishName,
        mobileWithCountryCode,
        cpr,
        person.isClearingAgent,
        blockNo,
        expiry,
        person.isDisabled,
        person.age,
      ],
    );

    final Map<String, dynamic>? record = _parser.firstJsonRecord(decoded);

    if (record == null) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.registrationFailed,
      );
    }

    final String inserted = _parser.readField(record, const ['P_INSERTED']);

    switch (inserted) {
      case '1':
      case '3':
        debugPrint('[MAWAEID] User registration completed');
        return MawaeidAuthResult(insertedStatus: inserted);
      case '2':
        debugPrint('[MAWAEID] User registration completed with warning');
        return const MawaeidAuthResult(insertedStatus: '2');
      case '999':
        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.otpAttemptsExhausted,
        );
      default:
        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.registrationFailed,
        );
    }
  }

  // ============================================================
  // DATE / MOBILE HELPERS
  // ============================================================

  static String formatExpiryForMawaeid(String displayDate) {
    final String trimmed = displayDate.trim();
    final List<String> parts = trimmed.split('/');

    if (parts.length != 3) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.invalidExpiry,
      );
    }

    final int? day = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.invalidExpiry,
      );
    }

    try {
      final DateTime parsed = DateTime(year, month, day);

      if (parsed.year != year || parsed.month != month || parsed.day != day) {
        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.invalidExpiry,
        );
      }
    } on MawaeidAuthException {
      rethrow;
    } catch (_) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.invalidExpiry,
      );
    }

    final String monthText = month.toString().padLeft(2, '0');
    final String dayText = day.toString().padLeft(2, '0');

    return '$year-$monthText-$dayText';
  }

  static String bahrainMobile(String eightDigitMobile) {
    return '973${eightDigitMobile.trim()}';
  }

  // ============================================================
  // HTTP
  // ============================================================

  Future<dynamic> _callFunction({
    required String funcName,
    required List<String> params,
  }) async {
    final String payload = await _requestPayload(
      funcName: funcName,
      params: params,
    );

    final dynamic decoded = _parser.tryParseJson(payload);

    if (decoded == null) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.malformedResponse,
      );
    }

    return decoded;
  }

  Future<String> _requestPayload({
    required String funcName,
    required List<String> params,
  }) async {
    final Uri url = Uri.parse(_baseUrl).replace(
      queryParameters: {'funcName': funcName, 'params': params.join(',')},
    );

    try {
      final http.Response response = await _sendGet(url).timeout(_timeout);
      final String body = _decodeBody(response);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[MAWAEID] Request failed with HTTP ${response.statusCode}');

        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.serverUnavailable,
        );
      }

      final String payload = _parser.unwrapPayload(body);

      if (payload.isEmpty) {
        throw const MawaeidAuthException(
          code: MawaeidAuthErrorCode.malformedResponse,
        );
      }

      return payload;
    } on MawaeidAuthException {
      rethrow;
    } on TimeoutException {
      debugPrint('[MAWAEID] Request timed out');

      throw const MawaeidAuthException(code: MawaeidAuthErrorCode.timeout);
    } on http.ClientException {
      debugPrint('[MAWAEID] Network request failed');

      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.serverUnavailable,
      );
    } on Error {
      rethrow;
    } catch (error) {
      debugPrint('[MAWAEID] Unexpected request error');

      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.serverUnavailable,
      );
    }
  }

  Future<http.Response> _sendGet(Uri url) {
    final http.Client? client = _client;

    if (client != null) {
      return client.get(url);
    }

    return http.get(url);
  }

  String _decodeBody(http.Response response) {
    try {
      return utf8.decode(response.bodyBytes);
    } catch (_) {
      return response.body;
    }
  }

  Future<List<String>> _deviceParams({required String userId}) async {
    return [
      'Mersad',
      'flutter',
      _platformName(),
      'mersad',
      '',
      '',
      '',
      '',
      '',
      userId,
      '',
      '',
      await _fcmToken(),
      _appVersion,
    ];
  }

  String _platformName() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      default:
        return defaultTargetPlatform.name;
    }
  }

  Future<String> _fcmToken() async {
    if (kIsWeb) {
      return '';
    }

    try {
      return await FirebaseMessaging.instance.getToken() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _requireSsnId() {
    final String? ssnId = _ssnId;

    if (ssnId == null || ssnId.isEmpty) {
      throw const MawaeidAuthException(
        code: MawaeidAuthErrorCode.bootstrapFailed,
      );
    }

    return ssnId;
  }
}

class MawaeidAuthResult {
  const MawaeidAuthResult({required this.insertedStatus});

  final String insertedStatus;

  bool get requiresDifferentMobileWarning => insertedStatus == '2';

  bool get canContinueToExistingOtp =>
      insertedStatus == '1' || insertedStatus == '2' || insertedStatus == '3';
}

enum MawaeidAuthErrorCode {
  bootstrapFailed,
  invalidCpr,
  invalidExpiry,
  invalidBlock,
  underAge,
  otpAttemptsExhausted,
  registrationFailed,
  serverUnavailable,
  timeout,
  malformedResponse,
}

class MawaeidAuthException implements Exception {
  const MawaeidAuthException({required this.code});

  final MawaeidAuthErrorCode code;

  @override
  String toString() => 'MawaeidAuthException($code)';
}
