import 'package:flutter_test/flutter_test.dart';
import 'package:pranidoctor_mobile/src/core/validation/bd_phone.dart';
import 'package:pranidoctor_mobile/src/features/auth/data/mobile_otp_auth_repository.dart';

void main() {
  group('BdPhone', () {
    test('normalizes 01… to 8801…', () {
      expect(BdPhone.normalizeToApiDigits('01711234567'), '8801711234567');
      expect(BdPhone.normalizeToApiDigits('01 711 234567'), '8801711234567');
    });

    test('accepts existing 880 prefix', () {
      expect(BdPhone.normalizeToApiDigits('8801711234567'), '8801711234567');
    });

    test('accepts +880 prefix', () {
      expect(BdPhone.normalizeToApiDigits('+880 1711 234567'), '8801711234567');
    });

    test('rejects invalid', () {
      expect(BdPhone.normalizeToApiDigits('999'), isNull);
      expect(BdPhone.normalizeToApiDigits('02123456789'), isNull);
    });
  });

  group('parseAccessTokenFromVerifyBody', () {
    test('reads data.accessToken', () {
      expect(
        parseAccessTokenFromVerifyBody({
          'ok': true,
          'data': {'accessToken': 'jwt-a'},
        }),
        'jwt-a',
      );
    });

    test('reads data.token', () {
      expect(
        parseAccessTokenFromVerifyBody({
          'ok': true,
          'data': {'token': 'jwt-b'},
        }),
        'jwt-b',
      );
    });

    test('reads top-level accessToken', () {
      expect(parseAccessTokenFromVerifyBody({'accessToken': 'jwt-c'}), 'jwt-c');
    });

    test('returns null when missing', () {
      expect(parseAccessTokenFromVerifyBody({'ok': true, 'data': {}}), isNull);
    });
  });
}
