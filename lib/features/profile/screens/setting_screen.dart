import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wefrh_rider/common/controllers/theme_controller.dart';
import 'package:wefrh_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:wefrh_rider/common/widgets/custom_app_bar_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/features/profile/widgets/profile_button_widget.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/styles.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWidget(
        title: 'account_setting'.tr,
        centerTitle: true,
        isBackButtonExist: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: Dimensions.h16),
        child: Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          child: Column(
            children: [
              ProfileButtonWidget(
                svgPath: ManagerAssets.moonIcon,
                title: 'dark_mode'.tr,
                isButtonActive: Get.isDarkMode,
                onTap: () {
                  Get.find<ThemeController>().toggleTheme();
                },
              ),
              SizedBox(height: Dimensions.h4),
              Divider(),
              GetBuilder<AuthController>(builder: (authController) {
                return ProfileButtonWidget(
                  svgPath: ManagerAssets.notificationIcon,
                  title: 'system_notification'.tr,
                  isButtonActive: authController.notification,
                  onTap: () {
                    showCustomBottomSheet(
                        child: ConfirmationBottomSheet(
                      title: 'are_you_sure_you_want_to_enable_notification'.tr,
                      iconSize: 60,
                      acceptText: !authController.notification
                          ? 'yes_enable'.tr
                          : 'yes_disable'.tr,
                      acceptColor: Theme.of(context).primaryColor,
                      cancelText: 'no'.tr,
                      onAccept: () async {
                        if (await Permission.notification.status.isDenied ||
                            await Permission
                                .notification.status.isPermanentlyDenied) {
                          showCustomSnackBar(
                              'make_sure_to_enable_app_notifications_first'.tr);
                        } else {
                          await authController.setNotificationActive(
                              !authController.notification);
                          Get.back();
                        }
                      },
                      onCancel: () => Get.back(),
                    ));
                  },
                );
              }),
              SizedBox(height: Dimensions.h4),
              Divider(),
              GetBuilder<ProfileController>(builder: (profileController) {
                return ProfileButtonWidget(
                  svgPath: ManagerAssets.notification2Icon,
                  title: 'background_notification'.tr,
                  isButtonActive: profileController.backgroundNotification,
                  onTap: () {
                    showBgNotificationBottomSheet(
                        profileController.backgroundNotification);
                  },
                );
              }),
              SizedBox(height: Dimensions.h4),
              Divider(),
              SizedBox(height: Dimensions.h10),
              ProfileButtonWidget(
                svgPath: ManagerAssets.keyIcon,
                title: 'change_password'.tr,
                showTrailing: false,
                onTap: () {
                  Get.toNamed(RouteHelper.getResetPasswordRoute(
                      '', '', 'password-change'));
                },
              ),
              Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    showCustomBottomSheet(
                      child: ConfirmationBottomSheet(
                        icon: ManagerAssets.warning,
                        title: 'are_you_sure_to_delete_account'.tr,
                        description: 'it_will_remove_your_all_information'.tr,
                        acceptText: 'yes_delete_it'.tr,
                        cancelText: 'no_cancel'.tr,
                        hasCancel: true,
                        onAccept: () {
                          profileController.deleteDriver();
                        },
                        onCancel: () {
                          Get.back();
                        },
                        acceptColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                  child: Text(
                    'delete_your_account'.tr,
                    style: textMedium().copyWith(
                      color: Colors.red,
                      fontSize: Dimensions.fs16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void checkBatteryPermission() async {
  Future.delayed(const Duration(milliseconds: 400), () async {
    if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    } else {
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }
  });
}

void showBgNotificationBottomSheet(bool allow) {
  showCustomBottomSheet(
    showCloseButton: false, 
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w30, vertical: Dimensions.h16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  ManagerAssets.logo,
                  width: 70,
                  height: 70,
                ),
                SizedBox(width: Dimensions.w16),
                Expanded(
                  child: Text(
                    '${'allow_to'.tr} ${AppConstants.appName} ${!allow ? 'to_run_notification_in_background'.tr : 'disable_background_notifications'.tr}',
                    textAlign: TextAlign.start,
                    style: textBold().copyWith(fontSize: Dimensions.fs16),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            allow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimensions.h16),
                      Text(
                        "follow_these_steps".tr,
                        style: textBold().copyWith(
                          fontSize: Dimensions.fs15,
                        ),
                      ),
                      SizedBox(height: Dimensions.h10),
                      _buildStep("1", "${AppConstants.appName}"),
                      _buildStep("2", "battery".tr),
                      _buildStep("3", "select_optimized".tr),
                    ],
                  )
                : const SizedBox(),
            SizedBox(height: Dimensions.h20),
            _buildInfoText(
                "you_will_be_able_to_get_order_notification_even_if_you_are_not_in_the_app"
                    .tr),
            _buildInfoText(
                "${AppConstants.appName} ${!allow ? 'will_run_notification_service_in_the_background_always'.tr : 'will_not_run_notification_service_in_the_background_always'.tr}"),
            _buildInfoText(!allow
                ? "notification_will_always_send_alert_from_the_background".tr
                : 'notification_will_not_always_send_alert_from_the_background'
                    .tr),
            SizedBox(height: Dimensions.h20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(Get.context!),
                  child: Text("cancel".tr,
                      style: textMedium().copyWith(
                          color: Theme.of(Get.context!).primaryColor)),
                ),
                SizedBox(width: Dimensions.w10),
                CustomButtonWidget(
                  width: 100,
                  onPressed: () async {
                    final profileController = Get.find<ProfileController>();

                    if (allow) {
                      openAppSettings();
                      if (await Permission
                          .ignoreBatteryOptimizations.status.isGranted) {
                        profileController.setBackgroundNotificationActive(true);
                      } else {
                        profileController
                            .setBackgroundNotificationActive(false);
                      }
                      Get.back();
                    } else {
                      if (await Permission
                          .ignoreBatteryOptimizations.status.isGranted) {
                        await openAppSettings();
                      } else {
                        await Permission.ignoreBatteryOptimizations.request();
                      }

                      if (await Permission
                          .ignoreBatteryOptimizations.status.isGranted) {
                        profileController.setBackgroundNotificationActive(true);
                      } else {
                        profileController
                            .setBackgroundNotificationActive(false);
                      }

                      Get.back();
                    }
                  },
                  buttonText: 'okay'.tr,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ).then((value) {
    checkBatteryPermission();
  });
}

Widget _buildInfoText(String text) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal:Dimensions.w10 ,vertical: Dimensions.h10,),
    margin: EdgeInsets.only(bottom: Dimensions.h10),
    decoration: BoxDecoration(
      color: Theme.of(Get.context!).disabledColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(
      text,
      style: textRegular(),
    ),
  );
}

Widget _buildStep(String number, String text) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: Dimensions.h4),
    child: Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(Get.context!).primaryColor,
          child: Text(
            number,
            style: textBold().copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: Dimensions.w8),
        Expanded(
          child: Text(
            text,
            style: textMedium().copyWith(
              fontSize: Dimensions.fs13,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}
