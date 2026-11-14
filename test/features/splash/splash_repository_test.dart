import 'package:doghree_rider/features/splash/domain/repositories/splash_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  late SharedPreferences prefs;
  late FakeApiClient apiClient;
  late SplashRepository repository;

  Future<void> setUpWith(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    prefs = await SharedPreferences.getInstance();
    apiClient = FakeApiClient(sharedPreferences: prefs);
    repository = SplashRepository(apiClient: apiClient, sharedPreferences: prefs);
  }

  group('initSharedData (audit row 2)', () {
    test('T1 fresh install: one call fills every default', () async {
      await setUpWith({});

      final bool result = await repository.initSharedData();

      expect(result, isTrue);
      expect(prefs.getBool(AppConstants.theme), isFalse);
      expect(prefs.getString(AppConstants.countryCode),
          AppConstants.languages[0].countryCode);
      expect(prefs.getString(AppConstants.languageCode),
          AppConstants.languages[0].languageCode);
      expect(prefs.getBool(AppConstants.notification), isTrue);
      expect(prefs.getInt(AppConstants.notificationCount), 0);
      expect(prefs.getStringList(AppConstants.ignoreList), isEmpty);
    });

    test('T2 guard: existing values are not overwritten', () async {
      await setUpWith({
        AppConstants.theme: true,
        AppConstants.languageCode: 'ar',
        AppConstants.notification: false,
      });

      await repository.initSharedData();

      expect(prefs.getBool(AppConstants.theme), isTrue);
      expect(prefs.getString(AppConstants.languageCode), 'ar');
      expect(prefs.getBool(AppConstants.notification), isFalse);
    });
  });

  group('getConfigData (audit row 4)', () {
    test('T3 config is loaded with handleError: false (no extra toast)',
        () async {
      await setUpWith({});

      await repository.getConfigData();

      expect(apiClient.getUris, [AppConstants.configUri]);
      expect(apiClient.getHandleErrors, [false]);
    });
  });
}
