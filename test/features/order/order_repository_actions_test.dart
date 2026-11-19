import 'package:doghree_rider/features/order/domain/models/order_action_result.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

Map<String, dynamic> _err(String code, String message) => {
      'errors': [
        {'code': code, 'message': message}
      ]
    };

void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;
  late OrderRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
    repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
  });

  tearDown(Get.reset);

  group('accept-order', () {
    test('R1 the outcome comes from errors[0].code, not the text', () async {
      api.nextResponse = Response(
          statusCode: 404,
          statusText: 'server text',
          body: _err('active_status', 'any text'));
      final r = await repo.acceptOrder(5);
      expect(r.outcome, AcceptOutcome.offline);
      expect(r.message, 'server text');
      expect(api.last.handleError, isFalse);

      api.nextResponse =
          Response(statusCode: 409, body: _err('order_already_taken', 'x'));
      expect((await repo.acceptOrder(5)).outcome, AcceptOutcome.taken);

      api.nextResponse = Response(
          statusCode: 405,
          statusText: 'deposit text',
          body: _err('deposit_cover_exceeded', 'deposit text'));
      final refused = await repo.acceptOrder(5);
      expect(refused.outcome, AcceptOutcome.refused);
      expect(refused.message, 'deposit text');
    });

    test('R2 a 200 with a non-Map body does not throw', () async {
      api.nextResponse = const Response(statusCode: 200, body: 'ok');
      final r = await repo.acceptOrder(5);
      expect(r.outcome, AcceptOutcome.accepted);
      expect(r.message, isNull);
    });
  });

  group('update-order-status', () {
    test('R3 a 200 with a non-Map body does not throw (audit row 22)',
        () async {
      api.nextResponse =
          const Response(statusCode: 200, body: 'Status updated');
      final r = await repo.updateOrderStatus(
          UpdateStatusBodyModel(orderId: 5, status: 'picked_up'), []);
      expect(r.outcome, StatusOutcome.updated);
      expect(r.message, isNull);
      expect(api.last.handleError, isFalse);
    });

    test('R4 406 error is notDelivered', () async {
      api.nextResponse =
          Response(statusCode: 406, statusText: 't', body: _err('error', 't'));
      final r = await repo.updateOrderStatus(
          UpdateStatusBodyModel(orderId: 5, status: 'delivered'), []);
      expect(r.outcome, StatusOutcome.notDelivered);
    });

    test('G2 guard: the body field is status, not order_status', () async {
      api.nextResponse = const Response(statusCode: 200, body: {});
      await repo.updateOrderStatus(
          UpdateStatusBodyModel(orderId: 5, status: 'picked_up'), []);
      final Map body = api.last.body as Map;
      expect(body['status'], 'picked_up');
      expect(body.containsKey('order_status'), isFalse);
    });
  });

  group('GET order (audit row 21)', () {
    test('R5 404 and 204 are notFound, offline is failed and silent', () async {
      api.nextResponse = const Response(statusCode: 404, body: {});
      expect((await repo.get(5)).outcome, OrderFetch.notFound);
      expect(api.last.handleError, isFalse);

      api.nextResponse = const Response(statusCode: 204, body: '');
      expect((await repo.get(5)).outcome, OrderFetch.notFound);

      api.nextResponse = const Response(statusCode: 1);
      expect((await repo.get(5)).outcome, OrderFetch.failed);
    });

    test('R6 a 200 Map is parsed', () async {
      api.nextResponse = const Response(
          statusCode: 200, body: {'id': 5, 'order_status': 'picked_up'});
      final r = await repo.get(5);
      expect(r.outcome, OrderFetch.found);
      expect(r.order?.id, 5);
      expect(r.order?.orderStatus, 'picked_up');
    });
  });

  test('R7 order-details failure is silent at the repository (audit row 25)',
      () async {
    api.nextResponse = const Response(statusCode: 500);
    final r = await repo.getOrderDetails(5);
    expect(r.details, isNull);
    expect(r.statusCode, 500);
    expect(api.last.handleError, isFalse);
  });
}
