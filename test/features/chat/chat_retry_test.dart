import 'dart:async';

import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/auth/domain/services/auth_service_interface.dart';
import 'package:doghree_rider/features/chat/controllers/chat_controller.dart';
import 'package:doghree_rider/features/chat/domain/repositories/chat_repository.dart';
import 'package:doghree_rider/features/chat/domain/services/chat_service.dart';
import 'package:doghree_rider/features/chat/screens/chat_screen.dart';
import 'package:doghree_rider/features/chat/screens/conversation_screen.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_api_client.dart';
import '../../helpers/pump_phone.dart';

/// D-13: Conversations and Chat after a failed first load. Every test here
/// compiles against the old code too, so each one is run there to prove it
/// failed before.
const Response _offline = Response(statusCode: 1, statusText: 'no internet');
const Response _server = Response(statusCode: 500, statusText: 'server');

Map<String, dynamic> _conversation(int id) => {
      'id': id,
      'sender_type': 'customer',
      'receiver_type': 'delivery_man',
      'unread_message_count': 0,
      'last_message_time': '2026-11-20 10:00:00',
      'sender': {'id': 100 + id, 'f_name': 'Customer', 'l_name': '$id'},
      'receiver': {'id': 1, 'f_name': 'Rider', 'l_name': 'Test'},
      'last_message': {'message': 'hello', 'sender_id': 100 + id},
    };

Response _page(List<int> ids, {int total = 20, int offset = 1}) => Response(
    statusCode: 200,
    body: {
      'total_size': total,
      'limit': 10,
      'offset': offset,
      'conversation': ids.map(_conversation).toList(),
    });

/// Holds GET answers until [release], so a request can stay in flight.
class _GatedApiClient extends FakeApiClient {
  Completer<void>? gate;
  _GatedApiClient({required super.sharedPreferences, super.nextResponse});

  @override
  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    final Response response = await super.getData(uri,
        query: query, headers: headers, handleError: handleError);
    if (gate != null) await gate!.future;
    return response;
  }
}

class _LoggedInAuthService implements AuthServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    switch (invocation.memberName) {
      case #isNotificationActive:
      case #isLoggedIn:
        return true;
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late SharedPreferences prefs;
  late _GatedApiClient api;
  late ChatRepository repo;
  late ChatController chat;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    api = _GatedApiClient(sharedPreferences: prefs, nextResponse: _offline);
    repo = ChatRepository(apiClient: api, sharedPreferences: prefs);
    chat = ChatController(
        chatServiceInterface: ChatService(chatRepositoryInterface: repo));
  });

  tearDown(() {
    ApiChecker.isLoggingOut = false;
    Get.reset();
  });

  int conversationGets() =>
      api.getUris.where((u) => u == AppConstants.getConversationListUri).length;

  group('silent first loads (no toast; the screen shows its state)', () {
    test('R1 the conversation list does not use ApiChecker toasts', () async {
      await repo.getConversationList(1);
      expect(api.getHandleErrors.last, isFalse);
    });

    test('R2 messages do not use ApiChecker toasts', () async {
      await repo.getMessages(1, null, AppConstants.user, 5);
      expect(api.getHandleErrors.last, isFalse);
    });

    test('G3 guard: search is a tap and keeps its one ApiChecker message',
        () async {
      await repo.searchConversationList('name');
      expect(api.getHandleErrors.last, isTrue);
    });
  });

  group('conversation list data', () {
    test('R4 a failed refresh keeps the list on screen', () async {
      api.nextResponse = _page([1, 2]);
      await chat.getConversationList(1);

      api.nextResponse = _offline;
      await chat.getConversationList(1);

      expect(chat.conversationModel, isNotNull);
      expect(chat.conversationModel!.conversations!.map((c) => c.id), [1, 2]);
    });

    test('R5 page 2 is added below page 1', () async {
      api.nextResponse = _page([1, 2], total: 12);
      await chat.getConversationList(1);

      api.nextResponse = _page([3], total: 12, offset: 2);
      await chat.getConversationList(2);

      expect(chat.conversationModel!.conversations!.map((c) => c.id),
          [1, 2, 3]);
    });
  });

  group('Conversations screen', () {
    Future<void> open(WidgetTester tester) async {
      Get.put<ChatController>(chat);
      await pumpPhone(tester, const ConversationScreen());
      await tester.pump();
    }

    testWidgets('W1 offline first load: no-connection state with Retry',
        (tester) async {
      await open(tester);

      expect(find.text('no_connection'), findsOneWidget);
      expect(find.text('retry'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('W2 a server error: server-problem state', (tester) async {
      api.nextResponse = _server;
      await open(tester);

      expect(find.text('server_problem'), findsOneWidget);
      expect(find.text('no_connection'), findsNothing);
    });

    testWidgets('W3 two quick taps on Retry send one request',
        (tester) async {
      await open(tester);
      expect(conversationGets(), 1);

      // The retry request stays in flight while the rider taps again.
      api.gate = Completer<void>();
      await tester.tap(find.text('retry'));
      await tester.tap(find.byType(TextButton), warnIfMissed: false);
      await tester.pump();

      // While it runs, the spinner replaces the state: nothing to tap.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('retry'), findsNothing);
      expect(conversationGets(), 2);

      api.gate!.complete();
      api.gate = null;
      await tester.pump();
      await tester.pump();
      expect(find.text('no_connection'), findsOneWidget);
      expect(conversationGets(), 2);
    });

    testWidgets('G1 guard: a 401 shows no failure state (the session sheet)',
        (tester) async {
      ApiChecker.isLoggingOut = true;
      api.nextResponse = const Response(statusCode: 401);
      await open(tester);

      expect(find.text('no_connection'), findsNothing);
      expect(find.text('server_problem'), findsNothing);
    });
  });

  group('Chat screen', () {
    final NotificationBodyModel body = NotificationBodyModel(
        notificationType: NotificationType.message,
        customerId: 7,
        type: AppConstants.user);

    Future<void> open(WidgetTester tester) async {
      Get.put<AuthController>(
          AuthController(authServiceInterface: _LoggedInAuthService()));
      Get.put<ChatController>(chat);
      await pumpPhone(tester,
          ChatScreen(notificationBody: body, user: null, conversationId: 5));
      await tester.pump();
    }

    testWidgets('W6 offline first load: no-connection state in the messages',
        (tester) async {
      await open(tester);

      expect(find.text('no_connection'), findsOneWidget);
      expect(find.text('retry'), findsOneWidget);
    });

    testWidgets('S1 a failed send keeps the typed text', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField), 'on my way');
      await tester.pump();
      await tester.tap(find.ancestor(
          of: find.byType(AnimatedContainer), matching: find.byType(InkWell)));
      await tester.pump();
      await tester.pump();

      expect(api.calls.where((c) => c.method == 'MULTIPART'), hasLength(1));
      expect(find.text('on my way'), findsOneWidget);
    });
  });
}
