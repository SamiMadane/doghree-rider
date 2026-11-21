import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_model.dart';
import 'package:doghree_rider/common/models/list_load.dart';
import 'package:doghree_rider/helper/date_converter_helper.dart';
import 'package:doghree_rider/helper/first_load_notice.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/notification/domain/services/notification_service_interface.dart';
import 'package:doghree_rider/helper/route_helper.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationServiceInterface notificationServiceInterface;
  NotificationController({required this.notificationServiceInterface});

  List<NotificationModel>? _notificationList;
  List<NotificationModel>? get notificationList => _notificationList;

  bool _hasNotification = false;
  bool get hasNotification => _hasNotification;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hideNotificationButton = false;
  bool get hideNotificationButton => _hideNotificationButton;

  /// Every message of this controller goes through here. Production always
  /// uses [showCustomSnackBar]; tests replace it only to count messages.
  @visibleForTesting
  void Function(String? message, {bool isError}) toast = showCustomSnackBar;

  

  /// ✅ معالجة النقر على الإشعار - Server-side
  Future<void> handleNotificationTap(NotificationModel notification) async {
    // تحديد الإشعار كمقروء في الـ Backend
    if (!notification.isRead) {
      await markNotificationAsRead(notification.id!);
    }

    // إذا لم يكن هناك بيانات إضافية، لا تفعل شيء
    if (notification.data == null || notification.data!.type == null) {
      return;
    }


    NotificationType notificationType =
        _convertStringToNotificationType(notification.data!.type!);

    // التنقل بناءً على نوع الإشعار
    switch (notificationType) {
      case NotificationType.order:
      case NotificationType.order_request:
        if (notification.data!.orderId != null) {
          Get.toNamed(
              RouteHelper.getOrderDetailsRoute(notification.data!.orderId!));
        }
        break;

      case NotificationType.message:
        if (notification.data!.conversationId != null) {
          NotificationBodyModel body = NotificationBodyModel(
            notificationType: NotificationType.message,
            orderId: notification.data!.orderId,
            customerId: notification.data!.customerId,
            vendorId: notification.data!.vendorId,
            conversationId: notification.data!.conversationId,
          );
          Get.toNamed(RouteHelper.getChatRoute(notificationBody: body));
        }
        break;

      case NotificationType.cash_collect:
        if (notification.data!.orderId != null) {
          Get.toNamed(
              RouteHelper.getOrderDetailsRoute(notification.data!.orderId!));
        }
        break;

      case NotificationType.unassign:
        Get.toNamed(RouteHelper.getMainRoute('order'));
        break;

      case NotificationType.block:
      case NotificationType.unblock:
        showCustomSnackBar(notification.description ?? '', isError: false);
        break;
      case NotificationType.withdraw:
        Get.toNamed(RouteHelper.getWalletRoute());
        break;

      case NotificationType.general:
      case NotificationType.otp:
        break;
    }
  }

  /// ✅ تحديد إشعار واحد كمقروء
  /// ✅ تحديد إشعار واحد كمقروء (نفس منطق اليوزر)
  Future<void> markNotificationAsRead(int notificationId) async {
    bool success = await notificationServiceInterface
        .markNotificationAsRead(notificationId);

    if (success) {
      // ✨ تحديث محلي فقط - نفس اليوزر
      if (_notificationList != null) {
        int index =
            _notificationList!.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notificationList![index].isRead = true;
          _updateHasNotification();
          update();
        }
      }
    } else {
    }
  }

  /// تحديد جميع الإشعارات كمقروءة
  Future<void> markAllNotificationsAsRead() async {
    _isLoading = true;
    update();

    // The loader stops even when the call throws (D-12, C5).
    try {
      bool success =
          await notificationServiceInterface.markAllNotificationsAsRead();

      if (success) {
        // تحديث جميع الإشعارات محلياً
        if (_notificationList != null) {
          for (var notification in _notificationList!) {
            notification.isRead = true;
          }
          _hasNotification = false;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('markAllNotificationsAsRead failed: ${e.runtimeType}');
    } finally {
      _isLoading = false;
      update();
    }
  }

  NotificationType _convertStringToNotificationType(String type) {
    String cleanType =
        type.replaceAll('NotificationType.', '').toLowerCase().trim();


    switch (cleanType) {
      case 'message':
        return NotificationType.message;

      case 'order':
      case 'order_status':
      case 'order_accepted':
      case 'order_confirmed':
      case 'order_processing':
      case 'order_handover':
      case 'order_picked_up':
        return NotificationType.order;

      case 'order_request':
      case 'new_order':
        return NotificationType.order_request;

      case 'block':
        return NotificationType.block;

      case 'unblock':
        return NotificationType.unblock;

      case 'otp':
        return NotificationType.otp;

      case 'cash_collect':
      case 'collect_cash':
        return NotificationType.cash_collect;

      case 'unassign':
      case 'order_canceled':
        return NotificationType.unassign;

      case 'withdraw':
        return NotificationType.withdraw;

      default:
        return NotificationType.general;
    }
  }

  /// Silent load (D-12). With [announce], a failure while no list was ever
  /// loaded shows exactly one message (FirstLoadNotice); with data on screen
  /// it stays silent. Push and resume refreshes never announce.
  Future<LoadAttempt> getNotificationList(
      {bool reload = false, bool announce = false}) async {
    final bool hadData = _notificationList != null;
    if (hadData && !reload) {
      return const LoadAttempt(ok: true, hadData: true);
    }
    LoadAttempt attempt;
    try {
      final ListLoad<NotificationModel> load =
          await notificationServiceInterface.getNotificationList();
      final List<NotificationModel>? notificationList = load.list;
      attempt = LoadAttempt(
          ok: load.ok,
          hadData: hadData,
          statusCode: load.statusCode,
          message: load.message);
      if (notificationList != null) {
        _notificationList = [];
        _notificationList!.addAll(notificationList);
        // Newest first. A missing or unreadable date sorts last instead of
        // throwing and hiding the whole list (D-12, C4).
        _notificationList!.sort((a, b) {
          final DateTime? da = _dateOf(a);
          final DateTime? db = _dateOf(b);
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });

        // ✅ حساب الإشعارات غير المقروءة من الـ Backend
        _updateHasNotification();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('getNotificationList failed: ${e.runtimeType}');
      attempt = LoadAttempt(ok: false, hadData: hadData, statusCode: 0);
    }
    update();
    if (announce) {
      final String? message = FirstLoadNotice.pick([attempt]);
      if (message != null) toast(message);
    }
    return attempt;
  }

  /// ✅ حساب عدد الإشعارات غير المقروءة
  static DateTime? _dateOf(NotificationModel n) {
    final String? value = n.updatedAt;
    if (value == null || value.isEmpty) return null;
    try {
      return DateConverterHelper.isoStringToLocalDate(value);
    } catch (_) {
      return null;
    }
  }

  int getUnreadNotificationCount() {
    if (_notificationList == null) return 0;
    return _notificationList!.where((n) => !n.isRead).length;
  }

  /// ✅ تحديث حالة وجود إشعارات غير مقروءة
  void _updateHasNotification() {
    _hasNotification = getUnreadNotificationCount() > 0;
  }

  Future<bool> sendDeliveredNotification(int? orderID) async {
    _hideNotificationButton = true;
    update();
    bool isSuccess =
        await notificationServiceInterface.sendDeliveredNotification(orderID);
    _hideNotificationButton = false;
    update();
    return isSuccess;
  }

  // ═══════════════════════════════════════════════════════
  // الدوال القديمة - @Deprecated للتوافق
  // ═══════════════════════════════════════════════════════
  @Deprecated('Use server-side read status instead')
  void saveSeenNotificationCount(int count) {
    notificationServiceInterface.saveSeenNotificationCount(count);
  }

  @Deprecated('Use server-side read status instead')
  int? getSeenNotificationCount() {
    return notificationServiceInterface.getSeenNotificationCount();
  }

  @Deprecated('Use server-side read status instead')
  void addSeenNotificationId(int id) {
    List<int> idList = [];
    idList.addAll(notificationServiceInterface.getNotificationIdList());
    idList.add(id);
    notificationServiceInterface.addSeenNotificationIdList(idList);
    update();
  }

  @Deprecated('Use server-side read status instead')
  List<int>? getSeenNotificationIdList() {
    return notificationServiceInterface.getNotificationIdList();
  }
}
