import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefrh_rider/api/api_client.dart';
import 'package:wefrh_rider/common/models/response_model.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:wefrh_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:wefrh_rider/features/profile/domain/models/profile_model.dart';
import 'package:wefrh_rider/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:wefrh_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:wefrh_rider/helper/location_permission_manager.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class ProfileService implements ProfileServiceInterface {
  final ProfileRepositoryInterface profileRepositoryInterface;
  ProfileService({required this.profileRepositoryInterface});

  @override
  Future<ProfileModel?> getProfileInfo() async {
    return await profileRepositoryInterface.getProfileInfo();
  }

  @override
  Future<ResponseModel> updateProfile(
      ProfileModel userInfoModel, XFile? data, String token) async {
    return await profileRepositoryInterface.updateProfile(
        userInfoModel, data, token);
  }

  @override
  Future<ResponseModel> updateActiveStatus() async {
    return await profileRepositoryInterface.updateActiveStatus();
  }

  @override
  Future<void> recordWebSocketLocation(
      RecordLocationBodyModel recordLocationBody) async {
    await profileRepositoryInterface
        .recordWebSocketLocation(recordLocationBody);
  }

  @override
  Future<Response> recordLocation(
      RecordLocationBodyModel recordLocationBody) async {
    return await profileRepositoryInterface.recordLocation(recordLocationBody);
  }

  @override
  Future<ResponseModel> deleteDriver() async {
    return await profileRepositoryInterface.deleteDriver();
  }

  /// اسم المكان من سيرفر دغري (geocode-api) بدل حزمة geocoding / Google.
  /// السيرفر يرد دائماً بـ status OK ونص صالح للعرض، وخارج قاعدة الأماكن
  /// يرجع «موقع محدد على الخريطة». عند فشل الاتصال نرجع نصاً فارغاً
  /// (الدليل يمنع كتابة «Unknown Location» من التطبيق).
  @override
  Future<String> addressPlaceMark(Position locationResult) async {
    try {
      final Response response = await Get.find<ApiClient>().getData(
        '/api/v1/config/geocode-api',
        query: {
          'lat': '${locationResult.latitude}',
          'lng': '${locationResult.longitude}',
        },
      );
      if (response.statusCode == 200 && response.body is Map) {
        final results = response.body['results'];
        if (results is List && results.isNotEmpty) {
          final first = results[0];
          // الدليل يذكر address_formatted في §8 و formatted_address في المثال، نقرأ الاثنين
          final text = first['address_formatted'] ?? first['formatted_address'];
          if (text != null && text.toString().isNotEmpty) {
            return text.toString();
          }
        }
      }
    } catch (e) {
      debugPrint('addressPlaceMark failed: $e');
    }
    return '';
  }

  @override
  void checkPermission(Function callback, {bool showDialog = true}) async {
    await LocationPermissionManager.to.requestLocationPermission(
      onGranted: () async => callback(),
      showDialogIfDenied: showDialog,
    );
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    XFile? pickImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      pickImage.length().then((value) {
        if (value > 2000000) {
          showCustomSnackBar('please_upload_lower_size_file'.tr);
        } else {
          return pickImage;
        }
      });
    }
    return pickImage;
  }
}