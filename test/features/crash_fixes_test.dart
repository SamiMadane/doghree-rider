import 'dart:convert';

import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/chat/controllers/chat_controller.dart';
import 'package:doghree_rider/features/chat/domain/models/message_model.dart';
import 'package:doghree_rider/features/chat/domain/repositories/chat_repository.dart';
import 'package:doghree_rider/features/chat/domain/services/chat_service_interface.dart';
import 'package:doghree_rider/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:doghree_rider/features/forgot_password/domain/repositories/forgot_password_repository.dart';
import 'package:doghree_rider/features/forgot_password/domain/services/forgot_password_service.dart';
import 'package:doghree_rider/features/notification/controllers/notification_controller.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository.dart';
import 'package:doghree_rider/features/notification/domain/services/notification_service.dart';
import 'package:doghree_rider/features/notification/domain/services/notification_service_interface.dart';
import 'package:doghree_rider/features/order/domain/repositories/order_repository.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_api_client.dart';

/// D-12 crash fixes C1-C5, C8 and C10. Every test here compiles against the
/// old code too, so each one is run there to prove it failed before.
const Response _html200 =
    Response(statusCode: 200, body: '<html><body>Login to Wi-Fi</body></html>');

/// Chat service whose send either throws or returns nothing.
class _FailingChatService implements ChatServiceInterface {
  final bool throws;
  _FailingChatService({required this.throws});

  @override
  dynamic noSuchMethod(Invocation invocation) {
    switch (invocation.memberName) {
      case #processMultipartBody:
        return <MultipartBody>[];
      case #processSendMessage:
        if (throws) return Future<MessageModel?>.error(StateError('send'));
        return Future<MessageModel?>.value(null);
    }
    return super.noSuchMethod(invocation);
  }
}

/// Notification service whose mark-all throws.
class _ThrowingMarkAllService implements NotificationServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #markAllNotificationsAsRead) {
      return Future<bool>.error(StateError('mark all'));
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late SharedPreferences prefs;
  late FakeApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = FakeApiClient(sharedPreferences: prefs, nextResponse: _html200);
  });

  tearDown(Get.reset);

  group('C1 chat: a 200 with an HTML body is a failure, not a TypeError', () {
    late ChatRepository repo;
    setUp(() => repo = ChatRepository(apiClient: api, sharedPreferences: prefs));

    test('C1a conversation list', () async {
      expect(await repo.getConversationList(1), isNull);
    });

    test('C1b conversation search', () async {
      expect(await repo.searchConversationList('name'), isNull);
    });

    test('C1c send message', () async {
      expect(await repo.sendMessage('hi', [], 1, null, 'customer'), isNull);
    });
  });

  group('C2 chat send: the loader always stops', () {
    test('C2a a failed send', () async {
      final controller =
          ChatController(chatServiceInterface: _FailingChatService(throws: false));
      final bool ok = await controller.sendMessage(
          message: 'hi', notificationBody: null, conversationId: 1);
      expect(ok, isFalse);
      expect(controller.isLoading, isFalse);
    });

    test('C2b a send that throws', () async {
      final controller =
          ChatController(chatServiceInterface: _FailingChatService(throws: true));
      await controller
          .sendMessage(message: 'hi', notificationBody: null, conversationId: 1)
          .catchError((_) => false);
      expect(controller.isLoading, isFalse);
    });
  });

  group('C3 forgot password: an HTML 200 fails cleanly', () {
    late ForgotPasswordController controller;
    setUp(() => controller = ForgotPasswordController(
        forgotPasswordServiceInterface: ForgotPasswordService(
            forgotPasswordRepositoryInterface: ForgotPasswordRepository(
                apiClient: api, sharedPreferences: prefs))));

    test('C3a verify code', () async {
      final result = await controller.verifyToken('0599000000');
      expect(result.isSuccess, isFalse);
      expect(result.message, 'error_occurred');
      expect(controller.isLoading, isFalse);
    });

    test('C3b reset password', () async {
      final result = await controller.resetPassword(
          'reset', '0599000000', 'secret12', 'secret12');
      expect(result.isSuccess, isFalse);
      expect(controller.isLoading, isFalse);
    });

    test('C3c guard: a JSON 200 is still a success with its message', () async {
      api.nextResponse =
          const Response(statusCode: 200, body: {'message': 'done'});
      final result = await controller.verifyToken('0599000000');
      expect(result.isSuccess, isTrue);
      expect(result.message, 'done');
    });
  });

  test('C4 a notification without updated_at does not hide the list',
      () async {
    api.nextResponse = const Response(statusCode: 200, body: [
      {'id': 1, 'title': 'old', 'updated_at': '2026-11-01T10:00:00.000000Z'},
      {'id': 2, 'title': 'no date', 'updated_at': null},
      {'id': 3, 'title': 'new', 'updated_at': '2026-11-02T10:00:00.000000Z'},
    ]);
    final controller = NotificationController(
        notificationServiceInterface: NotificationService(
            notificationRepositoryInterface: NotificationRepository(
                apiClient: api, sharedPreferences: prefs)));

    await controller.getNotificationList();

    expect(controller.notificationList!.map((n) => n.id), [3, 1, 2]);
  });

  test('C5 mark-all-read that throws still stops the loader', () async {
    final controller = NotificationController(
        notificationServiceInterface: _ThrowingMarkAllService());
    await controller.markAllNotificationsAsRead().catchError((_) {});
    expect(controller.isLoading, isFalse);
  });

  test('C8 cancel reasons: an HTML 200 gives no list, not a TypeError',
      () async {
    final repo = OrderRepository(apiClient: api, sharedPreferences: prefs);
    expect(await repo.getCancelReasons(), isNull);
  });

  group('C10 a corrupt stored entry is skipped', () {
    test('C10a ignored order requests', () async {
      await prefs.setStringList(AppConstants.ignoreList, [
        jsonEncode({'id': 7, 'time': '01-11-2026 10:00'}),
        'not json',
      ]);
      final list = OrderRepository(apiClient: api, sharedPreferences: prefs)
          .getIgnoreList();
      expect(list.map((e) => e.id), [7]);
    });

    test('C10b seen notification ids', () async {
      await prefs
          .setStringList(AppConstants.notificationIdList, ['4', '{broken']);
      final ids = NotificationRepository(apiClient: api, sharedPreferences: prefs)
          .getNotificationIdList();
      expect(ids, [4]);
    });
  });
}
