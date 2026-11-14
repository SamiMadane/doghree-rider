import 'package:doghree_rider/api/log_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogSanitizer (audit row 8)', () {
    test('T1 redacts token, phone, number and coordinates, keeps the path', () {
      const String raw = '/api/v1/delivery-man/order?token=SECRET-TOKEN-123'
          '&order_id=42&lat=31.5&lng=34.4';
      final String out = LogSanitizer.uri(raw);

      expect(out, startsWith('/api/v1/delivery-man/order?'));
      expect(out, isNot(contains('SECRET-TOKEN-123')));
      expect(out, isNot(contains('31.5')));
      expect(out, isNot(contains('34.4')));
      expect(out, contains('token=***'));

      final String route = LogSanitizer.text(
          'GOING TO ROUTE /reset-password?phone=%2B10000000000&token=987654&page=reset-password');
      expect(route, isNot(contains('10000000000')));
      expect(route, isNot(contains('987654')));
      expect(route, contains('page=reset-password'));

      final String verify =
          LogSanitizer.text('GOING TO ROUTE /verification?number=+10000000000');
      expect(verify, isNot(contains('10000000000')));
    });

    test('G4 guard: non-sensitive values are kept', () {
      const String raw = '/api/v1/delivery-man/all-orders?offset=2&limit=10&order_id=42';
      expect(LogSanitizer.uri(raw), raw);
    });
  });
}
