import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:doghree_rider/features/auth/domain/models/vehicle_model.dart';
import 'package:doghree_rider/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:doghree_rider/helper/json_helper.dart';
import 'package:doghree_rider/helper/push_client.dart';
import 'package:doghree_rider/util/app_constants.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  final PushClient push;
  final Duration pushTimeout;
  Future<bool>? _pushCleanup;

  AuthRepository({
    required this.apiClient,
    required this.sharedPreferences,
    PushClient? push,
    this.pushTimeout = const Duration(seconds: 5),
  }) : push = push ?? const PushClient();

  @override
  Future<Response> login(String phone, String password) async {
    return await apiClient.postData(
        AppConstants.loginUri, {"phone": phone, "password": password},
        handleError: false);
  }

  @override
  Future<Response> registerDeliveryMan(DeliveryManBodyModel deliveryManBody,
      List<MultipartBody> multiParts) async {
    return await apiClient.postMultipartData(
        AppConstants.dmRegisterUri, deliveryManBody.toJson(), multiParts,
        handleError: false);
  }

  @override
  Future<List<VehicleModel>?> getList() async {
    final Response response = await apiClient.getData(AppConstants.vehiclesUri);
    if (response.statusCode != 200) return null;
    // A body that is not a List is a failure; a bad item is skipped (row 52).
    return JsonHelper.mapList(response.body, VehicleModel.fromJson,
        name: 'vehicles');
  }

  @override
  Future<Response> updateToken() async {
    // A logout that could not release the old device token finishes first,
    // so getToken below never hands the server a token that is about to die.
    await retryPendingPushCleanup();
    // Notifications off: no automatic caller (splash, app start, language
    // change, login) may register a token. Only toggling them on does.
    if (!isNotificationActive()) {
      return const Response(statusCode: 0, statusText: 'notifications_off');
    }
    String? deviceToken;
    if (!GetPlatform.isWeb) {
      try {
        if (!GetPlatform.isIOS || await push.requestPermissionIos()) {
          deviceToken = await push.getToken();
        }
      } catch (e) {
        if (kDebugMode) debugPrint('FCM getToken failed: ${e.runtimeType}');
      }
      for (final t in _topics()) {
        push.subscribe(t).catchError((Object e) {
          if (kDebugMode) debugPrint('FCM subscribe failed: ${e.runtimeType}');
        });
      }
    }
    // The server requires fcm_token, so a call without one can only fail.
    if (deviceToken == null || deviceToken.isEmpty) {
      return const Response(statusCode: 0, statusText: 'fcm_token_unavailable');
    }
    return await apiClient.postData(AppConstants.tokenUri,
        {"_method": "put", "fcm_token": deviceToken},
        handleError: false);
  }

  /// All or nothing: topics first, the token last, and the in-memory auth
  /// header only once the token is on disk. Any failure rolls everything
  /// back and rethrows.
  @override
  Future<bool> saveUserToken(
      String token, String? zoneTopic, String? vehicleWiseTopic) async {
    try {
      final bool saved =
          await _setOrRemove(AppConstants.zoneTopic, zoneTopic) &&
              await _setOrRemove(
                  AppConstants.vehicleWiseTopic, vehicleWiseTopic) &&
              await sharedPreferences.setString(AppConstants.token, token);
      if (!saved) throw StateError('token not saved');
    } catch (_) {
      for (final key in [
        AppConstants.token,
        AppConstants.zoneTopic,
        AppConstants.vehicleWiseTopic,
      ]) {
        try {
          await sharedPreferences.remove(key);
        } catch (_) {}
      }
      _setAuthHeader(null);
      rethrow;
    }
    _setAuthHeader(token);
    return true;
  }

  Future<bool> _setOrRemove(String key, String? value) {
    return (value == null || value.isEmpty)
        ? sharedPreferences.remove(key)
        : sharedPreferences.setString(key, value);
  }

  /// Sets or clears the Bearer token and always keeps the current language.
  void _setAuthHeader(String? token) {
    apiClient.token = token;
    apiClient.updateHeader(
        token, sharedPreferences.getString(AppConstants.languageCode));
  }

  @override
  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }

  /// Ends the local session, then releases the device for push.
  ///
  /// No server call runs here: update-fcm-token requires fcm_token, so the
  /// device token is invalidated on the device instead (deleteToken). If FCM
  /// is unreachable, the cleanup is saved as pending and retried at the next
  /// start, on the sign-in screen and before the next login gets a token.
  @override
  Future<bool> clearSharedData() async {
    final List<String> topics = _topics();
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.setStringList(AppConstants.ignoreList, []);
    await sharedPreferences.remove(AppConstants.userAddress);
    await sharedPreferences.remove(AppConstants.zoneTopic);
    await sharedPreferences.remove(AppConstants.vehicleWiseTopic);
    _setAuthHeader(null);
    if (!GetPlatform.isWeb) await _releasePush(topics);
    return true;
  }

  @override
  Future<bool> retryPendingPushCleanup() async {
    if (GetPlatform.isWeb) return true;
    return _runPushCleanup();
  }

  /// Marks the cleanup as pending before trying it, so a failure, a timeout
  /// or a killed app all leave it to be retried.
  Future<bool> _releasePush(List<String> topics) async {
    try {
      final List<String> pending =
          sharedPreferences.getStringList(AppConstants.fcmCleanupTopics) ?? [];
      await sharedPreferences.setStringList(
          AppConstants.fcmCleanupTopics, {...pending, ...topics}.toList());
      await sharedPreferences.setBool(AppConstants.fcmCleanupPending, true);
    } catch (e) {
      if (kDebugMode) debugPrint('FCM cleanup flag failed: ${e.runtimeType}');
    }
    return _runPushCleanup();
  }

  /// One cleanup at a time. A caller that arrives while one runs waits for
  /// it, then runs again only if something is still pending.
  Future<bool> _runPushCleanup() async {
    while (_pushCleanup != null) {
      await _pushCleanup;
    }
    if (!(sharedPreferences.getBool(AppConstants.fcmCleanupPending) ??
        false)) {
      return true;
    }
    final Future<bool> run = _pushCleanupOnce();
    _pushCleanup = run;
    try {
      return await run;
    } finally {
      if (identical(_pushCleanup, run)) _pushCleanup = null;
    }
  }

  /// The flag is cleared only after deleteToken succeeds.
  Future<bool> _pushCleanupOnce() async {
    try {
      await _pushCleanupSteps().timeout(pushTimeout);
      await sharedPreferences.remove(AppConstants.fcmCleanupTopics);
      await sharedPreferences.remove(AppConstants.fcmCleanupPending);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('FCM cleanup pending: ${e.runtimeType}');
      return false;
    }
  }

  Future<void> _pushCleanupSteps() async {
    final List<String> topics =
        sharedPreferences.getStringList(AppConstants.fcmCleanupTopics) ?? [];
    for (final t in topics) {
      await push.unsubscribe(t);
    }
    await push.deleteToken();
  }

  /// Remember-me keeps the phone only. A password saved by an older version
  /// is removed.
  @override
  Future<void> saveUserNumber(
      String number, String countryDialCode, String countryCode) async {
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.setString(AppConstants.userNumber, number);
    await sharedPreferences.setString(
        AppConstants.userCountryDialCode, countryDialCode);
    await sharedPreferences.setString(
        AppConstants.userCountryCode, countryCode);
  }

  @override
  Future<void> purgeStoredPassword() async {
    await sharedPreferences.remove(AppConstants.userPassword);
  }

  @override
  Future<void> setLogoutReason(String reason) async {
    await sharedPreferences.setString(AppConstants.logoutReason, reason);
  }

  @override
  Future<String?> getLogoutReason() async {
    return sharedPreferences.getString(AppConstants.logoutReason);
  }

  @override
  Future<void> clearLogoutReason() async {
    await sharedPreferences.remove(AppConstants.logoutReason);
  }

  @override
  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  @override
  String getUserCountryDialCode() {
    return sharedPreferences.getString(AppConstants.userCountryDialCode) ?? "";
  }

  @override
  String getUserCountryCode() {
    return sharedPreferences.getString(AppConstants.userCountryCode) ?? "";
  }

  @override
  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  @override
  Future<void> setNotificationActive(bool isActive) async {
    // Saved first: updateToken reads it and registers only when it is on.
    await sharedPreferences.setBool(AppConstants.notification, isActive);
    if (isActive) {
      updateToken().then((_) {}, onError: (Object e) {
        if (kDebugMode) debugPrint('FCM updateToken failed: ${e.runtimeType}');
      });
    } else if (!GetPlatform.isWeb) {
      // Same release as logout; update-fcm-token without a token only fails.
      _releasePush(_topics());
    }
  }

  @override
  Future<bool> clearUserNumber() async {
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.remove(AppConstants.userCountryDialCode);
    await sharedPreferences.remove(AppConstants.userCountryCode);
    return await sharedPreferences.remove(AppConstants.userNumber);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  List<String> _topics() {
    return [
      AppConstants.topic,
      sharedPreferences.getString(AppConstants.zoneTopic) ?? '',
      sharedPreferences.getString(AppConstants.vehicleWiseTopic) ?? '',
    ].where((t) => t.isNotEmpty && t != 'No_topic_found').toList();
  }
}
