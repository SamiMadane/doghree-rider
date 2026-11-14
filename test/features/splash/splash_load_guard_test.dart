import 'package:doghree_rider/features/splash/domain/models/splash_load_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashLoadGuard (single splash load)', () {
    test('T10 a second load cannot start while one is running', () {
      final guard = SplashLoadGuard();

      expect(guard.tryStartLoad(), isTrue);
      expect(guard.tryStartLoad(), isFalse);

      guard.endLoad();
      expect(guard.tryStartLoad(), isTrue);
    });

    test('T11 navigation happens at most once and blocks later loads', () {
      final guard = SplashLoadGuard();

      expect(guard.tryNavigate(), isTrue);
      expect(guard.tryNavigate(), isFalse);
      expect(guard.tryStartLoad(), isFalse);
    });
  });
}
