import 'package:doghree_rider/common/widgets/no_internet_screen.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/splash/domain/models/splash_load_guard.dart';
import 'package:doghree_rider/features/splash/domain/repositories/splash_repository.dart';
import 'package:doghree_rider/features/splash/domain/services/splash_service.dart';
import 'package:doghree_rider/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

/// D-12: the splash says "no internet" only for a connectivity failure.
/// A server failure (5xx, 403, unknown, a body that is not JSON) gets the
/// server text on the same Retry screen.
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
  });

  tearDown(Get.reset);

  /// Loads the config through the real repository and service with [res],
  /// and returns what the splash would show.
  Future<SplashFailure> configFailure(Response res) async {
    api.nextResponse = res;
    final controller = SplashController(
        navigationHandlerServiceInterface: SplashService(
            navigationHandlerRepositoryInterface:
                SplashRepository(apiClient: api, sharedPreferences: prefs)));
    expect(await controller.getConfigData(), isFalse);
    return splashFailureFor(configStatus: controller.lastConfigStatus);
  }

  group('config load', () {
    test('K1 no internet (1) shows the no-internet text', () async {
      expect(await configFailure(const Response(statusCode: 1)),
          SplashFailure.noInternet);
    });

    test('K2 a 500 shows the server text', () async {
      expect(await configFailure(const Response(statusCode: 500)),
          SplashFailure.serverProblem);
    });

    test('K3 a 403 shows the server text', () async {
      expect(await configFailure(const Response(statusCode: 403)),
          SplashFailure.serverProblem);
    });

    test('K4 an unknown failure (0) shows the server text', () async {
      expect(await configFailure(const Response(statusCode: 0)),
          SplashFailure.serverProblem);
    });

    test('K5 a 200 with an HTML body shows the server text', () async {
      expect(
          await configFailure(const Response(
              statusCode: 200, body: '<html><body>Login to Wi-Fi</body></html>')),
          SplashFailure.serverProblem);
    });
  });

  group('profile check', () {
    test('K6 offline shows the no-internet text', () {
      expect(splashFailureFor(session: SessionStatus.offline),
          SplashFailure.noInternet);
    });

    test('K7 unverified (5xx, 403, 0, HTML) shows the server text', () {
      expect(splashFailureFor(session: SessionStatus.unverified),
          SplashFailure.serverProblem);
    });
  });

  group('Retry screen text', () {
    Future<void> pump(WidgetTester tester, {required bool server}) async {
      // A phone-sized surface (the design size), not the 800x600 default.
      tester.view.physicalSize = const Size(376 * 3, 812 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(376, 812),
        builder: (_, __) => GetMaterialApp(
          theme: light,
          home: NoInternetScreen(serverProblem: server, onRetry: () {}),
        ),
      ));
      await tester.pump();
    }

    testWidgets('K8 the server variant shows the server text only',
        (tester) async {
      await pump(tester, server: true);

      expect(find.text('server_problem'), findsOneWidget);
      expect(find.text('server_problem_try_again'), findsOneWidget);
      expect(find.text('no_connection'), findsNothing);
    });

    testWidgets('K9 guard: the default still shows the no-internet text',
        (tester) async {
      await pump(tester, server: false);

      expect(find.text('no_connection'), findsOneWidget);
      expect(find.text('please_check_your_internet_and_try_again'),
          findsOneWidget);
      expect(find.text('server_problem'), findsNothing);
    });
  });
}
