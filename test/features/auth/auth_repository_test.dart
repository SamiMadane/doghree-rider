import 'package:doghree_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

/// Records every updateHeader call (token, language).
class HeaderRecordingApiClient extends FakeApiClient {
  final List<List<String?>> headerCalls = [];
  HeaderRecordingApiClient({required super.sharedPreferences});

  @override
  void updateHeader(String? token, String? languageCode) {
    headerCalls.add([token, languageCode]);
    super.updateHeader(token, languageCode);
  }
}

/// Real prefs, except that writing the auth token throws.
class TokenWriteFailsPrefs implements SharedPreferences {
  final SharedPreferences inner;
  TokenWriteFailsPrefs(this.inner);

  @override
  Future<bool> setString(String key, String value) {
    if (key == AppConstants.token) throw StateError('disk full');
    return inner.setString(key, value);
  }

  @override
  String? getString(String key) => inner.getString(key);
  @override
  bool? getBool(String key) => inner.getBool(key);
  @override
  List<String>? getStringList(String key) => inner.getStringList(key);
  @override
  bool containsKey(String key) => inner.containsKey(key);
  @override
  Future<bool> remove(String key) => inner.remove(key);
  @override
  Future<bool> setBool(String key, bool value) => inner.setBool(key, value);
  @override
  Future<bool> setStringList(String key, List<String> value) =>
      inner.setStringList(key, value);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Audit rows 14 and 15 and the D-02 logout FCM note. These tests use only
/// the API that already existed before D-03, so they also run on old code.
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.token: 'old-token',
      AppConstants.languageCode: 'ar',
      AppConstants.zoneTopic: 'zone_1_push',
      AppConstants.vehicleWiseTopic: 'delivery_man_1_2',
    });
    prefs = await SharedPreferences.getInstance();
  });

  test('T4 a failed token write saves nothing and leaves no auth header (row 14)',
      () async {
    await prefs.remove(AppConstants.token);
    await prefs.remove(AppConstants.zoneTopic);
    await prefs.remove(AppConstants.vehicleWiseTopic);
    final failing = TokenWriteFailsPrefs(prefs);
    final api = HeaderRecordingApiClient(sharedPreferences: failing);
    final repo = AuthRepository(apiClient: api, sharedPreferences: failing);

    await expectLater(
        repo.saveUserToken('new-token', 'zone_2_push', 'delivery_man_2_1'),
        throwsA(anything));

    expect(prefs.containsKey(AppConstants.token), isFalse);
    expect(prefs.containsKey(AppConstants.zoneTopic), isFalse);
    expect(prefs.containsKey(AppConstants.vehicleWiseTopic), isFalse);
    expect(api.token, isNull);
    expect(api.headerCalls.last.first, isNull);
  });

  test('T5 logout keeps the current language header (row 15)', () async {
    final api = HeaderRecordingApiClient(sharedPreferences: prefs);
    final repo = AuthRepository(apiClient: api, sharedPreferences: prefs);

    await repo.clearSharedData();

    expect(api.headerCalls.last, [null, 'ar']);
    expect(prefs.containsKey(AppConstants.token), isFalse);
  });

  test('T6 logout sends no update-fcm-token call without fcm_token (D-02 note)',
      () async {
    final api = HeaderRecordingApiClient(sharedPreferences: prefs);
    final repo = AuthRepository(apiClient: api, sharedPreferences: prefs);

    await repo.clearSharedData();

    expect(api.calls.where((c) => c.uri == AppConstants.tokenUri), isEmpty);
  });

  test('G2 guard: a saved token keeps the language header', () async {
    await prefs.remove(AppConstants.token);
    final api = HeaderRecordingApiClient(sharedPreferences: prefs);
    final repo = AuthRepository(apiClient: api, sharedPreferences: prefs);

    await repo.saveUserToken('new-token', 'zone_2_push', 'delivery_man_2_1');

    expect(prefs.getString(AppConstants.token), 'new-token');
    expect(api.headerCalls.last, ['new-token', 'ar']);
  });
}
