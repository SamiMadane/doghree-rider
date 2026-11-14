import 'package:doghree_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:doghree_rider/features/chat/domain/repositories/chat_repository.dart';
import 'package:doghree_rider/features/forgot_password/domain/repositories/forgot_password_repository.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/features/profile/domain/repositories/profile_repository.dart';
import 'package:doghree_rider/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';

const String secret = 'SECRET-TOKEN-123';

/// Audit row 9: rider auth is the Bearer header only. No request may carry
/// the token in its URI, query map or body.
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({AppConstants.token: secret});
    prefs = await SharedPreferences.getInstance();
    // A failure status keeps the repositories from parsing an empty body.
    api = FakeApiClient(
        sharedPreferences: prefs,
        nextResponse: const Response(statusCode: 500));
  });

  void expectNoToken() {
    expect(api.calls, isNotEmpty);
    for (final RecordedCall c in api.calls) {
      final String where = '${c.method} ${c.uri}';
      expect(c.uri, isNot(contains('token=')), reason: where);
      expect(c.uri, isNot(contains(secret)), reason: where);
      expect(c.query?.containsKey('token') ?? false, isFalse, reason: where);
      if (c.body is Map) {
        expect((c.body as Map).containsKey('token'), isFalse, reason: where);
      }
      expect('${c.query} ${c.body}', isNot(contains(secret)), reason: where);
    }
  }

  test('T3a order repository sends no token', () async {
    final r = OrderRepository(apiClient: api, sharedPreferences: prefs);
    await r.get(42);
    await r.getCompletedOrderList(1);
    await r.getList();
    await r.getLatestOrders();
    await r.getOrderDetails(42);
    await r.acceptOrder(42);
    await r.updateOrderStatus(
        UpdateStatusBodyModel(orderId: 42, status: 'picked_up'), []);
    expect(api.calls.length, 7);
    expectNoToken();
  });

  test('T3b chat repository sends no token', () async {
    final r = ChatRepository(apiClient: api, sharedPreferences: prefs);
    await r.getConversationList(1);
    await r.searchConversationList('a');
    await r.getMessages(1, 5, AppConstants.user, null);
    await r.getMessages(1, null, AppConstants.user, 9);
    await r.sendMessage('hi', [], 9, null, AppConstants.customer);
    expect(api.calls.length, 5);
    expectNoToken();
  });

  test('T3c profile repository sends no token over HTTP', () async {
    final r = ProfileRepository(apiClient: api, sharedPreferences: prefs);
    await r.getProfileInfo();
    await r.updateProfile(
        ProfileModel(fName: 'A', lName: 'B', email: 'a@b.c'), null, '');
    await r.updateActiveStatus();
    await r.recordLocation(
        RecordLocationBodyModel(latitude: 1, longitude: 2, location: 'x'));
    await r.deleteDriver();
    expect(api.calls.length, 5);
    expectNoToken();
  });

  test('T3d wallet, notification and change-password send no token',
      () async {
    await WalletRepository(apiClient: api, sharedPreferences: prefs)
        .getEarningReport(offset: '1', type: 'all');
    await WalletRepository(apiClient: api, sharedPreferences: prefs)
        .getEarningReport(
            offset: '1',
            type: 'all',
            startDate: '2026-01-01',
            endDate: '2026-01-31');
    await NotificationRepository(apiClient: api, sharedPreferences: prefs)
        .sendDeliveredNotification(42);
    await ForgotPasswordRepository(apiClient: api, sharedPreferences: prefs)
        .changePassword(
            ProfileModel(fName: 'A', lName: 'B', email: 'a@b.c'), 'x', 'y');
    expect(api.calls.length, 4);
    expectNoToken();
  });
}
