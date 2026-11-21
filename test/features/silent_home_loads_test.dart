import 'package:doghree_rider/features/notification/domain/repositories/notification_repository.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';

/// D-12: Home's running orders and the notifications list are fetched
/// silently, so ApiChecker never adds a toast; the screen shows at most one
/// message (first_load_notice_test). Compiles against the old code too.
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
  });

  tearDown(Get.reset);

  group('repositories are silent', () {
    test('H1 running orders: handleError is false', () async {
      api.nextResponse = const Response(statusCode: 1);
      await OrderRepository(apiClient: api, sharedPreferences: prefs)
          .getList();
      expect(api.last.handleError, isFalse);
    });

    test('H2 notifications: handleError is false', () async {
      api.nextResponse = const Response(statusCode: 1);
      await NotificationRepository(apiClient: api, sharedPreferences: prefs)
          .getList();
      expect(api.last.handleError, isFalse);
    });
  });
}
