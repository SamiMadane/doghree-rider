import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/auth/domain/services/auth_service_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Every call goes through noSuchMethod, so this fake compiles against the
/// old and the new AuthServiceInterface alike.
class _FakeAuthService implements AuthServiceInterface {
  Response loginResponse;
  bool loginThrows = false;
  bool updateTokenThrows = false;
  final List<List<Object?>> savedTokens = [];

  _FakeAuthService(this.loginResponse);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    switch (invocation.memberName) {
      case #isNotificationActive:
        return true;
      case #login:
        if (loginThrows) return Future<Response>.error(StateError('boom'));
        return Future<Response>.value(loginResponse);
      case #saveUserToken:
        savedTokens.add(invocation.positionalArguments);
        return Future<bool>.value(true);
      case #updateToken:
        if (updateTokenThrows) {
          return Future<Response>.error(StateError('getToken failed'));
        }
        return Future<Response>.value(const Response(statusCode: 200));
    }
    return super.noSuchMethod(invocation);
  }
}

/// Audit row 14: login.
void main() {
  test('T1 a rider with no zone logs in and the loader stops', () async {
    final service = _FakeAuthService(const Response(statusCode: 200, body: {
      'token': 'tok',
      'topic': 'No_topic_found',
      'zone_topic': null,
    }));
    final controller = AuthController(authServiceInterface: service);

    final result = await controller.login('+970599000000', 'secret1');

    expect(result.isSuccess, isTrue);
    expect(controller.isLoading, isFalse);
    expect(service.savedTokens, [
      ['tok', null, 'No_topic_found']
    ]);
  });

  test('T2 an FCM failure after login does not fail or block the login',
      () async {
    final service = _FakeAuthService(const Response(statusCode: 200, body: {
      'token': 'tok',
      'topic': 'delivery_man_1_2',
      'zone_topic': 'zone_1_push',
    }))
      ..updateTokenThrows = true;
    final controller = AuthController(authServiceInterface: service);

    final result = await controller.login('+970599000000', 'secret1');
    await Future<void>.delayed(Duration.zero);

    expect(result.isSuccess, isTrue);
    expect(controller.isLoading, isFalse);
  });

  test('T3 an exception during login stops the loader and fails', () async {
    final service = _FakeAuthService(const Response(statusCode: 200))
      ..loginThrows = true;
    final controller = AuthController(authServiceInterface: service);

    final result = await controller.login('+970599000000', 'secret1');

    expect(result.isSuccess, isFalse);
    expect(controller.isLoading, isFalse);
  });

  test('G1 guard: a 401 fails, saves nothing and stops the loader', () async {
    final service = _FakeAuthService(const Response(
        statusCode: 401, statusText: 'wrong credentials'));
    final controller = AuthController(authServiceInterface: service);

    final result = await controller.login('+970599000000', 'secret1');

    expect(result.isSuccess, isFalse);
    expect(result.message, 'wrong credentials');
    expect(controller.isLoading, isFalse);
    expect(service.savedTokens, isEmpty);
  });
}
