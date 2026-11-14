import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/api/api_client.dart';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ProfileRepository implements ProfileRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ProfileRepository({required this.apiClient, required this.sharedPreferences});

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

  @override
  Future<ResponseModel> updateProfile(ProfileModel userInfoModel, XFile? data, String token) async {
    ResponseModel responseModel;
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put', 'f_name': userInfoModel.fName!, 'l_name': userInfoModel.lName!,
      'email': userInfoModel.email!,
    });
    Response response = await apiClient.postMultipartData(AppConstants.updateProfileUri, fields, [MultipartBody('image', data)], handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
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
  Future<void> recordWebSocketLocation(RecordLocationBodyModel recordLocationBody) async {
    recordLocationBody.token = _getUserToken();
    String uri = '${Get.find<SplashController>().configModel!.webSocketUri!}:${Get.find<SplashController>().configModel!.webSocketPort!}/delivery-man/live-location?appKey=${Get.find<SplashController>().configModel!.webSocketKey!}';
    final wsUrl = Uri.parse(uri);
    var channel = WebSocketChannel.connect(wsUrl);

    channel.sink.add(jsonEncode(recordLocationBody));
    channel.sink.close(status.goingAway);
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