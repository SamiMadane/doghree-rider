import 'package:firebase_messaging/firebase_messaging.dart';

/// Thin wrapper over [FirebaseMessaging] used by the auth repository, so the
/// login and logout FCM steps can be faked in unit tests.
class PushClient {
  const PushClient();

  /// iOS only: shows the permission prompt. Returns true when authorized.
  Future<bool> requestPermissionIos() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  Future<void> subscribe(String topic) =>
      FirebaseMessaging.instance.subscribeToTopic(topic);

  Future<void> unsubscribe(String topic) =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);

  /// Invalidates this device's FCM token. Pushes the server sends to the old
  /// token, and its topic subscriptions, no longer reach the device.
  Future<void> deleteToken() => FirebaseMessaging.instance.deleteToken();
}
