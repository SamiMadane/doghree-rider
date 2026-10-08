import 'package:wefrh_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:wefrh_rider/features/notification/domain/models/notification_model.dart';
import 'package:wefrh_rider/helper/date_converter_helper.dart';
import 'package:get/get.dart';
import 'package:wefrh_rider/features/notification/domain/services/notification_service_interface.dart';
import 'package:wefrh_rider/helper/route_helper.dart';

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

  /// ✅ معالجة النقر على الإشعار - Server-side
  Future<void> handleNotificationTap(NotificationModel notification) async {
    print('🔔 Notification ID: ${notification.id}');
    print('🔔 Is Read Before: ${notification.isRead}');
    // تحديد الإشعار كمقروء في الـ Backend
    if (!notification.isRead) {
      await markNotificationAsRead(notification.id!);
    }

    // إذا لم يكن هناك بيانات إضافية، لا تفعل شيء
    if (notification.data == null || notification.data!.type == null) {
      return;
    }

    print('🔔 Raw type from API: "${notification.data!.type}"');
    print('🔔 Order ID: ${notification.data!.orderId}');

    NotificationType notificationType =
        _convertStringToNotificationType(notification.data!.type!);
    print('🔔 Converted Notification Type: $notificationType');

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
        Get.snackbar(
          'notification'.tr,
          notification.description ?? '',
          snackPosition: SnackPosition.TOP,
        );
        break;

      case NotificationType.general:
      case NotificationType.otp:
      default:
        break;
    }
  }

  /// ✅ تحديد إشعار واحد كمقروء
  /// ✅ تحديد إشعار واحد كمقروء (نفس منطق اليوزر)
Future<void> markNotificationAsRead(int notificationId) async {
  bool success = await notificationServiceInterface.markNotificationAsRead(notificationId);

  if (success) {
    // ✨ تحديث محلي فقط - نفس اليوزر
    if (_notificationList != null) {
      int index = _notificationList!.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notificationList![index].isRead = true;
        _updateHasNotification();
        update();
        print('✅ Notification $notificationId marked locally');
      }
    }
  } else {
    print('❌ Failed to mark notification $notificationId as read');
  }
}


    /// تحديد جميع الإشعارات كمقروءة
  Future<void> markAllNotificationsAsRead() async {
    _isLoading = true;
    update();

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
      print('✅ All notifications marked as read');
    }

    _isLoading = false;
    update();
  }
  NotificationType _convertStringToNotificationType(String type) {
    String cleanType =
        type.replaceAll('NotificationType.', '').toLowerCase().trim();

    print('🔄 Clean type: "$cleanType"');

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

      default:
        print('⚠️ Unknown type: "$cleanType"');
        return NotificationType.general;
    }
  }

  Future<void> getNotificationList([bool reload = false]) async {
    if (_notificationList == null || reload) {
      List<NotificationModel>? notificationList =
          await notificationServiceInterface.getNotificationList();
      if (notificationList != null) {
        _notificationList = [];
        _notificationList!.addAll(notificationList);
        _notificationList!.sort((a, b) {
          return DateConverterHelper.isoStringToLocalDate(a.updatedAt!)
              .compareTo(
                  DateConverterHelper.isoStringToLocalDate(b.updatedAt!));
        });
        Iterable iterable = _notificationList!.reversed;
        _notificationList = iterable.toList() as List<NotificationModel>?;

        // ✅ حساب الإشعارات غير المقروءة من الـ Backend
        _updateHasNotification();
      }
    }
    update();
  }

  /// ✅ حساب عدد الإشعارات غير المقروءة
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
