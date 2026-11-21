import 'dart:async';
import 'package:doghree_rider/common/models/response_model.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/address/domain/models/record_location_body_model.dart';
import 'package:doghree_rider/features/splash/controllers/splash_controller.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_model.dart';
import 'package:doghree_rider/features/profile/domain/models/profile_result_model.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doghree_rider/features/profile/domain/services/profile_service_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/helper/image_picker_helper.dart';
import 'package:doghree_rider/helper/image_upload_rules.dart';
import 'package:doghree_rider/api/error_message.dart';
import 'package:doghree_rider/api/error_type.dart';
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

  /// Every message of the profile edit goes through here. Production always
  /// uses [showCustomSnackBar]; tests replace it only to count messages.
  @visibleForTesting
  void Function(String? message, {bool isError}) toast = showCustomSnackBar;

  bool _picking = false;

  /// اختيار صورة البروفايل مع القص الاحترافي. One picker at a time; the
  /// helper shows the one message for a picker failure (audit row 46).
  Future<void> pickProfileImageWithCrop(BuildContext context) async {
    if (_picking) return;
    _picking = true;
    try {
      final XFile? croppedImage =
          await ImagePickerHelper.showImageSourceBottomSheet(
        context: context,
        cropStyle: CropStyle.circle,
        lockAspectRatio: false,
      );
      if (croppedImage != null) await acceptProfileImage(croppedImage);
    } finally {
      _picking = false;
    }
  }

  /// Keeps [file] as the new profile photo only if it passes
  /// [ImageUploadRules]. Otherwise one message, and the old photo stays.
  Future<bool> acceptProfileImage(XFile file) async {
    final ImageCheck check = await ImageUploadRules.check(file);
    if (check != ImageCheck.ok) {
      toast(ImageUploadRules.messageKey(check).tr);
      return false;
    }
    _pickedFile = file;
    update();
    return true;
  }

  /// Loads the profile. On any failure the previous [profileModel] is kept.
  /// The returned [SessionStatus] lets the caller tell a real session end
  /// (expired) apart from offline or server trouble.
  Future<SessionStatus> getProfile({bool isFromSplash = false}) async {
    final ProfileResult result = await profileServiceInterface.getProfileInfo();
    final ProfileModel? profileModel = result.profile;
    if (result.status == SessionStatus.valid && profileModel != null) {
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
    return result.status;
  }

  /// One request per tap, one message, and the loader always stops (audit
  /// row 48). On success only the edited fields change: the rest of the
  /// loaded profile (id, online state, wallet) is kept.
  Future<bool> updateUserInfo(ProfileModel updateUserModel) async {
    if (_isLoading) return false;
    _isLoading = true;
    update();
    bool success = false;
    try {
      final ResponseModel responseModel = await profileServiceInterface
          .updateProfile(updateUserModel, _pickedFile);
      if (responseModel.isSuccess) {
        success = true;
        _applyProfileEdit(updateUserModel);
        _pickedFile = null;
        _isLoading = false;
        // Closing the screen can never turn a saved profile into an error.
        try {
          Get.back();
        } catch (e) {
          if (kDebugMode) debugPrint('close edit screen failed: ${e.runtimeType}');
        }
        final String? message = responseModel.message;
        toast((message == null || message.isEmpty) ? 'profile_updated'.tr : message,
            isError: false);
      } else if (responseModel.statusCode == 401) {
        // checkSession already ended the session: no second message.
      } else if (responseModel.statusCode == 1) {
        toast(ErrorMessages.getMessage(ErrorType.noInternet));
      } else {
        final String? message = responseModel.message;
        toast((message == null || message.isEmpty) ? 'error_occurred'.tr : message);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('updateUserInfo failed: ${e.runtimeType}');
      toast('error_occurred'.tr);
    } finally {
      _isLoading = false;
      update();
    }
    return success;
  }

  void _applyProfileEdit(ProfileModel edit) {
    final ProfileModel? current = _profileModel;
    if (current == null) return;
    if (edit.fName != null) current.fName = edit.fName;
    if (edit.lName != null) current.lName = edit.lName;
    if (edit.email != null) current.email = edit.email;
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

  /// One request per tap, one message, and the loader always stops. The
  /// confirm sheet is closed only if it is still open, never a blind back.
  Future<void> deleteDriver() async {
    if (_isLoading) return;
    _isLoading = true;
    update();
    ResponseModel responseModel;
    try {
      responseModel = await profileServiceInterface.deleteDriver();
    } catch (e) {
      if (kDebugMode) debugPrint('deleteDriver failed: ${e.runtimeType}');
      responseModel = ResponseModel(false, null);
    } finally {
      _isLoading = false;
      update();
    }
    if (Get.isBottomSheetOpen == true) Get.back();
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      stopLocationRecord();
      try {
        await Get.find<AuthController>().clearSharedData();
      } catch (e) {
        if (kDebugMode) debugPrint('delete cleanup failed: ${e.runtimeType}');
      }
      Get.offAllNamed(RouteHelper.getSignInRoute());
    } else {
      final String? message = responseModel.message;
      showCustomSnackBar(
          (message == null || message.isEmpty) ? 'error_occurred'.tr : message,
          isError: true);
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
    _timer = null;
  }

  bool _recording = false;

  /// One tick of the 10 s timer. It never throws and never shows anything
  /// (audit rows 38, 39): with no real position, no GPS, no permission or no
  /// config it skips the tick, and the next tick tries again, so recording
  /// recovers by itself.
  Future<void> recordLocation() async {
    if (_recording) return;
    _recording = true;
    try {
      final Position? position =
          await profileServiceInterface.currentPositionOrNull();
      if (position == null) return;
      final String address =
          await profileServiceInterface.addressPlaceMark(position);

      if (_timer == null || !_timer!.isActive) return;
      final RecordLocationBodyModel body = RecordLocationBodyModel(
        location: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _recordLocation = body;

      if (_webSocketEnabled()) {
        await profileServiceInterface.recordWebSocketLocation(body);
      } else {
        await profileServiceInterface.recordLocation(body);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('recordLocation failed: ${e.runtimeType}');
    } finally {
      _recording = false;
    }
  }

  bool _webSocketEnabled() =>
      Get.isRegistered<SplashController>() &&
      Get.find<SplashController>().configModel?.webSocketStatus == true;

  void setBackgroundNotificationActive(bool isActive) {
    _backgroundNotification = isActive;
    update();
  }
}
