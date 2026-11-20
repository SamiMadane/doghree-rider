import 'package:doghree_rider/features/chat/domain/repositories/chat_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

/// Audit row 54: the empty-messages check in ChatRepository.getMessages.
void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;
  late ChatRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs);
    repo = ChatRepository(apiClient: api, sharedPreferences: prefs);
  });

  tearDown(Get.reset);

  Future<dynamic> load() => repo.getMessages(1, null, AppConstants.user, 5);

  group('message details body shapes (audit row 54)', () {
    test('N5 a 200 List body is a failure (null), not a throw', () async {
      api.nextResponse = const Response(statusCode: 200, body: []);
      expect(await load(), isNull);
    });

    test('N6 a null messages field gives an empty list', () async {
      api.nextResponse =
          const Response(statusCode: 200, body: {'messages': null});
      final model = await load();
      expect(model, isNotNull);
      expect(model.messages, isEmpty);
    });

    test('N7 a String messages field gives an empty list', () async {
      api.nextResponse =
          const Response(statusCode: 200, body: {'messages': 'x'});
      final model = await load();
      expect(model.messages, isEmpty);
    });

    test('G4 an empty messages list still gives a model (new conversation)',
        () async {
      api.nextResponse = const Response(statusCode: 200, body: {
        'total_size': 0,
        'limit': 10,
        'offset': 1,
        'messages': [],
      });
      final model = await load();
      expect(model, isNotNull);
      expect(model.messages, isEmpty);
      expect(model.totalSize, 0);
    });
  });
}
