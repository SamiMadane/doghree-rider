import 'dart:convert';

import 'package:doghree_rider/features/chat/screens/chat_screen.dart';
import 'package:doghree_rider/features/chat/screens/conversation_screen.dart';
import 'package:doghree_rider/features/dashboard/screens/dashboard_screen.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/features/order/screens/order_details_screen.dart';
import 'package:doghree_rider/features/splash/screens/splash_screen.dart';
import 'package:doghree_rider/helper/phone_format_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Arabic text of a length that varies with [i], so some base64 has a `+`.
String _arabic(int i) =>
    String.fromCharCode(0x0621 + i % 40) * (1 + i ~/ 40);

/// Audit row 51. GetX 4.6.6 reads route parameters with
/// Uri.parse(route).queryParameters, so that is what the screens receive.
void main() {
  group('route query encoding (audit row 51)', () {
    test('T10a reset-password route keeps +, & and = intact', () {
      final params = Uri.parse(RouteHelper.getResetPasswordRoute(
              '+10000000000', 'a+b=c&d', 'reset-password'))
          .queryParameters;

      expect(params['phone'], '+10000000000');
      expect(params['token'], 'a+b=c&d');
      expect(params['page'], 'reset-password');
    });

    test('T10b verification route keeps the + and the session', () {
      final params = Uri.parse(RouteHelper.getVerificationRoute('+10000000000',
              session: 'session-1'))
          .queryParameters;

      expect(params['number'], '+10000000000');
      expect(utf8.decode(base64Url.decode(params['session']!)), 'session-1');
      expect(
          Uri.parse(RouteHelper.getVerificationRoute('+10000000000'))
              .queryParameters
              .containsKey('session'),
          isFalse);
    });

    test('T10c phone keeps a single leading + (verification and new password)',
        () {
      expect(PhoneFormat.withPlus('+10000000000'), '+10000000000');
      expect(PhoneFormat.withPlus(' 10000000000 '), '+10000000000');
      expect(PhoneFormat.withPlus(null), '');
    });
  });

  group('push route pages never throw (audit rows 31, 34)', () {
    tearDown(() => Get.parameters = <String, String?>{});

    Widget build(String name, Map<String, String?> params) {
      Get.parameters = params;
      return RouteHelper.routes.firstWhere((p) => p.name == name).page();
    }

    /// Simulates GetX: route values arrive through Uri.parse (+ is a space).
    Map<String, String?> query(String route) =>
        Map<String, String?>.of(Uri.parse(route).queryParameters);

    NotificationBodyModel withPlusInBase64(
        NotificationBodyModel Function(int i) make, String Function(NotificationBodyModel b) encode) {
      for (int i = 1; i < 100000; i++) {
        final NotificationBodyModel body = make(i);
        if (encode(body).contains('+')) return body;
      }
      throw StateError('no body with + in its base64');
    }

    test('N3 order-details with id=null opens My Orders, not a FormatException',
        () {
      final Widget page = build(RouteHelper.orderDetails,
          query(RouteHelper.getOrderDetailsRoute(null, fromNotification: true)));
      expect(page, isA<DashboardScreen>());
      expect((page as DashboardScreen).pageIndex, 2);
    });

    test('N4 chat with a non-numeric conversation_id gives a null id', () {
      final params = query(RouteHelper.getChatRoute(
          notificationBody: NotificationBodyModel(
              notificationType: NotificationType.message, type: 'user'),
          conversationId: 5,
          fromNotification: true));
      params['conversation_id'] = 'abc';
      final Widget page = build(RouteHelper.chatScreen, params);
      expect(page, isA<ChatScreen>());
      expect((page as ChatScreen).conversationId, isNull);
    });

    test('N4b chat with a broken notification_body opens the conversation list',
        () {
      final Widget page = build(RouteHelper.chatScreen, {
        'notification_body': 'not-base64!!',
        'user': 'null',
        'conversation_id': '5',
        'from': 'true',
      });
      expect(page, isA<ConversationScreen>());
    });

    test('G2 navigation-handler keeps a body whose base64 has a + (D-02 note)',
        () {
      String encode(NotificationBodyModel b) => Uri.parse(
              RouteHelper.getNavigationHandlerRoute(b))
          .query;
      final NotificationBodyModel body = withPlusInBase64(
          (i) => NotificationBodyModel(
              notificationType: NotificationType.order,
              orderId: i,
              type: _arabic(i)),
          (b) => base64Encode(utf8.encode(jsonEncode(b.toJson()))));
      expect(encode(body), contains('+'));

      final Widget page = build(RouteHelper.navigationHandler,
          query(RouteHelper.getNavigationHandlerRoute(body)));
      final NotificationBodyModel? decoded = (page as SplashScreen).body;
      expect(decoded!.notificationType, NotificationType.order);
      expect(decoded.orderId, body.orderId);
      expect(decoded.type, body.type);
    });

    test('G3 chat route keeps a body whose base64 has a +', () {
      final NotificationBodyModel body = withPlusInBase64(
          (i) => NotificationBodyModel(
              notificationType: NotificationType.message,
              type: _arabic(i),
              conversationId: i),
          (b) => base64Encode(utf8.encode(jsonEncode(b))));

      final Widget page = build(
          RouteHelper.chatScreen,
          query(RouteHelper.getChatRoute(
              notificationBody: body,
              conversationId: body.conversationId,
              fromNotification: true)));
      final ChatScreen chat = page as ChatScreen;
      expect(chat.notificationBody!.conversationId, body.conversationId);
      expect(chat.notificationBody!.type, body.type);
      expect(chat.conversationId, body.conversationId);
      expect(chat.fromNotification, isTrue);
    });

    test('G5 order-details with a numeric id still opens that order', () {
      final Widget page = build(RouteHelper.orderDetails,
          query(RouteHelper.getOrderDetailsRoute(12, fromNotification: true)));
      expect(page, isA<OrderDetailsScreen>());
      expect((page as OrderDetailsScreen).orderId, 12);
      expect(page.fromNotification, isTrue);
    });
  });
}
