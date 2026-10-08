import 'package:wefrh_rider/features/notification/domain/models/notification_model.dart';
import 'package:wefrh_rider/features/notification/domain/repositories/notification_repository_interface.dart';
import 'package:wefrh_rider/features/notification/domain/services/notification_service_interface.dart';

class NotificationService implements NotificationServiceInterface {
  final NotificationRepositoryInterface notificationRepositoryInterface;
  NotificationService({required this.notificationRepositoryInterface});

  @override
  Future<List<NotificationModel>?> getNotificationList() async {
    return await notificationRepositoryInterface.getList();
  }

  // ✅ الجديد - Server-side
  @override
  Future<bool> markNotificationAsRead(int notificationId) async {
    return await notificationRepositoryInterface.markNotificationAsRead(notificationId);
  }

  @override
  Future<bool> markNotificationsAsRead(List<int> notificationIds) async {
    return await notificationRepositoryInterface.markNotificationsAsRead(notificationIds);
  }

  @override
  Future<bool> markAllNotificationsAsRead() async {
    return await notificationRepositoryInterface.markAllNotificationsAsRead();
  }

  @override
  Future<bool> sendDeliveredNotification(int? orderID) async {
    return await notificationRepositoryInterface.sendDeliveredNotification(orderID);
  }

  // القديم - optional للتوافق
  @override
  void saveSeenNotificationCount(int count) {}
  @override
  int? getSeenNotificationCount() => null;
  @override
  List<int> getNotificationIdList() => [];
  @override
  void addSeenNotificationIdList(List<int> notificationList) {}
}
