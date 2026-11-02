import 'package:flutter_test/flutter_test.dart';
import 'package:sanctions/services/mawaeid_response_parser.dart';

void main() {
  const MawaeidResponseParser parser = MawaeidResponseParser();

  group('MawaeidResponseParser JSON', () {
    test('parses HTML-wrapped bootstrap JSON', () {
      const String raw = '''
<html>
<head>
<title>Mawaeid LOG_EXT_MOB_DATA</title>
</head>
<body>
[{"P_INSERTED" : "1", "ORDS" : "https://mob.mawaid.org:7011/apex/qms/promaw/ssnChk/", "V_TRX_ID" : "11135225_uuid"}]</body>
</html>
''';

      final String payload = parser.unwrapPayload(raw);
      final dynamic decoded = parser.tryParseJson(payload);
      final Map<String, dynamic>? record = parser.firstJsonRecord(decoded);

      expect(parser.readField(record!, const ['P_INSERTED']), '1');
      expect(parser.readField(record, const ['V_TRX_ID']), '11135225_uuid');
    });

    test('parses raw JSON array', () {
      const String raw = '[{"P_INSERTED":"3"}]';
      final Map<String, dynamic>? record = parser.firstJsonRecord(
        parser.tryParseJson(parser.unwrapPayload(raw)),
      );

      expect(parser.readField(record!, const ['P_INSERTED']), '3');
    });

    test('returns null for empty and malformed payloads', () {
      expect(parser.unwrapPayload(''), '');
      expect(parser.tryParseJson(''), null);
      expect(parser.tryParseJson('<html><body>not-json</body></html>'), null);
      expect(parser.firstJsonRecord(parser.tryParseJson('[]')), null);
    });
  });

  group('MawaeidResponseParser XML', () {
    test('maps NO_RECORD_FOUND SOAP fault to invalid CPR', () {
      const String raw = '''
<html>
<body>
[<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><soap:Fault><faultcode>soap:Server</faultcode><faultstring>Block Validation General Exception</faultstring><detail><ns2:ApplicationException xmlns:ns2="http://service.person.retrieve.crs.integration.cio.gov.bh/"><message>NO_RECORD_FOUND</message></ns2:ApplicationException></detail></soap:Fault></soap:Body></soap:Envelope>]
</body>
</html>
''';

      final String xml = parser.extractXml(parser.unwrapPayload(raw));

      expect(parser.containsPersonNameInformation(xml), isFalse);
      expect(
        parser.cprVerificationError(xml),
        MawaeidCprVerificationError.invalidCpr,
      );
    });

    test('maps date unmarshalling errors to invalid expiry', () {
      const String xml =
          '<soap:Fault><faultstring>Unmarshalling Error: 10-09-2030 </faultstring></soap:Fault>';

      expect(
        parser.cprVerificationError(xml),
        MawaeidCprVerificationError.invalidExpiry,
      );
    });

    test('maps under-age and block messages', () {
      expect(
        parser.cprVerificationError('<message>Under Age</message>'),
        MawaeidCprVerificationError.underAge,
      );
      expect(
        parser.cprVerificationError('<message>Invalid Block</message>'),
        MawaeidCprVerificationError.invalidBlock,
      );
    });

    test('extracts person fields from namespaced XML', () {
      const String xml = '''
<ns2:PersonNameInformation>
  <ns2:EnglishFullName>TEST USER</ns2:EnglishFullName>
  <ns2:ArabicFullName><![CDATA[مستخدم تجريبي]]></ns2:ArabicFullName>
  <ns2:Age>34</ns2:Age>
  <ns2:IsClearingAgent>N</ns2:IsClearingAgent>
  <ns2:IsDisabled>N</ns2:IsDisabled>
</ns2:PersonNameInformation>
''';

      expect(parser.containsPersonNameInformation(xml), isTrue);

      final MawaeidPersonInfo person = parser.parsePersonInfo(xml);

      expect(person.englishFullName, 'TEST USER');
      expect(person.arabicFullName, 'مستخدم تجريبي');
      expect(person.age, '34');
      expect(person.isClearingAgent, 'N');
      expect(person.isDisabled, 'N');
    });
  });
}
