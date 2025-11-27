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

  bool _hideNotificationButton = false;
  bool get hideNotificationButton => _hideNotificationButton;

  void handleNotificationTap(NotificationModel notification) {
    // تسجيل الإشعار كمقروء
    addSeenNotificationId(notification.id!);

    // إذا لم يكن هناك بيانات إضافية، لا تفعل شيء
    if (notification.data == null || notification.data!.type == null) {
      return;
    }

    print('Raw type from API: "${notification.data!.type}"');
    print('Order ID: ${notification.data!.orderId}');

    // استدعاء الدالة وحفظ النتيجة
    NotificationType notificationType =
        _convertStringToNotificationType(notification.data!.type!);
    print('Converted Notification Type: $notificationType');

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
        // إشعار عام - لا حاجة للتنقل
        break;
    }
  }

// الدالة يجب أن تكون خارج handleNotificationTap
  NotificationType _convertStringToNotificationType(String type) {
    String cleanType =
        type.replaceAll('NotificationType.', '').toLowerCase().trim();

    print('Clean type: "$cleanType"');

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
        print('Unknown type: "$cleanType"');
        return NotificationType.general;
    }
  }

  Future<void> getNotificationList() async {
    List<NotificationModel>? notificationList =
        await notificationServiceInterface.getNotificationList();
    if (notificationList != null) {
      _notificationList = [];
      _notificationList!.addAll(notificationList);
      _notificationList!.sort((a, b) {
        return DateConverterHelper.isoStringToLocalDate(a.updatedAt!)
            .compareTo(DateConverterHelper.isoStringToLocalDate(b.updatedAt!));
      });
      Iterable iterable = _notificationList!.reversed;
      _notificationList = iterable.toList() as List<NotificationModel>?;
      _hasNotification =
          _notificationList!.length != getSeenNotificationCount();
    }
    update();
  }

  Future<bool> sendDeliveredNotification(int? orderID) async {
    _hideNotificationButton = true;
    update();
    bool isSuccess =
        await notificationServiceInterface.sendDeliveredNotification(orderID);
    bool success;
    isSuccess ? success = true : success = false;
    _hideNotificationButton = false;
    update();
    return success;
  }

  void saveSeenNotificationCount(int count) {
    notificationServiceInterface.saveSeenNotificationCount(count);
  }

  int? getSeenNotificationCount() {
    return notificationServiceInterface.getSeenNotificationCount();
  }

  void addSeenNotificationId(int id) {
    List<int> idList = [];
    idList.addAll(notificationServiceInterface.getNotificationIdList());
    idList.add(id);
    notificationServiceInterface.addSeenNotificationIdList(idList);
    update();
  }

  List<int>? getSeenNotificationIdList() {
    return notificationServiceInterface.getNotificationIdList();
  }
}
