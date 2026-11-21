import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:doghree_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/chat/controllers/chat_controller.dart';
import 'package:doghree_rider/features/notification/controllers/notification_controller.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/notification/domain/models/notification_body_model.dart';
import 'package:doghree_rider/helper/app_error_handler.dart';
import 'package:doghree_rider/helper/firebase_state.dart';
import 'package:doghree_rider/helper/notification_router.dart';
import 'package:doghree_rider/helper/order_ringing.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:doghree_rider/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {
  static const String channelId = 'doghree_rider';

  static Future<void> createChannel(FlutterLocalNotificationsPlugin fln) async {
    final channel = AndroidNotificationChannel(
      channelId,
      AppConstants.appName,
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    await fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
    static int _newId() =>
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('ic_notification');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (load) async {
      OrderRinging.stop();
      try {
        final String? payload = load.payload;
        if (payload != null && payload.isNotEmpty) {
          NotificationRouter.open(
              NotificationBodyModel.fromJson(jsonDecode(payload)));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Notification tap failed: ${e.runtimeType}');
      }
      return;
    });
    await createChannel(flutterLocalNotificationsPlugin);
    // Without Firebase there is no push to listen to (D-12).
    if (!FirebaseState.ready) return;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
      }
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().getNotificationList(true);
      }

      if (message.data['type'] == 'message' &&
          Get.currentRoute.startsWith(RouteHelper.chatScreen)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          final ChatController chat = Get.find<ChatController>();
          chat.getConversationList(1);
          // The chat may still be loading (no conversation yet): no forced
          // reads (audit row 33).
          final int? openId = chat.messageModel?.conversation?.id;
          if (NotificationRouter.chatPushAction(
                  openId, message.data['conversation_id']) ==
              ChatPushAction.refreshOpenChat) {
            chat.getMessages(
              1,
              NotificationBodyModel(
                notificationType: NotificationType.message,
                customerId:
                    message.data['sender_type'] == AppConstants.user ? 0 : null,
                vendorId: message.data['sender_type'] == AppConstants.vendor
                    ? 0
                    : null,
              ),
              null,
              openId,
            );
          } else {
            NotificationHelper.showNotification(
                message, flutterLocalNotificationsPlugin);
          }
        }
      } else if (message.data['type'] == 'message' &&
          Get.currentRoute.startsWith(RouteHelper.conversationListScreen)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
      } else if (message.data['type'] == 'otp') {
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
      } else if (message.data['type'] == 'withdraw') {
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().getWallet();
          Get.find<WalletController>().getWithdrawals();
        }
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().getNotificationList();
        }
      } else {
        String? type = message.data['type'];

        if (type != 'assign' &&
            type != 'new_order' &&
            type != 'order_request') {
          NotificationHelper.showNotification(
              message, flutterLocalNotificationsPlugin);
          Get.find<OrderController>().getCurrentOrders();
          Get.find<OrderController>().getLatestOrders();
          Get.find<NotificationController>().getNotificationList();
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      OrderRinging.stop();
      try {
        if (message.data.isNotEmpty) {
          NotificationRouter.open(convertNotification(message.data));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Notification open failed: ${e.runtimeType}');
      }
    });
  }

  static Future<void> showNotification(
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if (!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? image;
      NotificationBodyModel? notificationBody =
          convertNotification(message.data);

      title = message.data['title'] ?? message.notification?.title;
      body = message.data['body'] ?? message.notification?.body ?? '';
      image = (message.data['image'] != null &&
              message.data['image'].isNotEmpty)
          ? message.data['image'].startsWith('http')
              ? message.data['image']
              : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
          : null;

      if (image != null && image.isNotEmpty) {
        try {
          await showBigPictureNotificationHiddenLargeIcon(
              title, body, notificationBody, image, fln);
        } catch (e) {
          await showBigTextNotification(title, body!, notificationBody, fln);
        }
      } else {
        await showBigTextNotification(title, body!, notificationBody, fln);
      }
    }
  }

  static Future<void> showBigTextNotification(
      String? title,
      String body,
      NotificationBodyModel? notificationBody,
      FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'doghree_rider',
      AppConstants.appName,
      color: const Color(0xFFFFC233),
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(_newId()
    , title, body, platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      String? title,
      String? body,
      NotificationBodyModel? notificationBody,
      String image,
      FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'doghree_rider',
      AppConstants.appName,
      color: const Color(0xFFFFC233),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(_newId(), title, body, platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : null);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBodyModel? convertNotification(Map<String, dynamic> data) {
    final type = data['type'];
    // Missing, '' (the withdraw push) or non-numeric gives null (row 34).
    final int? orderId = NotificationRouter.validId(data['order_id']);

    switch (type) {
      case 'cash_collect':
        return NotificationBodyModel(
            notificationType: NotificationType.general);
      case 'unassign':
        return NotificationBodyModel(
            notificationType: NotificationType.unassign);
      case 'order_status':
        return NotificationBodyModel(
            orderId: orderId, notificationType: NotificationType.order);
      case 'assign':
        return NotificationBodyModel(
            orderId: orderId, notificationType: NotificationType.order);
      case 'new_order':
      case 'order_request':
        return NotificationBodyModel(
            orderId: orderId,
            notificationType: NotificationType.order_request);
      case 'withdraw':
        return NotificationBodyModel(
            notificationType: NotificationType.withdraw);
      case 'block':
        return NotificationBodyModel(notificationType: NotificationType.block);
      case 'unblock':
        return NotificationBodyModel(
            notificationType: NotificationType.unblock);
      case 'otp':
        return NotificationBodyModel(notificationType: NotificationType.otp);
      case 'message':
        return _handleMessageNotification(data);
      default:
        return NotificationBodyModel(
            notificationType: NotificationType.general);
    }
  }

  static NotificationBodyModel _handleMessageNotification(
      Map<String, dynamic> data) {
    final senderType = data['sender_type'];

    return NotificationBodyModel(
      // A missing, non-numeric or int id never throws (audit row 34).
      conversationId: NotificationRouter.validId(data['conversation_id']),
      notificationType: NotificationType.message,
      type: senderType == AppConstants.user
          ? AppConstants.user
          : AppConstants.vendor,
    );
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  // Background isolate: nothing here may throw (D-12). A failure is logged
  // (debug only, sanitized) and the push is dropped.
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    final String? type = message.data['type']?.toString();
    final int? orderId = int.tryParse('${message.data['order_id'] ?? ''}');

    if (type == 'assign' || type == 'new_order' || type == 'order_request') {
      FlutterForegroundTask.initCommunicationPort();
      _initService();
      await _startService(
        orderId,
        type == 'assign'
            ? NotificationType.order
            : NotificationType.order_request,
      );
    } else if (GetPlatform.isAndroid && message.notification == null) {
      // data-only: النظام ما بعرضه، فنعرضه إحنا
      final fln = FlutterLocalNotificationsPlugin();
      await fln.initialize(const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification')));
      await NotificationHelper.createChannel(fln);
      await NotificationHelper.showNotification(message, fln);
    }
  } catch (e) {
    AppErrorHandler.log('Background push failed: ${e.runtimeType}');
  }
}

@pragma('vm:entry-point')
Future<ServiceRequestResult> _startService(
    int? orderId, NotificationType notificationType) async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: OrderRinging.title(notificationType, orderId),
      notificationText: notificationType == NotificationType.order_request
          ? 'New order request arrived, you can confirmed this.'
          : 'Open app and check order details.',
      callback: startCallback,
      // notificationButtons: [
      //   const NotificationButton(id: '1', text: 'Open'),
      // ],
      // notificationInitialRoute: RouteHelper.getOrderDetailsRoute(int.parse(orderId!), fromNotification: true),
    );
  }
}

@pragma('vm:entry-point')
void _initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: OrderRinging.channelId,
      channelName: 'Order ringing',
      channelDescription:
          'This notification appears when the foreground service is running.',
      onlyAlertOnce: false,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<ServiceRequestResult> stopService() async {
  try {
    await _audioPlayer.stop();
    _audioPlayer.dispose();
  } catch (e) {
  if (kDebugMode) debugPrint('stopService failed: $e');
}
  return FlutterForegroundTask.stopService();
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

final AudioPlayer _audioPlayer = AudioPlayer();

class MyTaskHandler extends TaskHandler {
  int _rings = 0;

  void _playAudio() {
    // A new push restarts the service, which makes a new handler, so the
    // count starts again (audit row 36).
    if (OrderRinging.shouldStopAfter(_rings)) {
      stopService();
      return;
    }
    _rings++;
    _audioPlayer.play(AssetSource('notification.mp3'));
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _playAudio();
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) {
    _playAudio();
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    stopService();
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    _playAudio();
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    if (id == '1') {
      FlutterForegroundTask.launchApp('/');
    }
    stopService();
  }

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {

    FlutterForegroundTask.launchApp('/');
    stopService();
  }

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {
    // Swiping the notification away means the rider has seen it.
    stopService();
  }
}
