import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  late FakeApiClient apiClient;
  late ProfileRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    apiClient = FakeApiClient(sharedPreferences: prefs);
    repository = ProfileRepository(apiClient: apiClient, sharedPreferences: prefs);
  });

  Future<ProfileResult> fetchWith(Response response) {
    apiClient.nextResponse = response;
    return repository.getProfileInfo();
  }

  group('getProfileInfo (audit row 3)', () {
    test('T4 offline or timeout (statusCode 1) is offline, not expired',
        () async {
      final result = await fetchWith(const Response(
          statusCode: 1, statusText: ApiClient.noInternetMessage));

      expect(result.status, SessionStatus.offline);
      expect(result.profile, isNull);
      expect(apiClient.getHandleErrors, [false]);
    });

    test('T5 server error, 403 and unknown failure are unverified', () async {
      expect((await fetchWith(const Response(statusCode: 500))).status,
          SessionStatus.unverified);
      expect((await fetchWith(const Response(statusCode: 403))).status,
          SessionStatus.unverified);
      expect((await fetchWith(const Response(statusCode: 0))).status,
          SessionStatus.unverified);
    });

    test('T6 401 is expired', () async {
      final result = await fetchWith(const Response(statusCode: 401));
      expect(result.status, SessionStatus.expired);
      expect(result.profile, isNull);
    });

    test('T7 200 with a valid body is valid and parsed', () async {
      final result = await fetchWith(const Response(statusCode: 200, body: {
        'id': 7,
        'f_name': 'Test',
        'active': 1,
        'identity_image_full_url': <String>[],
      }));

      expect(result.status, SessionStatus.valid);
      expect(result.profile?.id, 7);
      expect(result.profile?.active, 1);
    });
  });
}
