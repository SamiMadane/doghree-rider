import 'package:doghree_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';
import '../../helpers/fake_push_client.dart';

/// Logout and notifications-off release the device for push (D-02 note),
/// with a pending flag when FCM cannot be reached; topics are null-safe
/// (row 14); remember-me keeps the phone only (row 16).
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;
  late FakePushClient push;

  AuthRepository repo({Duration timeout = const Duration(seconds: 5)}) =>
      AuthRepository(
          apiClient: api,
          sharedPreferences: prefs,
          push: push,
          pushTimeout: timeout);

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.token: 'old-token',
      AppConstants.languageCode: 'ar',
      AppConstants.zoneTopic: 'zone_1_push',
      AppConstants.vehicleWiseTopic: 'delivery_man_1_2',
    });
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
    push = FakePushClient();
  });

  test('T7 logout clears the session first, then unsubscribes and deletes '
      'the device token', () async {
    final List<bool> loggedInAtPushCall = [];
    push.onCall = (_) => loggedInAtPushCall
        .add(prefs.containsKey(AppConstants.token) || api.token != null);

    expect(await repo().clearSharedData(), isTrue);

    expect(push.log, [
      'unsubscribe:${AppConstants.topic}',
      'unsubscribe:zone_1_push',
      'unsubscribe:delivery_man_1_2',
      'deleteToken',
    ]);
    expect(loggedInAtPushCall, everyElement(isFalse));
    expect(prefs.containsKey(AppConstants.zoneTopic), isFalse);
    expect(prefs.getBool(AppConstants.fcmCleanupPending), isNull);
    expect(prefs.getStringList(AppConstants.fcmCleanupTopics), isNull);
  });

  test('T7b offline FCM: logout returns within the timeout and stays pending',
      () async {
    push.hang = true;

    await repo(timeout: const Duration(milliseconds: 50))
        .clearSharedData()
        .timeout(const Duration(seconds: 2));

    expect(prefs.containsKey(AppConstants.token), isFalse);
    expect(prefs.getBool(AppConstants.fcmCleanupPending), isTrue);
  });

  test('T8 No_topic_found and empty topics are never subscribed', () async {
    await prefs.remove(AppConstants.token);
    final r = repo();
    await r.saveUserToken('new-token', '', 'No_topic_found');
    await r.updateToken();

    expect(push.log.where((c) => c.startsWith('subscribe:')),
        ['subscribe:${AppConstants.topic}']);
    final put = api.calls.singleWhere((c) => c.uri == AppConstants.tokenUri);
    expect((put.body as Map)['fcm_token'], 'device-token');
  });

  test('T8b no update-fcm-token call when FCM gives no token', () async {
    push.failGetToken = true;

    await repo().updateToken();

    expect(api.calls.where((c) => c.uri == AppConstants.tokenUri), isEmpty);
  });

  test('T11 remember-me stores the phone only and purges an old password',
      () async {
    await prefs.setString(AppConstants.userPassword, 'old-secret');

    await repo().saveUserNumber('599000000', '+970', 'PS');

    expect(prefs.containsKey(AppConstants.userPassword), isFalse);
    expect(prefs.getString(AppConstants.userNumber), '599000000');

    await prefs.setString(AppConstants.userPassword, 'old-secret');
    await repo().purgeStoredPassword();
    expect(prefs.containsKey(AppConstants.userPassword), isFalse);
  });

  test('T12 a failing deleteToken leaves the cleanup pending', () async {
    push.failDeleteToken = true;

    await repo().clearSharedData();

    expect(push.log.last, 'deleteToken');
    expect(prefs.getBool(AppConstants.fcmCleanupPending), isTrue);
    expect(prefs.getStringList(AppConstants.fcmCleanupTopics), [
      AppConstants.topic,
      'zone_1_push',
      'delivery_man_1_2',
    ]);
  });

  test('T13 the next retry with a working push client clears the flag',
      () async {
    push.failDeleteToken = true;
    await repo().clearSharedData();

    // Next app start: a fresh repository, FCM reachable again.
    push = FakePushClient();
    expect(await repo().retryPendingPushCleanup(), isTrue);

    expect(push.log, [
      'unsubscribe:${AppConstants.topic}',
      'unsubscribe:zone_1_push',
      'unsubscribe:delivery_man_1_2',
      'deleteToken',
    ]);
    expect(prefs.getBool(AppConstants.fcmCleanupPending), isNull);
    expect(prefs.getStringList(AppConstants.fcmCleanupTopics), isNull);
  });

  test('T14 the next login finishes a pending cleanup before getToken',
      () async {
    push.failDeleteToken = true;
    await repo().clearSharedData();
    push = FakePushClient();

    final r = repo();
    await r.saveUserToken('new-token', 'zone_1_push', 'delivery_man_1_2');
    await r.updateToken();

    expect(push.log.indexOf('deleteToken'),
        lessThan(push.log.indexOf('getToken')));
    expect(prefs.getBool(AppConstants.fcmCleanupPending), isNull);
  });

  test('T15 notifications off releases the device without the doomed PUT',
      () async {
    repo().setNotificationActive(false);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(push.log.last, 'deleteToken');
    expect(api.calls.where((c) => c.uri == AppConstants.tokenUri), isEmpty);
    expect(prefs.getBool(AppConstants.notification), isFalse);
    expect(prefs.getString(AppConstants.zoneTopic), 'zone_1_push');
  });
}
