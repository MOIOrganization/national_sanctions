import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sanctions/services/mawaeid_auth_service.dart';

void main() {
  test('formatExpiryForMawaeid converts DD/MM/YYYY to YYYY-MM-DD', () {
    expect(
      MawaeidAuthService.formatExpiryForMawaeid('10/09/2030'),
      '2030-09-10',
    );
  });

  test('bahrainMobile prefixes 973', () {
    expect(MawaeidAuthService.bahrainMobile('33123456'), '97333123456');
  });

  test('bootstrapSession stores V_TRX_ID when P_INSERTED is 1', () async {
    final MawaeidAuthService service = MawaeidAuthService(
      client: MockClient((request) async {
        expect(request.url.queryParameters['funcName'], 'LOG_EXT_MOB_DATA');
        expect(request.method, 'GET');

        return http.Response(
          '''
<html><body>
[{"P_INSERTED" : "1", "V_TRX_ID" : "11135225_test"}]
</body></html>
''',
          200,
          headers: const {'content-type': 'text/html; charset=UTF-8'},
        );
      }),
    );

    final String ssnId = await service.bootstrapSession();

    expect(ssnId, '11135225_test');
  });

  test('verifyCpr throws invalidCpr for NO_RECORD_FOUND', () async {
    final MawaeidAuthService service = MawaeidAuthService(
      client: MockClient((request) async {
        final String funcName = request.url.queryParameters['funcName'] ?? '';

        if (funcName == 'LOG_EXT_MOB_DATA') {
          return http.Response('[{"P_INSERTED":"1","V_TRX_ID":"ssn-1"}]', 200);
        }

        return http.Response('''
<html><body>
[<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><soap:Fault><faultstring>Block Validation General Exception</faultstring><detail><message>NO_RECORD_FOUND</message></detail></soap:Fault></soap:Body></soap:Envelope>]
</body></html>
''', 200);
      }),
    );

    await service.bootstrapSession();

    expect(
      () => service.verifyCpr(
        cpr: '123456789',
        blockNo: '123',
        expiry: '2030-09-10',
      ),
      throwsA(
        isA<MawaeidAuthException>().having(
          (error) => error.code,
          'code',
          MawaeidAuthErrorCode.invalidCpr,
        ),
      ),
    );
  });

  test('registerOrUpdateUser continues for P_INSERTED 1 and 3', () async {
    Future<MawaeidAuthService> serviceWithInserted(String inserted) async {
      final MawaeidAuthService service = MawaeidAuthService(
        client: MockClient((request) async {
          final String funcName = request.url.queryParameters['funcName'] ?? '';

          if (funcName == 'LOG_EXT_MOB_DATA') {
            return http.Response(
              '[{"P_INSERTED":"1","V_TRX_ID":"ssn-1"}]',
              200,
            );
          }

          expect(
            request.url.queryParameters['params']!.startsWith('ssn-1,'),
            isTrue,
          );

          return http.Response('[{"P_INSERTED":"$inserted"}]', 200);
        }),
      );

      await service.bootstrapSession();

      return service;
    }

    const MawaeidPersonInfo person = MawaeidPersonInfo(
      englishFullName: 'TEST USER',
      arabicFullName: 'مستخدم',
      age: '30',
      isClearingAgent: 'N',
      isDisabled: 'N',
    );

    final MawaeidAuthResult existing = await (await serviceWithInserted('1'))
        .registerOrUpdateUser(
          person: person,
          mobile: '33123456',
          cpr: '123456789',
          blockNo: '123',
          expiry: '2030-09-10',
        );

    expect(existing.canContinueToExistingOtp, isTrue);
    expect(existing.requiresDifferentMobileWarning, isFalse);

    final MawaeidAuthResult created = await (await serviceWithInserted('3'))
        .registerOrUpdateUser(
          person: person,
          mobile: '33123456',
          cpr: '123456789',
          blockNo: '123',
          expiry: '2030-09-10',
        );

    expect(created.insertedStatus, '3');
  });

  test('registerOrUpdateUser warns on 2 and stops on 999', () async {
    const MawaeidPersonInfo person = MawaeidPersonInfo(
      englishFullName: 'TEST USER',
      arabicFullName: 'مستخدم',
      age: '30',
      isClearingAgent: 'N',
      isDisabled: 'N',
    );

    Future<MawaeidAuthService> serviceWithInserted(String inserted) async {
      final MawaeidAuthService service = MawaeidAuthService(
        client: MockClient((request) async {
          if (request.url.queryParameters['funcName'] == 'LOG_EXT_MOB_DATA') {
            return http.Response(
              '[{"P_INSERTED":"1","V_TRX_ID":"ssn-1"}]',
              200,
            );
          }

          return http.Response('[{"P_INSERTED":"$inserted"}]', 200);
        }),
      );

      await service.bootstrapSession();

      return service;
    }

    final MawaeidAuthResult differentMobile =
        await (await serviceWithInserted('2')).registerOrUpdateUser(
          person: person,
          mobile: '33123456',
          cpr: '123456789',
          blockNo: '123',
          expiry: '2030-09-10',
        );

    expect(differentMobile.requiresDifferentMobileWarning, isTrue);
    expect(differentMobile.canContinueToExistingOtp, isTrue);

    expect(
      () async => (await serviceWithInserted('999')).registerOrUpdateUser(
        person: person,
        mobile: '33123456',
        cpr: '123456789',
        blockNo: '123',
        expiry: '2030-09-10',
      ),
      throwsA(
        isA<MawaeidAuthException>().having(
          (error) => error.code,
          'code',
          MawaeidAuthErrorCode.otpAttemptsExhausted,
        ),
      ),
    );
  });

  test('authenticate runs Mawaeid steps then allows existing OTP', () async {
    final List<String> funcNames = <String>[];
    final List<String> paramPayloads = <String>[];

    final MawaeidAuthService service = MawaeidAuthService(
      client: MockClient((request) async {
        final String funcName = request.url.queryParameters['funcName'] ?? '';
        final String params = request.url.queryParameters['params'] ?? '';

        funcNames.add(funcName);
        paramPayloads.add(params);

        if (funcName == 'LOG_EXT_MOB_DATA') {
          return http.Response('[{"P_INSERTED":"1","V_TRX_ID":"ssn-1"}]', 200);
        }

        if (funcName == 'VERIFY_USER_CPR_AGE_AGENT_DISABILITY_CHK') {
          return http.Response(
            '''
<html><body>
[<PersonNameInformation>
  <EnglishFullName>TEST USER</EnglishFullName>
  <ArabicFullName>Test Arabic</ArabicFullName>
  <Age>30</Age>
  <IsClearingAgent>N</IsClearingAgent>
  <IsDisabled>N</IsDisabled>
</PersonNameInformation>]
</body></html>
''',
            200,
            headers: const {'content-type': 'text/html; charset=utf-8'},
          );
        }

        fail('Unexpected Mawaeid function: $funcName');
      }),
    );

    final MawaeidAuthResult result = await service.authenticate(
      cpr: '123456789',
      blockNo: '321',
      expiryDisplayDate: '10/09/2030',
      mobile: '33123456',
    );

    expect(funcNames, [
      'LOG_EXT_MOB_DATA',
      'VERIFY_USER_CPR_AGE_AGENT_DISABILITY_CHK',
    ]);
    expect(paramPayloads[1], 'ssn-1,123456789,321,2030-09-10');
    expect(funcNames, isNot(contains('INS_MOB_CUSTOMERS_MAWAEID_AGE_DISABILITY')));
    expect(funcNames, isNot(contains('MOB_USER_OTP_TOKEN_VERSION')));
    expect(result.canContinueToExistingOtp, isTrue);
    expect(result.requiresDifferentMobileWarning, isFalse);
  });

  test('maps timeout and unavailable responses', () async {
    final MawaeidAuthService timeoutService = MawaeidAuthService(
      timeout: const Duration(milliseconds: 10),
      client: MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('[{"P_INSERTED":"1","V_TRX_ID":"ssn-1"}]', 200);
      }),
    );

    expect(
      timeoutService.bootstrapSession(),
      throwsA(
        isA<MawaeidAuthException>().having(
          (error) => error.code,
          'code',
          MawaeidAuthErrorCode.timeout,
        ),
      ),
    );

    final MawaeidAuthService unavailableService = MawaeidAuthService(
      client: MockClient((request) async {
        return http.Response('unavailable', 503);
      }),
    );

    expect(
      unavailableService.bootstrapSession(),
      throwsA(
        isA<MawaeidAuthException>().having(
          (error) => error.code,
          'code',
          MawaeidAuthErrorCode.serverUnavailable,
        ),
      ),
    );
  });
}
