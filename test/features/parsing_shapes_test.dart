import 'package:doghree_rider/common/models/config_model.dart';
import 'package:doghree_rider/features/address/domain/repositories/address_repository.dart';
import 'package:doghree_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:doghree_rider/features/chat/domain/models/message_model.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository.dart';
import 'package:doghree_rider/features/order/domain/models/order_details_model.dart';
import 'package:doghree_rider/features/order/domain/models/order_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';

Map<String, dynamic> _order(int id, {Map<String, dynamic>? extra}) => {
      'id': id,
      'order_type': 'delivery',
      'order_status': 'confirmed',
      'details_count': 2,
      ...?extra,
    };

void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
  });

  tearDown(Get.reset);

  group('list repositories: a wrong body shape is a failure (audit row 52)',
      () {
    test('R1 current-orders 200 with a Map body gives null', () async {
      final repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse =
          const Response(statusCode: 200, body: {'orders': []});
      expect(await repo.getList(), isNull);
    });

    test('R2 latest-orders 200 with a String body gives null', () async {
      final repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = const Response(statusCode: 200, body: 'ok');
      expect(await repo.getLatestOrders(), isNull);
    });

    test('R3 notifications 200 with a Map body gives null', () async {
      final repo =
          NotificationRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse =
          const Response(statusCode: 200, body: {'message': 'x'});
      expect(await repo.getList(), isNull);
    });

    test('R4 zones 200 with a Map body gives null', () async {
      final repo = AddressRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = const Response(statusCode: 200, body: {'zones': []});
      expect(await repo.getList(), isNull);
    });

    test('R5 vehicles 200 with a String body gives null', () async {
      final repo = AuthRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = const Response(statusCode: 200, body: 'ok');
      expect(await repo.getList(), isNull);
    });

    test('R6 one bad item in current-orders is skipped, the rest load',
        () async {
      final repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = Response(statusCode: 200, body: [
        'not a map',
        {'id': 'abc', 'details_count': 'x', 'payments': 'wrong'},
        _order(7),
      ]);
      final list = await repo.getList();
      expect(list, isNotNull);
      expect(list!.where((o) => o.id == 7), hasLength(1));
    });

    test('R7 every history page is silent and carries page and limit',
        () async {
      final repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = Response(statusCode: 200, body: {
        'total_size': 12,
        'limit': '10',
        'offset': '2',
        'orders': [_order(1)],
      });
      final page = await repo.getCompletedOrderList(2);
      expect(page?.orders, hasLength(1));
      expect(api.last.handleError, isFalse);
      expect(api.last.query, {'offset': 2, 'limit': 10});
    });

    test('R8 history 200 with a non-Map body gives null', () async {
      final repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = const Response(statusCode: 200, body: <dynamic>[]);
      expect(await repo.getCompletedOrderList(1), isNull);
    });

    test('G1 valid bare arrays still parse in full', () async {
      final orders = OrderRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse =
          Response(statusCode: 200, body: [_order(1), _order(2)]);
      expect((await orders.getList())!.map((o) => o.id), [1, 2]);
      expect((await orders.getLatestOrders())!.map((o) => o.id), [1, 2]);

      final vehicles = AuthRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = const Response(statusCode: 200, body: [
        {'id': 1, 'type': 'bike'}
      ]);
      expect((await vehicles.getList())!.single.type, 'bike');
    });

    test('G2 a real [] is an empty list, not a failure', () async {
      final orders = OrderRepository(apiClient: api, sharedPreferences: prefs);
      final notes =
          NotificationRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = const Response(statusCode: 200, body: <dynamic>[]);
      expect(await orders.getList(), isEmpty);
      expect(await orders.getLatestOrders(), isEmpty);
      expect(await notes.getList(), isEmpty);
    });

    test('G8 a non-200 stays null', () async {
      final repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
      api.nextResponse = const Response(statusCode: 500);
      expect(await repo.getList(), isNull);
      expect(await repo.getLatestOrders(), isNull);
    });
  });

  group('models: null or missing fields must not throw (audit row 53)', () {
    test('M1 profile without identity_image_full_url parses', () {
      final profile = ProfileModel.fromJson({'id': 1, 'f_name': 'A'});
      expect(profile.id, 1);
      expect(profile.identityImageFullUrl, isEmpty);
    });

    test('M2 message with file_full_url null parses', () {
      final message = Message.fromJson({'id': 1, 'file_full_url': null});
      expect(message.id, 1);
      expect(message.filesFullUrl, isEmpty);
    });

    test('M3a config module_config without module_type parses', () {
      final config = ConfigModel.fromJson({
        'module_config': {'grocery': <String, dynamic>{}},
      });
      expect(config.moduleConfig, isNotNull);
      expect(config.moduleConfig!.module, isNull);
    });

    test('M3b config module_config with module_type [] parses', () {
      final config = ConfigModel.fromJson({
        'module_config': {'module_type': <String>[]},
      });
      expect(config.moduleConfig!.moduleType, isEmpty);
    });

    test('M4 choice options with options null parse', () {
      final options =
          ChoiceOptions.fromJson({'name': 'size', 'title': 'Size'});
      expect(options.options, isEmpty);
    });

    test('M5 total_size, limit and offset as strings parse', () {
      final page = PaginatedOrderModel.fromJson({
        'total_size': '142',
        'limit': '10',
        'offset': '1',
        'orders': [_order(1)],
      });
      expect(page.totalSize, 142);
      expect(page.orders, hasLength(1));
    });

    test('M6 numeric store_lat and a string details_count parse', () {
      final order = OrderModel.fromJson(_order(1, extra: {
        'store_lat': 31.5,
        'store_lng': '34.4',
        'details_count': '2',
        'module_type': 7,
      }));
      expect(order.storeLat, '31.5');
      expect(order.storeLng, '34.4');
      expect(order.detailsCount, 2);
      expect(order.moduleType, '7');
    });

    test('M7 a history page without orders gives null orders', () {
      final page = PaginatedOrderModel.fromJson({'total_size': 3});
      expect(page.orders, isNull);
    });

    test('G3 an order with every store_* key null parses to nulls', () {
      final order = OrderModel.fromJson(_order(1, extra: {
        'store_name': null,
        'store_address': null,
        'store_phone': null,
        'store_lat': null,
        'store_lng': null,
        'store_logo_full_url': null,
        'module_type': null,
      }));
      expect(order.storeLat, isNull);
      expect(order.storeLng, isNull);
      expect(order.moduleType, isNull);
      expect(order.storeName, isNull);
    });

    test('G9 string lists that are present still parse', () {
      expect(
          ProfileModel.fromJson({
            'identity_image_full_url': ['a.png', 'b.png']
          }).identityImageFullUrl,
          ['a.png', 'b.png']);
      expect(
          OrderModel.fromJson(_order(1, extra: {
            'order_proof_full_url': ['p.png']
          })).orderProofFullUrl,
          ['p.png']);
    });
  });
}
