import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/features/auth/domain/models/delivery_man_body_model.dart';
import 'package:doghree_rider/features/auth/domain/models/vehicle_model.dart';
import 'package:doghree_rider/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepository({required this.apiClient, required this.sharedPreferences});

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
    List<VehicleModel>? vehicles;
    Response response = await apiClient.getData(AppConstants.vehiclesUri);
    if (response.statusCode == 200) {
      vehicles = [];
      response.body
          .forEach((vehicle) => vehicles!.add(VehicleModel.fromJson(vehicle)));
    }
    return vehicles;
  }

  @override
  Future<Response> updateToken() async {
    String? deviceToken;
    if (GetPlatform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        deviceToken = await _saveDeviceToken();
      }
    } else {
      deviceToken = await _saveDeviceToken();
    }
    if (!GetPlatform.isWeb) {
      for (final t in _topics()) {
        FirebaseMessaging.instance.subscribeToTopic(t);
      }
    }
    return await apiClient.postData(AppConstants.tokenUri,
        {"_method": "put", "token": getUserToken(), "fcm_token": deviceToken},
        handleError: false);
  }

  Future<String?> _saveDeviceToken() async {
    String? deviceToken = '';
    if (!GetPlatform.isWeb) {
      deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
    }
    debugPrint('----Device Token----- $deviceToken');
    return deviceToken;
  }

  @override
  Future<bool> saveUserToken(
      String token, String zoneTopic, String vehicleWiseTopic) async {
    apiClient.token = token;
    apiClient.updateHeader(
        token, sharedPreferences.getString(AppConstants.languageCode));
    sharedPreferences.setString(AppConstants.zoneTopic, zoneTopic);
    sharedPreferences.setString(
        AppConstants.vehicleWiseTopic, vehicleWiseTopic);

    return await sharedPreferences.setString(AppConstants.token, token);
  }

  @override
  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }

  @override
  Future<bool> clearSharedData() async {
    if (!GetPlatform.isWeb) {
      try {
        for (final t in _topics()) {
          await FirebaseMessaging.instance.unsubscribeFromTopic(t);
        }
      } catch (_) {}
      apiClient.postData(
          AppConstants.tokenUri, {"_method": "put", "token": getUserToken()},
          handleError: false);
    }
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.setStringList(AppConstants.ignoreList, []);
    await sharedPreferences.remove(AppConstants.userAddress);
    apiClient.updateHeader(null, null);
    return true;
  }

  @override
  Future<void> saveUserNumberAndPassword(String number, String password,
      String countryDialCode, String countryCode) async {
    try {
      await sharedPreferences.setString(AppConstants.userPassword, password);
      await sharedPreferences.setString(AppConstants.userNumber, number);
      await sharedPreferences.setString(
          AppConstants.userCountryDialCode, countryDialCode);
      await sharedPreferences.setString(
          AppConstants.userCountryCode, countryCode);
    } catch (e) {
      rethrow;
    }
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
  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.userPassword) ?? "";
  }

  @override
  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  @override
  void setNotificationActive(bool isActive) {
    if (isActive) {
      updateToken();
    } else {
      if (!GetPlatform.isWeb) {
        apiClient.postData(
            AppConstants.tokenUri, {"_method": "put", "token": getUserToken()},
            handleError: false);
        for (final t in _topics()) {
          FirebaseMessaging.instance.unsubscribeFromTopic(t);
        }
      }
    }
    sharedPreferences.setBool(AppConstants.notification, isActive);
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
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
