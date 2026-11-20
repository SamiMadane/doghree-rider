import 'package:doghree_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:doghree_rider/helper/order_ringing.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';
import '../../helpers/fake_push_client.dart';
import '../../helpers/fake_ringing_client.dart';

/// Audit row 36: logout (and block, session expiry, delete account, which
/// all end in clearSharedData) stops the ringing and never fails because of it.
void main() {
  late SharedPreferences prefs;
  late FakeRingingClient ringing;
  late FakePushClient push;
  late AuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({AppConstants.token: 't'});
    prefs = await SharedPreferences.getInstance();
    ringing = FakeRingingClient();
    OrderRinging.client = ringing;
    push = FakePushClient();
    repo = AuthRepository(
        apiClient: FakeApiClient(sharedPreferences: prefs),
        sharedPreferences: prefs,
        push: push);
  });

  tearDown(() => OrderRinging.client = const RingingClient());

  test('R7 logout stops the ringing first', () async {
    String? firstPushCall;
    bool stoppedBeforePush = false;
    push.onCall = (call) {
      firstPushCall ??= call;
      stoppedBeforePush = ringing.stopCalls == 1;
    };
    expect(await repo.clearSharedData(), isTrue);
    expect(ringing.stopCalls, 1);
    expect(firstPushCall, isNotNull);
    expect(stoppedBeforePush, isTrue);
  });

  test('R7b a platform error in stop does not block the logout', () async {
    ringing.failIsRunning = true;
    expect(await repo.clearSharedData(), isTrue);
    expect(prefs.containsKey(AppConstants.token), isFalse);
  });
}
