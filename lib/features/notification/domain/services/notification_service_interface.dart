import 'package:wefrh_rider/features/notification/domain/models/notification_model.dart';

abstract class NotificationServiceInterface {
  Future<List<NotificationModel>?> getNotificationList();

  // ✅ الجديد - Server-side
  Future<bool> markNotificationAsRead(int notificationId);
  Future<bool> markNotificationsAsRead(List<int> notificationIds);
  Future<bool> markAllNotificationsAsRead();

  Future<bool> sendDeliveredNotification(int? orderID);
  
  // القديم للتوافق
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  List<int> getNotificationIdList();
  void addSeenNotificationIdList(List<int> notificationList);
}
