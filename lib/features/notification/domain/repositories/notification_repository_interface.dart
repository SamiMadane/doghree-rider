import 'package:wefrh_rider/interface/repository_interface.dart';
import 'package:wefrh_rider/features/notification/domain/models/notification_model.dart';

abstract class NotificationRepositoryInterface extends RepositoryInterface {
  // ✅ الجديد - Server-side read status
  Future<List<NotificationModel>?> getList({int? offset});
  Future<bool> markNotificationAsRead(int notificationId);
  Future<bool> markNotificationsAsRead(List<int> notificationIds);
  Future<bool> markAllNotificationsAsRead();

  // القديم للتوافق
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  List<int> getNotificationIdList();
  void addSeenNotificationIdList(List<int> notificationList);
  Future<dynamic> sendDeliveredNotification(int? orderID);
}
