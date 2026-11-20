import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/helper/json_helper.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Where a tapped push opens (audit row 35).
enum NotificationTarget {
  none,
  orderDetails,
  requests,
  myOrders,
  chat,
  conversations,
  notifications,
  wallet,
  signIn,
}

/// What the splash does with a cold-start push.
enum ColdStartRouting { notification, defaultRouting }

/// What a foreground chat push does.
enum ChatPushAction { refreshOpenChat, notify }

/// The one push-tap mapping used by the local notification tap,
/// onMessageOpenedApp and the cold start through splash (audit rows 6, 31,
/// 35). Decisions use the push type only, never the text.
class NotificationRouter {
  const NotificationRouter._();

  /// A usable server id, or null (missing, non-numeric, zero or negative).
  static int? validId(dynamic value) {
    final int? id = JsonHelper.asInt(value);
    return id != null && id > 0 ? id : null;
  }

  static NotificationTarget targetFor(NotificationBodyModel? body,
      {required bool isLoggedIn}) {
    if (body == null || !isLoggedIn) return NotificationTarget.none;
    switch (body.notificationType) {
      case NotificationType.order:
        return validId(body.orderId) != null
            ? NotificationTarget.orderDetails
            : NotificationTarget.myOrders;
      // A request push can be for an order this rider cannot carry: open the
      // board (which refreshes itself), never the pushed order (R2).
      case NotificationType.order_request:
      case NotificationType.unassign:
        return NotificationTarget.requests;
      case NotificationType.message:
        return validId(body.conversationId) != null
            ? NotificationTarget.chat
            : NotificationTarget.conversations;
      case NotificationType.withdraw:
        return NotificationTarget.wallet;
      case NotificationType.general:
      case NotificationType.cash_collect:
        return NotificationTarget.notifications;
      case NotificationType.block:
        return NotificationTarget.signIn;
      case NotificationType.unblock:
      case NotificationType.otp:
      case null:
        return NotificationTarget.none;
    }
  }

  static String? routeFor(NotificationBodyModel? body,
          {required bool isLoggedIn}) =>
      _route(targetFor(body, isLoggedIn: isLoggedIn), body);

  static String? _route(NotificationTarget target, NotificationBodyModel? body) {
    switch (target) {
      case NotificationTarget.orderDetails:
        return RouteHelper.getOrderDetailsRoute(validId(body?.orderId),
            fromNotification: true);
      case NotificationTarget.requests:
        return RouteHelper.getMainRoute('order-request');
      case NotificationTarget.myOrders:
        return RouteHelper.getMainRoute('order');
      case NotificationTarget.chat:
        return RouteHelper.getChatRoute(
            notificationBody: body,
            conversationId: validId(body?.conversationId),
            fromNotification: true);
      case NotificationTarget.conversations:
        return RouteHelper.getConversationListRoute();
      case NotificationTarget.notifications:
        return RouteHelper.getNotificationRoute(fromNotification: true);
      case NotificationTarget.wallet:
        return RouteHelper.getWalletRoute();
      case NotificationTarget.signIn:
        return RouteHelper.getSignInRoute();
      case NotificationTarget.none:
        return null;
    }
  }

  /// Splash opens the push only when it has a target. Otherwise the default
  /// routing runs. Exactly one of the two runs.
  static ColdStartRouting coldStartPlan(NotificationBodyModel? body,
          {required bool isLoggedIn}) =>
      targetFor(body, isLoggedIn: isLoggedIn) == NotificationTarget.none
          ? ColdStartRouting.defaultRouting
          : ColdStartRouting.notification;

  /// Dashboard tabs and sign-in replace the stack, so only one Dashboard
  /// (and one push listener) exists.
  static bool replacesStack(NotificationTarget target) =>
      target == NotificationTarget.requests ||
      target == NotificationTarget.myOrders ||
      target == NotificationTarget.signIn;

  /// Opens the push. On a cold start the dashboard goes underneath, so back
  /// never returns to splash (row 6). Returns whether it navigated. Never
  /// throws.
  static bool open(NotificationBodyModel? body, {bool coldStart = false}) {
    try {
      final bool isLoggedIn = Get.isRegistered<AuthController>() &&
          Get.find<AuthController>().isLoggedIn();
      final NotificationTarget target =
          targetFor(body, isLoggedIn: isLoggedIn);
      final String? route = _route(target, body);
      if (route == null) return false;

      if (replacesStack(target)) {
        Get.offAllNamed(route);
      } else if (coldStart) {
        Get.offAllNamed(RouteHelper.getInitialRoute());
        Get.toNamed(route);
      } else {
        Get.toNamed(route);
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Notification route failed: ${e.runtimeType}');
      return false;
    }
  }

  /// A foreground chat push refreshes the open chat only when both ids are
  /// known and equal. While the chat is still loading (no conversation yet),
  /// or for a bad id, the rider gets the notification instead (row 33).
  static ChatPushAction chatPushAction(
          int? openConversationId, dynamic pushedConversationId) {
    final int? pushed = validId(pushedConversationId);
    return pushed != null && pushed == openConversationId
        ? ChatPushAction.refreshOpenChat
        : ChatPushAction.notify;
  }
}

enum ForegroundPushKind { request, assign, block, other }

/// The foreground push data the dashboard acts on (audit row 32). Never
/// throws: a missing or bad order id is null.
class ForegroundOrderPush {
  final ForegroundPushKind kind;
  final int? orderId;
  final bool isParcel;

  const ForegroundOrderPush(this.kind, this.orderId, this.isParcel);

  factory ForegroundOrderPush.fromData(Map<String, dynamic> data) {
    final String? type =
        JsonHelper.asString(data['body_loc_key'] ?? data['type']);
    final ForegroundPushKind kind;
    switch (type) {
      case 'new_order':
      case 'order_request':
        kind = ForegroundPushKind.request;
        break;
      case 'assign':
        kind = ForegroundPushKind.assign;
        break;
      case 'block':
        kind = ForegroundPushKind.block;
        break;
      default:
        kind = ForegroundPushKind.other;
    }
    return ForegroundOrderPush(
      kind,
      NotificationRouter.validId(data['order_id']) ??
          NotificationRouter.validId(data['title_loc_key']),
      data['order_type'] == 'parcel_order',
    );
  }
}
