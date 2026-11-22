import 'package:doghree_rider/features/forgot_password/domain/repositories/forgot_password_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';

/// D-13, audit row 81: the Firebase OTP check works like verifyToken. The
/// screen shows the one message, so the call does not go through ApiChecker,
/// and the status reaches the screen for the rate-limit timer. Compiles
/// against the old code too.
void main() {
  test('V1 a rate-limited OTP check keeps its status and has no toast',
      () async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FakeApiClient api = FakeApiClient(
        sharedPreferences: prefs,
        nextResponse: const Response(
            statusCode: 429,
            statusText: 'too many attempts',
            body: {'message': 'too many attempts'}));
    final ForgotPasswordRepository repo =
        ForgotPasswordRepository(apiClient: api, sharedPreferences: prefs);

    final result = await repo.verifyFirebaseOtp(
        phoneNumber: 'phone', session: 'session', otp: '0000');

    expect(api.last.uri, AppConstants.firebaseAuthVerify);
    expect(api.last.handleError, isFalse);
    expect(result.isSuccess, isFalse);
    expect(result.statusCode, 429);
    expect(result.isRateLimited, isTrue);
    expect(result.message, 'too many attempts');
  });
}
