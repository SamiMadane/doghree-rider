import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_model.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  NotificationRepository(
      {required this.apiClient, required this.sharedPreferences});

  @override
Future<List<NotificationModel>?> getList({int? offset}) async {
  List<NotificationModel>? notificationList;
  Response response = await apiClient.getData(AppConstants.notificationUri);

  print('🔍 API Response Length: ${response.body.length}');
  print('🔍 Raw API Response: ${response.body}');

  if (response.statusCode == 200) {
    notificationList = [];

    response.body.forEach((notification) {
      // طباعة القيم الخام من API
      print('------------------------------');
      print('🔔 Notification ID (raw): ${notification['id']}');
      print('📥 is_read from API (raw): ${notification['is_read']}');

      // التحويل إلى Model
      NotificationModel notify = NotificationModel.fromJson(notification);

      // طباعة بعد التحويل
      print('✅ Notification ID: ${notify.id}');
      print('✅ isRead (parsed): ${notify.isRead}');
      print('------------------------------');

      notificationList!.add(notify);
    });
  }

  return notificationList;
}

  // ✅ الجديد - Server-side marking
  Future<bool> _patchMarkRead(List<int> notificationIds,
      {bool all = false}) async {
    try {
      Response response = await apiClient.patchData(
        all
            ? AppConstants.markAllNotificationsReadUri
            : AppConstants.markNotificationReadUri,
        all ? {} : {'notification_ids': notificationIds},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error marking notifications as read: $e');
      return false;
    }
  }

  @override
  Future<bool> markNotificationAsRead(int notificationId) async {
    return await _patchMarkRead([notificationId]);
  }

  @override
  Future<bool> markNotificationsAsRead(List<int> notificationIds) async {
    return await _patchMarkRead(notificationIds);
  }

  @override
  Future<bool> markAllNotificationsAsRead() async {
    return await _patchMarkRead([], all: true);
  }

  @override
  Future<bool> sendDeliveredNotification(int? orderID) async {
    Response response = await apiClient.postData(
        AppConstants.deliveredOrderNotificationUri,
        {"_method": "put", 'token': _getUserToken(), 'order_id': orderID});
    return (response.statusCode == 200);
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  // ═══════════════════════════════════════════════════════
  // الدوال القديمة للتوافق - ما تغيرش
  // ═══════════════════════════════════════════════════════
  @override
  void saveSeenNotificationCount(int count) {
    sharedPreferences.setInt(AppConstants.notificationCount, count);
  }

  @override
  int? getSeenNotificationCount() {
    return sharedPreferences.getInt(AppConstants.notificationCount);
  }

  @override
  List<int> getNotificationIdList() {
    List<String>? list = [];
    if (sharedPreferences.containsKey(AppConstants.notificationIdList)) {
      list = sharedPreferences.getStringList(AppConstants.notificationIdList);
    }
    List<int> notificationIdList = [];
    for (var id in list ?? []) {
      notificationIdList.add(jsonDecode(id));
    }
    return notificationIdList;
  }

  @override
  void addSeenNotificationIdList(List<int> notificationList) {
    List<String> list = [];
    for (int id in notificationList) {
      list.add(jsonEncode(id));
    }
    sharedPreferences.setStringList(AppConstants.notificationIdList, list);
  }

  @override
  Future add(value) => throw UnimplementedError();
  @override
  Future delete(int? id) => throw UnimplementedError();
  @override
  Future get(int? id) => throw UnimplementedError();
  @override
  Future update(Map<String, dynamic> body) => throw UnimplementedError();
}
