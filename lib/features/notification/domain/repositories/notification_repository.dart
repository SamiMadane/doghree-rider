import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/list_load.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_model.dart';
import 'package:doghree_rider/features/notification/domain/repositories/notification_repository_interface.dart';
import 'package:doghree_rider/helper/json_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  NotificationRepository(
      {required this.apiClient, required this.sharedPreferences});

  /// A bare array. A 200 that is not a List is a failure (null) and a bad
  /// item is skipped (audit row 52). The server also returns `200 []` on its
  /// own errors, so an empty list is not proof of "no notifications".
  @override
  Future<List<NotificationModel>?> getList({int? offset}) async =>
      (await loadList()).list;

  /// Silent (D-12): the screen decides whether to show one message
  /// (FirstLoadNotice). A 401 still ends the session.
  @override
  Future<ListLoad<NotificationModel>> loadList() async {
    final Response response = await apiClient
        .getData(AppConstants.notificationUri, handleError: false);
    ApiChecker.checkSession(response);
    if (response.statusCode != 200) return ListLoad.failed(response);
    final List<NotificationModel>? list = JsonHelper.mapList(
        response.body, NotificationModel.fromJson,
        name: 'notifications');
    return list == null
        ? ListLoad<NotificationModel>(null, statusCode: 0)
        : ListLoad<NotificationModel>(list, statusCode: 200);
  }

  // ✅ الجديد - Server-side marking
  // Marking one or more as read happens in the background when a
  // notification is opened, so it is silent (audit row 12). Mark-all is a
  // user tap and keeps ApiChecker's single error message.
  Future<bool> _patchMarkRead(List<int> notificationIds,
      {bool all = false}) async {
    try {
      Response response = await apiClient.patchData(
        all
            ? AppConstants.markAllNotificationsReadUri
            : AppConstants.markNotificationReadUri,
        all ? {} : {'notification_ids': notificationIds},
        handleError: all,
      );
      if (!all) ApiChecker.checkSession(response);
      return response.statusCode == 200;
    } catch (e) {
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
        {"_method": "put", 'order_id': orderID});
    return (response.statusCode == 200);
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
