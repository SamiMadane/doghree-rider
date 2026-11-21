import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:doghree_rider/features/auth/domain/services/auth_service.dart';
import 'package:doghree_rider/helper/push_client.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';

/// D-12: Firebase did not start (no Firebase app exists in a unit test, as
/// after a failed `Firebase.initializeApp`). The real PushClient is used, so
/// any Firebase call it makes fails the way it would on the device. Login,
/// the token update and logout must all still complete.
///
/// This file does not import FirebaseState, so it compiles against the old
/// code too: there, PushClient called FirebaseMessaging directly.
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  AuthRepository repo() => AuthRepository(
      apiClient: api,
      sharedPreferences: prefs,
      push: const PushClient(),
      pushTimeout: const Duration(seconds: 1));

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.languageCode: 'ar',
      AppConstants.notification: true,
      AppConstants.zoneTopic: 'zone_1_push',
      AppConstants.vehicleWiseTopic: 'delivery_man_1_2',
    });
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
  });

  tearDown(Get.reset);

  test('F1 the token update is skipped without an exception', () async {
    final Response result = await repo().updateToken();

    expect(result.statusCode, 0);
    expect(api.calls.where((c) => c.uri == AppConstants.tokenUri), isEmpty);
  });

  test('F2 the login flow completes and sends no token update', () async {
    api.nextResponse = const Response(statusCode: 200, body: {
      'token': 'session-token',
      'topic': 'delivery_man_1_2',
      'zone_topic': 'zone_1_push',
    });
    final controller = AuthController(
        authServiceInterface: AuthService(authRepositoryInterface: repo()));

    final result = await controller.login('0599000000', 'secret1');
    // Let the background token update run to its end.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(result.isSuccess, isTrue);
    expect(controller.isLoading, isFalse);
    expect(prefs.getString(AppConstants.token), 'session-token');
    expect(api.calls.where((c) => c.uri == AppConstants.tokenUri), isEmpty);
  });

  test('F3 logout completes and leaves the push cleanup pending', () async {
    await prefs.setString(AppConstants.token, 'session-token');

    final bool done = await repo().clearSharedData();

    expect(done, isTrue);
    expect(prefs.containsKey(AppConstants.token), isFalse);
    expect(prefs.getBool(AppConstants.fcmCleanupPending), isTrue);
  });
}
