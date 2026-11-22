import 'dart:async';

import 'package:doghree_rider/common/models/load_failure.dart';
import 'package:doghree_rider/common/widgets/load_failed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_phone.dart';

/// D-13: one failure rule and one shared failure state for first loads.
void main() {
  group('LoadFailures.fromStatus', () {
    test('L1 no internet (1)', () {
      expect(LoadFailures.fromStatus(1), LoadFailure.noInternet);
    });

    test('L2 server problem for 0, 403, 500 and an unreadable 200', () {
      for (final int code in [0, 403, 500, 200]) {
        expect(LoadFailures.fromStatus(code), LoadFailure.serverProblem,
            reason: 'status $code');
      }
    });

    test('L3 a null status is a server problem', () {
      expect(LoadFailures.fromStatus(null), LoadFailure.serverProblem);
    });

    test('L4 a 401 shows nothing (the session sheet owns it)', () {
      expect(LoadFailures.fromStatus(401), isNull);
    });
  });

  group('LoadFailedWidget', () {
    testWidgets('L5 no internet shows the no-connection texts and Retry',
        (tester) async {
      await pumpPhone(
          tester,
          Scaffold(
              body: LoadFailedWidget(
                  failure: LoadFailure.noInternet, onRetry: () async {})));

      expect(find.text('no_connection'), findsOneWidget);
      expect(find.text('please_check_your_internet_and_try_again'),
          findsOneWidget);
      expect(find.text('retry'), findsOneWidget);
      expect(find.text('server_problem'), findsNothing);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('L6 server problem shows the server texts', (tester) async {
      await pumpPhone(
          tester,
          Scaffold(
              body: LoadFailedWidget(
                  failure: LoadFailure.serverProblem, onRetry: () async {})));

      expect(find.text('server_problem'), findsOneWidget);
      expect(find.text('server_problem_try_again'), findsOneWidget);
      expect(find.text('no_connection'), findsNothing);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('L7 taps while a retry runs send no second request',
        (tester) async {
      int calls = 0;
      final Completer<void> done = Completer<void>();
      await pumpPhone(
          tester,
          Scaffold(
              body: LoadFailedWidget(
                  failure: LoadFailure.noInternet,
                  onRetry: () {
                    calls++;
                    return done.future;
                  })));

      await tester.tap(find.text('retry'));
      await tester.tap(find.byType(TextButton), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.byType(TextButton), warnIfMissed: false);
      await tester.pump();

      expect(calls, 1);

      done.complete();
      await tester.pumpAndSettle();
      expect(find.text('retry'), findsOneWidget);
    });

    testWidgets('L8 the button works again after a retry ends',
        (tester) async {
      int calls = 0;
      await pumpPhone(
          tester,
          Scaffold(
              body: LoadFailedWidget(
                  failure: LoadFailure.serverProblem,
                  onRetry: () async => calls++)));

      await tester.tap(find.text('retry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('retry'));
      await tester.pumpAndSettle();

      expect(calls, 2);
    });

    testWidgets('L9 a retry that throws still frees the button',
        (tester) async {
      int calls = 0;
      await pumpPhone(
          tester,
          Scaffold(
              body: LoadFailedWidget(
                  failure: LoadFailure.serverProblem,
                  onRetry: () async {
                    calls++;
                    throw StateError('retry');
                  })));

      await tester.tap(find.text('retry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('retry'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(tester.takeException(), isNull);
    });
  });
}
