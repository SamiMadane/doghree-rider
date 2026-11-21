import 'package:doghree_rider/common/widgets/startup_failed_app.dart';
import 'package:doghree_rider/helper/app_error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// D-12: the app-wide safety net and the start-up failure screen.
void main() {
  final List<String> lines = [];

  setUp(() {
    lines.clear();
    AppErrorHandler.sink = lines.add;
  });

  test('E1 an uncaught async error is handled (returns true)', () {
    final bool handled = AppErrorHandler.handlePlatformError(
        StateError('boom'), StackTrace.empty);

    expect(handled, isTrue);
    expect(lines, hasLength(1));
    expect(lines.single, contains('StateError'));
  });

  test('E2 the log never carries a token or a phone from a URL', () {
    AppErrorHandler.report(Exception(
        'GET https://x.test/api/v1/delivery-man/profile?token=abc123&phone=0599111222 failed'));

    expect(lines.single, isNot(contains('abc123')));
    expect(lines.single, isNot(contains('0599111222')));
    expect(lines.single, contains('token=***'));
  });

  test('E3 a failing log sink never throws', () {
    AppErrorHandler.sink = (_) => throw StateError('sink');

    expect(() => AppErrorHandler.report(StateError('x')), returnsNormally);
    expect(() => AppErrorHandler.log('y'), returnsNormally);
  });

  testWidgets('E4 release: a failed build shows an empty box, not an error',
      (tester) async {
    final ErrorWidgetBuilder originalBuilder = ErrorWidget.builder;
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;
    try {
      AppErrorHandler.install(release: true);
      final Widget w = ErrorWidget.builder(
          FlutterErrorDetails(exception: StateError('build')));
      expect(w, isA<ColoredBox>());
      expect(w, isNot(isA<ErrorWidget>()));
    } finally {
      ErrorWidget.builder = originalBuilder;
      FlutterError.onError = originalOnError;
    }
  });

  testWidgets('E5 debug: the error widget is left as Flutter made it',
      (tester) async {
    final ErrorWidgetBuilder originalBuilder = ErrorWidget.builder;
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;
    try {
      AppErrorHandler.install(release: false);
      expect(identical(ErrorWidget.builder, originalBuilder), isTrue);
    } finally {
      ErrorWidget.builder = originalBuilder;
      FlutterError.onError = originalOnError;
    }
  });

  testWidgets('E6 the start-up failure screen shows both messages',
      (tester) async {
    await tester.pumpWidget(const StartupFailedApp());

    expect(find.text(StartupFailedApp.messageAr), findsOneWidget);
    expect(find.text(StartupFailedApp.messageEn), findsOneWidget);
  });
}
