import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
import 'package:doghree_rider/features/notification/controllers/notification_controller.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository.dart';
import 'package:doghree_rider/features/notification/domain/services/notification_service.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:doghree_rider/features/order/domain/services/order_service.dart';
import 'package:doghree_rider/helper/first_load_notice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';

/// D-12: Home's running orders and the notifications list load silently.
/// No data yet and the load fails → exactly one message. Data on screen →
/// silent. Resume and push refreshes → always silent. A 401 → only the
/// session sheet.
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;
  final String noInternet = ErrorMessages.getMessage(ErrorType.noInternet);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
  });

  tearDown(() {
    ApiChecker.isLoggingOut = false;
    Get.reset();
  });

  group('FirstLoadNotice.pick', () {
    const LoadAttempt okEmpty = LoadAttempt(ok: true, hadData: false);

    test('P1 two loads fail with no data: one message, no internet wins', () {
      expect(
          FirstLoadNotice.pick(const [
            LoadAttempt(
                ok: false, hadData: false, statusCode: 500, message: 'server'),
            LoadAttempt(ok: false, hadData: false, statusCode: 1),
          ]),
          noInternet);
    });

    test('P2 one load fails with no data: its server message', () {
      expect(
          FirstLoadNotice.pick(const [
            okEmpty,
            LoadAttempt(
                ok: false, hadData: false, statusCode: 403, message: 'blocked'),
          ]),
          'blocked');
    });

    test('P3 a failure with data already on screen: no message', () {
      expect(
          FirstLoadNotice.pick(const [
            LoadAttempt(ok: false, hadData: true, statusCode: 1),
          ]),
          isNull);
    });

    test('P4 a 401: no message (the session sheet shows)', () {
      expect(
          FirstLoadNotice.pick(const [
            LoadAttempt(ok: false, hadData: false, statusCode: 401),
          ]),
          isNull);
    });

    test('P5 all loads succeed: no message', () {
      expect(FirstLoadNotice.pick(const [okEmpty, okEmpty]), isNull);
    });

    test('P6 a failure without a server text: the generic message', () {
      expect(
          FirstLoadNotice.pick(const [
            LoadAttempt(ok: false, hadData: false, statusCode: 0, message: ' '),
          ]),
          'error_occurred');
    });
  });

  group('running orders (OrderController)', () {
    late List<String?> toasts;
    late OrderController controller;

    setUp(() {
      toasts = [];
      controller = OrderController(
          orderServiceInterface: OrderService(
              orderRepositoryInterface:
                  OrderRepository(apiClient: api, sharedPreferences: prefs)))
        ..toast = (String? m, {bool isError = true}) => toasts.add(m);
    });

    test('O1 first load offline, announced: exactly one message', () async {
      api.nextResponse = const Response(statusCode: 1);
      await controller.getCurrentOrders(announce: true);
      expect(toasts, [noInternet]);
      expect(controller.currentOrderList, isNull);
    });

    test('O2 data on screen, the refresh fails: silent, list kept', () async {
      api.nextResponse = const Response(statusCode: 200, body: []);
      await controller.getCurrentOrders();
      api.nextResponse = const Response(statusCode: 1);
      await controller.getCurrentOrders(announce: true);
      expect(toasts, isEmpty);
      expect(controller.currentOrderList, isEmpty);
    });

    test('O3 a push or resume refresh (not announced) is silent', () async {
      api.nextResponse = const Response(statusCode: 500);
      await controller.getCurrentOrders();
      expect(toasts, isEmpty);
    });

    test('O4 pull to refresh with no data yet: one message', () async {
      api.nextResponse = const Response(statusCode: 1);
      await controller.getCurrentOrders();
      await controller.getCurrentOrders(announce: true);
      expect(toasts, [noInternet]);
    });

    test('O5 a 401: no message from the list', () async {
      ApiChecker.isLoggingOut = true; // no session sheet in a unit test
      api.nextResponse = const Response(statusCode: 401);
      await controller.getCurrentOrders(announce: true);
      expect(toasts, isEmpty);
    });
  });

  group('notifications (NotificationController)', () {
    late List<String?> toasts;
    late NotificationController controller;

    setUp(() {
      toasts = [];
      controller = NotificationController(
          notificationServiceInterface: NotificationService(
              notificationRepositoryInterface: NotificationRepository(
                  apiClient: api, sharedPreferences: prefs)))
        ..toast = (String? m, {bool isError = true}) => toasts.add(m);
    });

    test('N1 first open fails, announced: exactly one message', () async {
      api.nextResponse = const Response(statusCode: 500, statusText: 'down');
      await controller.getNotificationList(reload: true, announce: true);
      expect(toasts, ['down']);
    });

    test('N2 resume refresh offline (not announced): silent', () async {
      api.nextResponse = const Response(statusCode: 1);
      await controller.getNotificationList(reload: true);
      expect(toasts, isEmpty);
    });

    test('N3 data on screen, pull to refresh fails: silent', () async {
      api.nextResponse = const Response(statusCode: 200, body: []);
      await controller.getNotificationList(reload: true);
      api.nextResponse = const Response(statusCode: 1);
      await controller.getNotificationList(reload: true, announce: true);
      expect(toasts, isEmpty);
      expect(controller.notificationList, isEmpty);
    });
  });
}
