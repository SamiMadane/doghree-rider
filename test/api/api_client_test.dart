import 'dart:convert';

import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/chat/domain/repositories/chat_repository.dart';
import 'package:doghree_rider/features/order/domain/models/update_status_body_model.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String secret = 'SECRET-TOKEN-123';

void main() {
  late SharedPreferences prefs;
  late ApiClient apiClient;
  final List<http.BaseRequest> requests = [];
  final List<String> bodies = [];

  setUp(() async {
    SharedPreferences.setMockInitialValues({AppConstants.token: secret});
    prefs = await SharedPreferences.getInstance();
    apiClient =
        ApiClient(appBaseUrl: 'http://fake.local', sharedPreferences: prefs);
    requests.clear();
    bodies.clear();
  });

  MockClient okClient(String body) => MockClient((request) async {
        requests.add(request);
        bodies.add(request.body);
        return http.Response(body, 200,
            headers: {'content-type': 'application/json'});
      });

  test('T2 debug logs never contain the token or coordinates (audit row 8)',
      () async {
    final List<String> logs = [];
    final DebugPrintCallback original = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => logs.add(m ?? '');
    try {
      await http.runWithClient(
        () => apiClient.getData('/api/v1/delivery-man/order?token=$secret',
            query: {'lat': '31.5123'}, handleError: false),
        () => MockClient((request) async =>
            throw http.ClientException('boom', request.url)),
      );
    } finally {
      debugPrint = original;
    }

    expect(logs, isNotEmpty);
    for (final String line in logs) {
      expect(line, isNot(contains(secret)));
      expect(line, isNot(contains('31.5123')));
    }
  });

  test('G1 guard: requests carry the Bearer header', () async {
    await http.runWithClient(
      () => apiClient.getData(AppConstants.walletUri, handleError: false),
      () => okClient('{}'),
    );
    expect(requests.single.headers['Authorization'], 'Bearer $secret');
  });

  test('G5 guard: multipart update-order-status carries the Bearer header '
      'and no token field', () async {
    final repository =
        OrderRepository(apiClient: apiClient, sharedPreferences: prefs);
    final result = await http.runWithClient(
      () => repository.updateOrderStatus(
          UpdateStatusBodyModel(orderId: 42, status: 'picked_up'), []),
      () => okClient(jsonEncode({'message': 'ok'})),
    );

    expect(result.isSuccess, isTrue);
    expect(requests.single, isA<http.Request>());
    expect(requests.single.headers['Authorization'], 'Bearer $secret');
    expect(requests.single.url.queryParameters.containsKey('token'), isFalse);
    expect(bodies.single, isNot(contains(secret)));
    expect(bodies.single, contains('picked_up'));
  });

  test('T9 chat search sends the name URL-encoded and intact (audit row 50)',
      () async {
    final repository =
        ChatRepository(apiClient: apiClient, sharedPreferences: prefs);
    await http.runWithClient(
      () => repository.searchConversationList('a&b+c #d'),
      () => okClient('{}'),
    );

    final Uri url = requests.single.url;
    expect(url.queryParameters['name'], 'a&b+c #d');
    expect(url.queryParameters.containsKey('token'), isFalse);
    expect(url.toString(), isNot(contains(secret)));
  });
}
