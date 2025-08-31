import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/common/controllers/theme_controller.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

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
        padding: EdgeInsets.only(top: Dimensions.p16),
        child: Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.all(Dimensions.p16),
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
              SizedBox(height: Dimensions.p5),
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
              SizedBox(height: Dimensions.p5),
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
              SizedBox(height: Dimensions.p5),
              Divider(),
              SizedBox(height: Dimensions.p10),
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
                    style: robotoMedium.copyWith(
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
  Get.bottomSheet(
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.p30,
                vertical: Dimensions.p16),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.r20),
                topRight: Radius.circular(Dimensions.r20),
              ),
            ),
            child: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.r16),
                    color: Theme.of(Get.context!).disabledColor,
                  ),
                ),
                const SizedBox(height: Dimensions.p20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      ManagerAssets.logo,
                      width: 70,
                      height: 70,
                    ),
                    SizedBox(width: Dimensions.p16),
                    Expanded(
                      child: Text(
                        '${!allow ? 'allow'.tr : 'disable'.tr} ${AppConstants.appName} ${!allow ? 'to_run_notification_in_background'.tr : 'from_running_notification_in_background'.tr}',
                        textAlign: TextAlign.start,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fs16),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                allow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.p16),
                          Text(
                            "Follow these steps:",
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fs15,
                            ),
                          ),
                          const SizedBox(height: Dimensions.p10),
                          _buildStep("1", "${AppConstants.appName}"),
                          _buildStep("2", "Battery"),
                          _buildStep("3", "Select Optimized"),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: Dimensions.p20),
                _buildInfoText(
                    "you_will_be_able_to_get_order_notification_even_if_you_are_not_in_the_app"
                        .tr),
                _buildInfoText(
                    "${AppConstants.appName} ${!allow ? 'will_run_notification_service_in_the_background_always'.tr : 'will_not_run_notification_service_in_the_background_always'.tr}"),
                _buildInfoText(!allow
                    ? "notification_will_always_send_alert_from_the_background"
                        .tr
                    : 'notification_will_not_always_send_alert_from_the_background'
                        .tr),
                const SizedBox(height: Dimensions.p20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(Get.context!),
                      child: Text("cancel".tr, style: robotoMedium),
                    ),
                    const SizedBox(width: Dimensions.p10),
                    ElevatedButton(
                      onPressed: () async {
                        final profileController = Get.find<ProfileController>();

                        if (allow) {
                          openAppSettings();
                          if (await Permission
                              .ignoreBatteryOptimizations.status.isGranted) {
                            profileController
                                .setBackgroundNotificationActive(true);
                          } else {
                            profileController
                                .setBackgroundNotificationActive(false);
                          }
                          Get.back();
                        } else {
                          // إذا الإذن موجود، نفتح الإعدادات وننتظر العودة
                          if (await Permission
                              .ignoreBatteryOptimizations.status.isGranted) {
                            await openAppSettings();
                          } else {
                            await Permission.ignoreBatteryOptimizations
                                .request();
                          }

                          // بعد العودة من الإعدادات، نتأكد من الحالة الحقيقية
                          if (await Permission
                              .ignoreBatteryOptimizations.status.isGranted) {
                            profileController
                                .setBackgroundNotificationActive(true);
                          } else {
                            profileController
                                .setBackgroundNotificationActive(false);
                          }

                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(Get.context!).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        "okay".tr,
                        style: robotoMedium.copyWith(
                            color: Theme.of(Get.context!).cardColor),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
          isScrollControlled: true)
      .then((value) {
    checkBatteryPermission();
  });
}

Widget _buildInfoText(String text) {
  return Container(
    padding: const EdgeInsets.all(Dimensions.p10),
    margin: const EdgeInsets.only(bottom: Dimensions.p10),
    decoration: BoxDecoration(
      color: Theme.of(Get.context!).disabledColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(
      text,
      style: robotoRegular,
    ),
  );
}

Widget _buildStep(String number, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: Dimensions.p5),
    child: Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(Get.context!).primaryColor,
          child: Text(
            number,
            style: robotoBold.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.p8),
        Expanded(
          child: Text(
            text,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fs13,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}
