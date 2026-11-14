import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:doghree_rider/features/profile/domain/repositories/profile_repository.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';

/// Background calls must not toast on failure (CLAUDE.md, silent background
/// work): they pass handleError: false so ApiChecker never shows a message.
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(
        sharedPreferences: prefs,
        nextResponse: const Response(statusCode: 1));
  });

  tearDown(Get.reset);

  test('T4 latest-orders polling is silent (audit row 10)', () async {
    final result = await OrderRepository(apiClient: api, sharedPreferences: prefs)
        .getLatestOrders();
    expect(result, isNull);
    expect(api.last.handleError, isFalse);
  });

  test('T5a record-location is silent (audit row 11)', () async {
    await ProfileRepository(apiClient: api, sharedPreferences: prefs)
        .recordLocation(RecordLocationBodyModel(latitude: 1, longitude: 2));
    expect(api.last.handleError, isFalse);
  });

  test('T5b geocode lookup is silent (audit row 11)', () async {
    Get.put<ApiClient>(api);
    final service = ProfileService(
        profileRepositoryInterface:
            ProfileRepository(apiClient: api, sharedPreferences: prefs));
    final String text = await service.addressPlaceMark(Position(
      latitude: 1,
      longitude: 2,
      timestamp: DateTime(2026),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    ));
    expect(text, '');
    expect(api.last.handleError, isFalse);
  });

  test('T6 single mark-read is silent (audit row 12)', () async {
    final ok = await NotificationRepository(
            apiClient: api, sharedPreferences: prefs)
        .markNotificationAsRead(5);
    expect(ok, isFalse);
    expect(api.last.method, 'PATCH');
    expect(api.last.handleError, isFalse);
  });

  test('G2 guard: mark-all-read (user tap) keeps one ApiChecker message',
      () async {
    await NotificationRepository(apiClient: api, sharedPreferences: prefs)
        .markAllNotificationsAsRead();
    expect(api.last.handleError, isTrue);
  });

  test('T7 My Orders page 1 is silent (audit row 13)', () async {
    final result = await OrderRepository(apiClient: api, sharedPreferences: prefs)
        .getCompletedOrderList(1);
    expect(result, isNull);
    expect(api.last.handleError, isFalse);
  });

  test('G3 guard: My Orders page 2 keeps its current handling (D-05)',
      () async {
    await OrderRepository(apiClient: api, sharedPreferences: prefs)
        .getCompletedOrderList(2);
    expect(api.last.handleError, isTrue);
  });
}
