import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/helper/firebase_state.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/features/forgot_password/domain/repositories/forgot_password_repository_interface.dart';

class ForgotPasswordRepository implements ForgotPasswordRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ForgotPasswordRepository(
      {required this.apiClient, required this.sharedPreferences});
  @override
  Future<ResponseModel> changePassword(
    ProfileModel userInfoModel,
    String currentPassword,
    String newPassword,
  ) async {
    ResponseModel responseModel;

    Map<String, dynamic> body = {
      '_method': 'put',
      'f_name': userInfoModel.fName,
      'l_name': userInfoModel.lName,
      'email': userInfoModel.email,
      'current_password': currentPassword,
      'password': newPassword,
    };

    Response response = await apiClient.postData(
      AppConstants.updateProfileUri,
      body,
      handleError: false,
    );
    if (_isOk(response)) {
      responseModel = ResponseModel(true, _message(response));
    } else {
      responseModel =
          ResponseModel(false, _failText(response));
    }

    return responseModel;
  }

  @override
  Future<ResponseModel> forgetPassword(String? phone) async {
    ResponseModel responseModel;
    String? deviceToken = await _saveDeviceToken();
    Response response = await apiClient.postData(AppConstants.forgetPasswordUri,
        {"phone": phone, "fcm_token": deviceToken},
        handleError: false);
    if (_isOk(response)) {
      responseModel = ResponseModel(true, _message(response));
    } else {
      responseModel = ResponseModel(false, _failText(response),
          statusCode: response.statusCode);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> verifyToken(String? phone, String token) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(
        AppConstants.verifyTokenUri, {"phone": phone, "reset_token": token},
        handleError: false);
    if (_isOk(response)) {
      responseModel = ResponseModel(true, _message(response));
    } else {
      responseModel = ResponseModel(false, _failText(response),
          statusCode: response.statusCode);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> verifyFirebaseOtp(
      {required String phoneNumber,
      required String session,
      required String otp}) async {
    Response response = await apiClient.postData(
      AppConstants.firebaseAuthVerify,
      {
        'sessionInfo': session,
        'phoneNumber': phoneNumber,
        'code': otp,
        'is_reset_token': 1,
      },
    );
    if (_isOk(response)) {
      return ResponseModel(true, _message(response));
    } else {
      return ResponseModel(false, _failText(response));
    }
  }

  @override
  Future<ResponseModel> resetPassword(String? resetToken, String phone,
      String password, String confirmPassword) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(
        AppConstants.resetPasswordUri,
        {
          "_method": "put",
          "phone": phone,
          "reset_token": resetToken,
          "password": password,
          "confirm_password": confirmPassword
        },
        handleError: false);
    if (_isOk(response)) {
      responseModel = ResponseModel(true, _message(response));
    } else {
      responseModel = ResponseModel(false, _failText(response),
          statusCode: response.statusCode);
    }
    return responseModel;
  }

  /// A 200 is a success only when the body is a JSON object. A 200 with an
  /// HTML page (captive Wi-Fi) or anything else cannot confirm the step, so
  /// it is a failure with the generic message (D-12, C3).
  static bool _isOk(Response response) =>
      response.statusCode == 200 && response.body is Map;

  /// The failure text: the server's, or the generic one for an unreadable
  /// 200 (its status text would be a bare OK).
  static String _failText(Response response) {
    final String? text = response.statusText;
    if (response.statusCode == 200 || text == null || text.trim().isEmpty) {
      return 'error_occurred'.tr;
    }
    return text;
  }

  static String? _message(Response response) {
    final dynamic message = (response.body as Map)['message'];
    return message is String ? message : null;
  }

  /// The FCM token sent with forget-password. Empty when Firebase did not
  /// start or FCM fails: the request still goes out (D-12).
  Future<String?> _saveDeviceToken() async {
    if (GetPlatform.isWeb || !FirebaseState.ready) return '';
    try {
      return await FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      if (kDebugMode) debugPrint('FCM getToken failed: ${e.runtimeType}');
      return '';
    }
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
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
}
