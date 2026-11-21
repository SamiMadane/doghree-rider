import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:doghree_rider/common/models/config_model.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ProfileRepository implements ProfileRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  final ConfigModel? Function() _config;
  final WebSocketChannel Function(Uri) _socketFactory;

  /// [config] and [socketFactory] are replaced in unit tests.
  ProfileRepository({
    required this.apiClient,
    required this.sharedPreferences,
    ConfigModel? Function()? config,
    WebSocketChannel Function(Uri)? socketFactory,
  })  : _config = config ?? _configFromSplash,
        _socketFactory = socketFactory ?? WebSocketChannel.connect;

  static ConfigModel? _configFromSplash() => Get.isRegistered<SplashController>()
      ? Get.find<SplashController>().configModel
      : null;

  @override
  Future<ProfileResult> getProfileInfo() async {
    Response response = await apiClient.getData(
      AppConstants.profileUri,
      handleError: false,
    );

    final SessionStatus status = sessionStatusFromCode(response.statusCode);
    if (status != SessionStatus.valid) {
      return ProfileResult(status: status);
    }
    try {
      return ProfileResult(
        profile: ProfileModel.fromJson(response.body),
        status: SessionStatus.valid,
      );
    } catch (_) {
      return const ProfileResult(status: SessionStatus.unverified);
    }
  }

  /// Multipart (60 s), silent: the controller shows the one message. A 401
  /// still ends the session. Only fields that have a value are sent, and the
  /// image part only when a photo was picked (audit row 47).
  @override
  Future<ResponseModel> updateProfile(ProfileModel userInfoModel, XFile? data) async {
    final Map<String, String> fields = <String, String>{'_method': 'put'};
    if (userInfoModel.fName != null) fields['f_name'] = userInfoModel.fName!;
    if (userInfoModel.lName != null) fields['l_name'] = userInfoModel.lName!;
    if (userInfoModel.email != null) fields['email'] = userInfoModel.email!;
    final Response response = await apiClient.postMultipartData(
        AppConstants.updateProfileUri,
        fields,
        [if (data != null) MultipartBody('image', data)],
        handleError: false);
    ApiChecker.checkSession(response);
    if (response.statusCode == 200) {
      final dynamic body = response.body;
      final String? message =
          body is Map && body['message'] is String ? body['message'] as String : null;
      return ResponseModel(true, message, statusCode: 200);
    }
    return ResponseModel(false, response.statusText, statusCode: response.statusCode);
  }

  @override
  Future<ResponseModel> updateActiveStatus() async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.activeStatusUri, {}, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<bool> recordWebSocketLocation(RecordLocationBodyModel recordLocationBody) async {
    final ConfigModel? config = _config();
    final String? host = config?.webSocketUri;
    final int? port = config?.webSocketPort;
    final String? key = config?.webSocketKey;
    if (host == null || host.isEmpty || port == null || key == null || key.isEmpty) {
      return false;
    }
    WebSocketChannel? channel;
    StreamSubscription<dynamic>? subscription;
    try {
      recordLocationBody.token = _getUserToken();
      channel = _socketFactory(Uri.parse('$host:$port/delivery-man/live-location?appKey=$key'));
      // A late socket error must not become an unhandled exception.
      subscription = channel.stream.listen((_) {}, onError: (_) {}, cancelOnError: true);
      await channel.ready.timeout(const Duration(seconds: 5));
      channel.sink.add(jsonEncode(recordLocationBody));
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('websocket location failed: ${e.runtimeType}');
      return false;
    } finally {
      recordLocationBody.token = null;
      try {
        await subscription?.cancel();
        await channel?.sink.close(status.goingAway).timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  @override
  Future<Response> recordLocation(RecordLocationBodyModel recordLocationBody) async {
    // Background every 10s: silent on failure (audit row 11), but a 401
    // still ends the session. Bearer header only.
    recordLocationBody.token = null;
    final Response response = await apiClient.postData(
        AppConstants.recordLocationUri, recordLocationBody.toJson(),
        handleError: false);
    ApiChecker.checkSession(response);
    return response;
  }

  @override
  Future<ResponseModel> deleteDriver() async {
    ResponseModel responseModel;
    Response response = await apiClient.deleteData(AppConstants.driverRemoveUri, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'your_account_remove_successfully'.tr);
    }else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
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