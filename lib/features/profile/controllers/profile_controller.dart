import 'dart:async';
import 'package:wefrh_rider/common/models/response_model.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:wefrh_rider/features/splash/controllers/splash_controller.dart';
import 'package:wefrh_rider/features/profile/domain/models/profile_model.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefrh_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:flutter/material.dart'; 
import 'package:wefrh_rider/helper/image_picker_helper.dart'; 
import 'package:image_cropper/image_cropper.dart'; 

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;
  ProfileController({required this.profileServiceInterface});

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  RecordLocationBodyModel? _recordLocation;
  RecordLocationBodyModel? get recordLocationBody => _recordLocation;

  Timer? _timer;

  bool _backgroundNotification = true;
  bool get backgroundNotification => _backgroundNotification;

  // ========== ✅ NEW: Pick Profile Image with Crop ==========
  /// اختيار صورة البروفايل مع القص الاحترافي
  Future<void> pickProfileImageWithCrop(BuildContext context) async {
    final XFile? croppedImage = await ImagePickerHelper.showImageSourceBottomSheet(
      context: context,
      cropStyle: CropStyle.circle, 
      lockAspectRatio: false,
    );

    if (croppedImage != null) {
      _pickedFile = croppedImage;
      update();
    }
  }

  // ========== ⚠️ KEEP OLD METHOD (for backward compatibility) ==========
  Future<void> pickProfileImage() async {
    XFile? image = await profileServiceInterface.pickImageFromGallery();
    if (image != null) {
      _pickedFile = image;
      update();
    }
  }

  Future<void> getProfile({bool isFromSplash = false}) async {
    ProfileModel? profileModel = await profileServiceInterface.getProfileInfo();
    if (profileModel != null) {
      _profileModel = profileModel;
      if (_profileModel!.active == 1) {
        profileServiceInterface.checkPermission(
          () => startLocationRecord(),
          showDialog: !isFromSplash,
        );
      } else {
        stopLocationRecord();
      }
    }
    update();
  }

  Future<bool> updateUserInfo(
      ProfileModel updateUserModel, String token) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.updateProfile(
        updateUserModel, _pickedFile, token);
    _isLoading = false;
    if (responseModel.isSuccess) {
      _profileModel = updateUserModel;
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  void pickImage() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    update();
  }

  void initData() {
    _pickedFile = null;
  }

  Future<bool> updateActiveStatus() async {
    ResponseModel responseModel =
        await profileServiceInterface.updateActiveStatus();
    if (responseModel.isSuccess) {
      Get.back();
      _profileModel!.active = _profileModel!.active == 0 ? 1 : 0;
      showCustomSnackBar(responseModel.message, isError: false);
      if (_profileModel!.active == 1) {
        profileServiceInterface.checkPermission(() => startLocationRecord());
      } else {
        stopLocationRecord();
      }
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    update();
    return responseModel.isSuccess;
  }

  Future deleteDriver() async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.deleteDriver();
    _isLoading = false;
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      Get.find<AuthController>().clearSharedData();
      stopLocationRecord();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    } else {
      Get.back();
      showCustomSnackBar(responseModel.message, isError: true);
    }
  }

  void startLocationRecord() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      recordLocation();
    });
  }

  void stopLocationRecord() {
    _timer?.cancel();
  }

  Future<void> recordLocation() async {
    final Position locationResult = await Geolocator.getCurrentPosition();
    String address =
        await profileServiceInterface.addressPlaceMark(locationResult);

    _recordLocation = RecordLocationBodyModel(
      location: address,
      latitude: locationResult.latitude,
      longitude: locationResult.longitude,
    );

    if (Get.find<SplashController>().configModel!.webSocketStatus!) {
      await profileServiceInterface.recordWebSocketLocation(_recordLocation!);
    } else {
      await profileServiceInterface.recordLocation(_recordLocation!);
    }
  }

  void setBackgroundNotificationActive(bool isActive) {
    _backgroundNotification = isActive;
    update();
  }
}