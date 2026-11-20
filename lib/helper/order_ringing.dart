import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// The Android calls behind [OrderRinging]. Replaced by a fake in unit tests.
class RingingClient {
  const RingingClient();

  Future<bool> isRunning() async {
    if (!GetPlatform.isAndroid) return false;
    return FlutterForegroundTask.isRunningService;
  }

  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }

  Future<void> deleteChannel(String id) async {
    if (!GetPlatform.isAndroid) return;
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(id);
  }
}

/// Stops the order-request ringing (the foreground service that plays
/// `notification.mp3` every 5 s). Every stop point in the app calls [stop].
///
/// This only touches the app's own foreground-service channel. The channel
/// the server pushes on (`doghree_rider`, the manifest default) is never
/// created, changed or deleted here (audit rows 36, 37).
class OrderRinging {
  /// 12 rings at the 5 s interval is 60 s. A backgrounded app cannot learn
  /// that another rider took the order, so this is the last guard.
  static const int maxRings = 12;

  /// The foreground-service channel of the app.
  static const String channelId = 'doghree_rider_ringing';

  /// The old foreground-service channel (a leftover from the template).
  static const String legacyChannelId = 'stackfood';

  @visibleForTesting
  static RingingClient client = const RingingClient();

  static bool shouldStopAfter(int ringCount) => ringCount >= maxRings;

  /// The service notification title. An unknown order id never prints "null".
  static String title(NotificationType type, int? orderId) {
    if (type == NotificationType.order_request) return 'Order Notification';
    return orderId == null
        ? 'You have been assigned a new order'
        : 'You have been assigned a new order ($orderId)';
  }

  /// Idempotent and silent: stops the service only when it runs, and never
  /// throws, so no caller (logout included) can be blocked by it.
  static Future<void> stop() async {
    try {
      if (await client.isRunning()) await client.stop();
    } catch (e) {
      if (kDebugMode) debugPrint('OrderRinging.stop failed: ${e.runtimeType}');
    }
  }

  /// Deletes the old `stackfood` channel once it is no longer needed. It
  /// accepts only that exact id and never runs while the service runs
  /// (Android would kill a foreground service whose channel is deleted).
  static Future<bool> retireLegacyChannel(
      {String id = legacyChannelId}) async {
    if (id != legacyChannelId) return false;
    try {
      if (await client.isRunning()) return false;
      await client.deleteChannel(id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('retireLegacyChannel failed: ${e.runtimeType}');
      }
      return false;
    }
  }
}

/// Opening or resuming the app means the rider has seen the request.
class OrderRingingObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) OrderRinging.stop();
  }
}
