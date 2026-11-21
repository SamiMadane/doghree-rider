import 'package:doghree_rider/helper/firebase_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Thin wrapper over [FirebaseMessaging] used by the auth repository, so the
/// login and logout FCM steps can be faked in unit tests.
///
/// Every method is async, so a Firebase error always arrives as a failed
/// future, never as a synchronous throw at the call site. When Firebase did
/// not start ([FirebaseState.ready] is false, D-12) no Firebase call is made:
/// there is no token and no topic change, and the logout cleanup fails so it
/// stays pending for the next start.
class PushClient {
  const PushClient();

  static StateError get _notReady => StateError('firebase_not_ready');

  /// iOS only: shows the permission prompt. Returns true when authorized.
  Future<bool> requestPermissionIos() async {
    if (!FirebaseState.ready) return false;
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

  Future<String?> getToken() async {
    if (!FirebaseState.ready) return null;
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> subscribe(String topic) async {
    if (!FirebaseState.ready) return;
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribe(String topic) async {
    if (!FirebaseState.ready) throw _notReady;
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  /// Invalidates this device's FCM token. Pushes the server sends to the old
  /// token, and its topic subscriptions, no longer reach the device.
  Future<void> deleteToken() async {
    if (!FirebaseState.ready) throw _notReady;
    await FirebaseMessaging.instance.deleteToken();
  }
}
