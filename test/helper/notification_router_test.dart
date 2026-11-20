import 'package:doghree_rider/features/chat/controllers/chat_controller.dart';
import 'package:doghree_rider/features/chat/domain/services/chat_service_interface.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/helper/notification_helper.dart';
import 'package:doghree_rider/helper/notification_router.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeChatService implements ChatServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

NotificationBodyModel _body(NotificationType type,
        {int? orderId, int? conversationId}) =>
    NotificationBodyModel(
        notificationType: type,
        orderId: orderId,
        conversationId: conversationId,
        type: type == NotificationType.message ? 'user' : null);

NotificationTarget _target(NotificationBodyModel? body,
        {bool isLoggedIn = true}) =>
    NotificationRouter.targetFor(body, isLoggedIn: isLoggedIn);

/// Push data as the three entry points get it: through convertNotification.
NotificationTarget _fromPush(Map<String, dynamic> data) =>
    _target(NotificationHelper.convertNotification(data));

void main() {
  tearDown(Get.reset);

  group('one push-tap mapping (audit rows 35, 6, 31)', () {
    test('R1 withdraw (order_id empty) opens the wallet', () {
      expect(_fromPush({'type': 'withdraw', 'order_id': ''}),
          NotificationTarget.wallet);
      expect(
          NotificationRouter.routeFor(
              NotificationHelper.convertNotification(
                  {'type': 'withdraw', 'order_id': ''}),
              isLoggedIn: true),
          RouteHelper.getWalletRoute());
    });

    test('R2 order_status with an id opens that order', () {
      final body = NotificationHelper.convertNotification(
          {'type': 'order_status', 'order_id': '42'});
      expect(_target(body), NotificationTarget.orderDetails);
      final params = Uri.parse(
              NotificationRouter.routeFor(body, isLoggedIn: true)!)
          .queryParameters;
      expect(params['id'], '42');
      expect(params['from'], 'true');
    });

    test('R3 order_status or assign without a usable id opens My Orders', () {
      expect(_fromPush({'type': 'order_status'}), NotificationTarget.myOrders);
      expect(_fromPush({'type': 'assign', 'order_id': ''}),
          NotificationTarget.myOrders);
      expect(_fromPush({'type': 'order_status', 'order_id': 'abc'}),
          NotificationTarget.myOrders);
      expect(_target(_body(NotificationType.order, orderId: 0)),
          NotificationTarget.myOrders);
      expect(
          NotificationRouter.routeFor(_body(NotificationType.order),
              isLoggedIn: true),
          RouteHelper.getMainRoute('order'));
    });

    test('R4 new_order and order_request open Requests, never the order', () {
      for (final type in ['new_order', 'order_request']) {
        final body = NotificationHelper.convertNotification(
            {'type': type, 'order_id': '42'});
        expect(_target(body), NotificationTarget.requests);
        expect(NotificationRouter.routeFor(body, isLoggedIn: true),
            RouteHelper.getMainRoute('order-request'));
      }
    });

    test('R5 message with a conversation id opens that chat', () {
      final body = NotificationHelper.convertNotification(
          {'type': 'message', 'conversation_id': '9', 'sender_type': 'user'});
      expect(_target(body), NotificationTarget.chat);
      final params = Uri.parse(
              NotificationRouter.routeFor(body, isLoggedIn: true)!)
          .queryParameters;
      expect(params['conversation_id'], '9');
      expect(params['from'], 'true');
    });

    test('R6 message without a usable id opens the conversation list', () {
      expect(_fromPush({'type': 'message'}), NotificationTarget.conversations);
      expect(_fromPush({'type': 'message', 'conversation_id': 'abc'}),
          NotificationTarget.conversations);
    });

    test('R7 general, cash_collect and unknown types open Notifications', () {
      expect(_fromPush({'type': 'general'}), NotificationTarget.notifications);
      expect(_fromPush({'type': 'cash_collect'}),
          NotificationTarget.notifications);
      expect(_fromPush({'type': 'something_new'}),
          NotificationTarget.notifications);
    });

    test('R8 unassign opens Requests', () {
      expect(_fromPush({'type': 'unassign'}), NotificationTarget.requests);
    });

    test('R9 block opens sign-in (approval note 1)', () {
      expect(_fromPush({'type': 'block'}), NotificationTarget.signIn);
    });

    test('R10 unblock for a logged-in rider does nothing (approval note 1)',
        () {
      expect(_fromPush({'type': 'unblock'}), NotificationTarget.none);
      expect(
          NotificationRouter.routeFor(_body(NotificationType.unblock),
              isLoggedIn: true),
          isNull);
    });

    test('R11 otp and a null body do nothing', () {
      expect(_fromPush({'type': 'otp'}), NotificationTarget.none);
      expect(_target(null), NotificationTarget.none);
      expect(_target(NotificationBodyModel()), NotificationTarget.none);
    });

    test('R12 logged out: no push opens anything', () {
      for (final type in NotificationType.values) {
        expect(
            _target(_body(type, orderId: 1, conversationId: 1),
                isLoggedIn: false),
            NotificationTarget.none,
            reason: '$type');
      }
    });

    test('R13 tabs and sign-in replace the stack; other screens push', () {
      expect(NotificationRouter.replacesStack(NotificationTarget.requests),
          isTrue);
      expect(NotificationRouter.replacesStack(NotificationTarget.myOrders),
          isTrue);
      expect(
          NotificationRouter.replacesStack(NotificationTarget.signIn), isTrue);
      expect(NotificationRouter.replacesStack(NotificationTarget.wallet),
          isFalse);
      expect(NotificationRouter.replacesStack(NotificationTarget.orderDetails),
          isFalse);
    });

    test('R14 open() with no session navigates nothing and never throws', () {
      expect(
          NotificationRouter.open(_body(NotificationType.withdraw),
              coldStart: true),
          isFalse);
      expect(NotificationRouter.open(null), isFalse);
    });
  });

  group('cold start: exactly one routing (approval note 2)', () {
    test('C1 a push with a target routes the notification', () {
      expect(
          NotificationRouter.coldStartPlan(_body(NotificationType.withdraw),
              isLoggedIn: true),
          ColdStartRouting.notification);
      expect(
          NotificationRouter.coldStartPlan(_body(NotificationType.order),
              isLoggedIn: true),
          ColdStartRouting.notification);
    });

    test('C2 no body, otp, unblock or logged out run the default routing', () {
      expect(NotificationRouter.coldStartPlan(null, isLoggedIn: true),
          ColdStartRouting.defaultRouting);
      expect(
          NotificationRouter.coldStartPlan(_body(NotificationType.otp),
              isLoggedIn: true),
          ColdStartRouting.defaultRouting);
      expect(
          NotificationRouter.coldStartPlan(_body(NotificationType.unblock),
              isLoggedIn: true),
          ColdStartRouting.defaultRouting);
      expect(
          NotificationRouter.coldStartPlan(_body(NotificationType.withdraw),
              isLoggedIn: false),
          ColdStartRouting.defaultRouting);
    });
  });

  group('foreground order push (audit row 32)', () {
    test('N8 a request push without order_id: the old parse threw, now null',
        () {
      final Map<String, dynamic> data = {'type': 'new_order'};
      // The old dashboard expression, reproduced inline.
      expect(() => int.parse(data['order_id'].toString()),
          throwsFormatException);

      final push = ForegroundOrderPush.fromData(data);
      expect(push.kind, ForegroundPushKind.request);
      expect(push.orderId, isNull);
    });

    test('F1 kinds, ids and parcel flag', () {
      final request = ForegroundOrderPush.fromData(
          {'type': 'order_request', 'order_id': '15', 'order_type': 'parcel_order'});
      expect(request.kind, ForegroundPushKind.request);
      expect(request.orderId, 15);
      expect(request.isParcel, isTrue);

      final assign =
          ForegroundOrderPush.fromData({'type': 'assign', 'order_id': 'abc'});
      expect(assign.kind, ForegroundPushKind.assign);
      expect(assign.orderId, isNull);
      expect(assign.isParcel, isFalse);

      expect(ForegroundOrderPush.fromData({'type': 'block'}).kind,
          ForegroundPushKind.block);
      expect(ForegroundOrderPush.fromData({'type': 'withdraw', 'order_id': ''}),
          isA<ForegroundOrderPush>()
              .having((p) => p.kind, 'kind', ForegroundPushKind.other)
              .having((p) => p.orderId, 'orderId', isNull));
    });

    test('F2 body_loc_key and title_loc_key keep their old precedence', () {
      final push = ForegroundOrderPush.fromData(
          {'body_loc_key': 'assign', 'type': 'message', 'title_loc_key': '33'});
      expect(push.kind, ForegroundPushKind.assign);
      expect(push.orderId, 33);
    });
  });

  group('chat push while the chat is loading (audit row 33)', () {
    test('N9 no conversation yet: the old read threw, now a notification', () {
      final chat = ChatController(chatServiceInterface: _FakeChatService());
      // The old handler expression, reproduced inline.
      expect(() => chat.messageModel!.conversation!.id, throwsA(anything));

      expect(
          NotificationRouter.chatPushAction(
              chat.messageModel?.conversation?.id, '5'),
          ChatPushAction.notify);
    });

    test('P1 same conversation refreshes; other or bad ids notify', () {
      expect(NotificationRouter.chatPushAction(5, '5'),
          ChatPushAction.refreshOpenChat);
      expect(NotificationRouter.chatPushAction(5, 5),
          ChatPushAction.refreshOpenChat);
      expect(NotificationRouter.chatPushAction(5, '6'), ChatPushAction.notify);
      expect(
          NotificationRouter.chatPushAction(5, 'abc'), ChatPushAction.notify);
      expect(NotificationRouter.chatPushAction(5, null), ChatPushAction.notify);
    });
  });
}
