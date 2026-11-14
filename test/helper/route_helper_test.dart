import 'dart:convert';

import 'package:doghree_rider/helper/phone_format_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Audit row 51. GetX 4.6.6 reads route parameters with
/// Uri.parse(route).queryParameters, so that is what the screens receive.
void main() {
  group('route query encoding (audit row 51)', () {
    test('T10a reset-password route keeps +, & and = intact', () {
      final params = Uri.parse(RouteHelper.getResetPasswordRoute(
              '+10000000000', 'a+b=c&d', 'reset-password'))
          .queryParameters;

      expect(params['phone'], '+10000000000');
      expect(params['token'], 'a+b=c&d');
      expect(params['page'], 'reset-password');
    });

    test('T10b verification route keeps the + and the session', () {
      final params = Uri.parse(RouteHelper.getVerificationRoute('+10000000000',
              session: 'session-1'))
          .queryParameters;

      expect(params['number'], '+10000000000');
      expect(utf8.decode(base64Url.decode(params['session']!)), 'session-1');
      expect(
          Uri.parse(RouteHelper.getVerificationRoute('+10000000000'))
              .queryParameters
              .containsKey('session'),
          isFalse);
    });

    test('T10c phone keeps a single leading + (verification and new password)',
        () {
      expect(PhoneFormat.withPlus('+10000000000'), '+10000000000');
      expect(PhoneFormat.withPlus(' 10000000000 '), '+10000000000');
      expect(PhoneFormat.withPlus(null), '');
    });
  });
}
