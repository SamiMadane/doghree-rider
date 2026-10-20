import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

class LocationPermissionManager extends GetxController {
  static LocationPermissionManager get to => Get.find();

  final _lastCheckTime = 0.obs;
  final _isCheckingPermission = false.obs;
  final _permissionStatus = Rxn<LocationPermission>();

  bool _hasCheckedInitially = false;

  static const _checkCooldownSeconds = 5;

  Future<void> checkPermissionOnHomeScreen() async {
    if (_hasCheckedInitially) return; // لو فحصنا قبل كده، متفحصش تاني

    _hasCheckedInitially = true;
    await _checkInitialPermission();
  }

  /// التحقق الأولي من حالة الصلاحية
  Future<void> _checkInitialPermission() async {
    try {
      _permissionStatus.value = await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('Error checking initial permission: $e');
    }
  }

  void resetInitialCheck() {
    _hasCheckedInitially = false;
  }

  Future<bool> requestLocationPermission({
    required Function onGranted,
    bool showDialogIfDenied = true,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_isCheckingPermission.value ||
        (now - _lastCheckTime.value) < _checkCooldownSeconds) {
      debugPrint('Permission check blocked - cooldown active');
      return false;
    }

    _isCheckingPermission.value = true;
    _lastCheckTime.value = now;

    try {
      while (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      var permission = await Geolocator.checkPermission();
      _permissionStatus.value = permission;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        _permissionStatus.value = permission;
      }

      if (permission == LocationPermission.denied) {
        if (showDialogIfDenied) {
          _showPermissionDeniedDialog(onGranted);
        }
        return false;
      } else if (permission == LocationPermission.deniedForever) {
        if (showDialogIfDenied) {
          _showPermissionDeniedForeverDialog(onGranted);
        }
        return false;
      } else if (GetPlatform.isAndroid &&
          permission == LocationPermission.whileInUse) {
        if (showDialogIfDenied) {
          _showUpgradeToAlwaysDialog(onGranted);
        }
        await onGranted();
        return true;
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await onGranted();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    } finally {
      _isCheckingPermission.value = false;
    }
  }

  /// عرض dialog عندما يرفض المستخدم الصلاحية لأول مرة
  void _showPermissionDeniedDialog(Function onGranted) {
    showCustomBottomSheet(
      isDismissible: true,
      showCloseButton: false,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w30,
            vertical: Dimensions.h16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header مع Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    ManagerAssets.locationAccessIcon,
                    width: 70,
                    height: 70,
                  ),
                  SizedBox(width: Dimensions.w16),
                  Text(
                    'location_permission_needed'.tr,
                    textAlign: TextAlign.start,
                    style: textBold().copyWith(fontSize: Dimensions.fs16),
                    maxLines: 2,
                  ),
                ],
              ),

              SizedBox(height: Dimensions.h20),

              // الرسالة التوضيحية
              _buildInfoText('location_required_to_go_online'.tr),
              _buildInfoText('you_need_to_allow_location_to_receive_orders'.tr),

              SizedBox(height: Dimensions.h20),

              // الأزرار
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'maybe_later'.tr,
                      style: textMedium().copyWith(
                        color: Theme.of(Get.context!).disabledColor,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.w10),
                  CustomButtonWidget(
                    width: 120,
                    onPressed: () async {
                      Get.back();
                      final permission = await Geolocator.requestPermission();
                      _permissionStatus.value = permission;

                      // إذا وافق، نفذ الـ callback
                      if (permission == LocationPermission.whileInUse ||
                          permission == LocationPermission.always) {
                        await onGranted();
                      }
                    },
                    buttonText: 'allow'.tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// عرض dialog عندما يرفض المستخدم الصلاحية للأبد أو whileInUse
  void _showPermissionDeniedForeverDialog(Function onGranted) {
    showCustomBottomSheet(
      isDismissible: true,
      showCloseButton: false,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w30,
            vertical: Dimensions.h16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header مع Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    ManagerAssets.locationAccessIcon,
                    width: 70,
                    height: 70,
                  ),
                  SizedBox(width: Dimensions.w16),
                  Expanded(
                    child: Text(
                      'allow_to'.tr +
                          ' ${AppConstants.appName} ' +
                          'to_access_location'.tr,
                      textAlign: TextAlign.start,
                      style: textBold().copyWith(fontSize: Dimensions.fs16),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimensions.h16),

              // الخطوات
              SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'follow_these_steps'.tr,
                      textAlign: TextAlign.start,
                      style: textBold().copyWith(fontSize: Dimensions.fs15),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.h10),

              _buildStep('1', 'tap_on_permissions'.tr),
              _buildStep('2', 'tap_on_location'.tr),
              _buildStep(
                  '3',
                  GetPlatform.isAndroid
                      ? 'select_allow_all_the_time'.tr
                      : 'select_always'.tr),

              SizedBox(height: Dimensions.h20),

              // الرسائل التوضيحية
              _buildInfoText('location_required_to_go_online'.tr),
              _buildInfoText(
                  '${AppConstants.appName} ${'will_track_your_location_in_background'.tr}'),
              _buildInfoText(
                  'you_will_receive_orders_based_on_your_location'.tr),

              SizedBox(height: Dimensions.h20),

              // الأزرار
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: textMedium().copyWith(
                        color: Theme.of(Get.context!).disabledColor,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.w10),
                  CustomButtonWidget(
                    autoWidth: true,
                    onPressed: () async {
                      Get.back();
                      await Geolocator.openAppSettings();

                      // بعد 3 ثواني نتحقق من الصلاحية
                      Future.delayed(const Duration(seconds: 3), () async {
                        final permission = await Geolocator.checkPermission();
                        _permissionStatus.value = permission;

                        if (permission == LocationPermission.always ||
                            permission == LocationPermission.whileInUse) {
                          await onGranted();
                        }
                      });
                    },
                    buttonText: 'open_settings'.tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// عرض dialog لترقية الصلاحية من While In Use إلى Always (Android فقط)
  void _showUpgradeToAlwaysDialog(Function onGranted) {
    showCustomBottomSheet(
      isDismissible: true,
      showCloseButton: false,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w30,
            vertical: Dimensions.h16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header مع Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    ManagerAssets.locationAccessIcon,
                    width: 70,
                    height: 70,
                  ),
                  SizedBox(width: Dimensions.w16),
                  Expanded(
                    child: Text(
                      'upgrade_location_permission'.tr,
                      textAlign: TextAlign.start,
                      style: textBold().copyWith(fontSize: Dimensions.fs16),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimensions.h16),

              // الخطوات
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'follow_these_steps'.tr,
                    textAlign: TextAlign.start,
                    style: textBold().copyWith(fontSize: Dimensions.fs15),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.h10),

              _buildStep('1', 'tap_on_permissions'.tr),
              _buildStep('2', 'tap_on_location'.tr),
              _buildStep('3', 'select_allow_all_the_time'.tr),

              SizedBox(height: Dimensions.h20),

              // الرسائل التوضيحية
              _buildInfoText('for_better_experience_allow_always'.tr),
              _buildInfoText(
                  '${AppConstants.appName} ${'will_track_your_location_in_background'.tr}'),
              _buildInfoText('you_will_receive_more_orders'.tr),

              SizedBox(height: Dimensions.h20),

              // الأزرار
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'skip'.tr,
                      style: textMedium().copyWith(
                        color: Theme.of(Get.context!).disabledColor,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.w10),
                  CustomButtonWidget(
                    autoWidth: true,
                    onPressed: () async {
                      Get.back();
                      await Geolocator.openAppSettings();

                      // بعد 3 ثواني نتحقق من الصلاحية
                      Future.delayed(const Duration(seconds: 3), () async {
                        final permission = await Geolocator.checkPermission();
                        _permissionStatus.value = permission;
                      });
                    },
                    buttonText: 'open_settings'.tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء خطوة واحدة
  Widget _buildStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: textBold().copyWith(
                  fontSize: Dimensions.fs12,
                  color: Get.theme.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: Dimensions.w10),
          Expanded(
            child: Text(
              text,
              style: textMedium().copyWith(
                fontSize: Dimensions.fs14,
                color: Get.theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء نص معلوماتي
  Widget _buildInfoText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: Dimensions.w10),
          Expanded(
            child: Text(
              text,
              style: textRegular().copyWith(
                fontSize: Dimensions.fs13,
                color: Get.theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// الحصول على حالة الصلاحية الحالية
  LocationPermission? get currentPermissionStatus => _permissionStatus.value;

  /// التحقق إذا كانت الصلاحية ممنوحة
  bool get isPermissionGranted =>
      _permissionStatus.value == LocationPermission.always ||
      _permissionStatus.value == LocationPermission.whileInUse;
}
