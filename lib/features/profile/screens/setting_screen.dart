import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart_delivery/common/controllers/theme_controller.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/notification_status_change_bottom_sheet.dart';
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
        padding: EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            children: [
              ProfileButtonWidget(
              iconData: Icons.dark_mode,
                title: 'dark_mode'.tr,
                isButtonActive: Get.isDarkMode,
                onTap: () {
                  Get.find<ThemeController>().toggleTheme();
                },
              ),
              SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Divider(),
              GetBuilder<AuthController>(builder: (authController) {
                return ProfileButtonWidget(
                  svgPath: ManagerAssets.notificationIcon,
                  title: 'system_notification'.tr,
                  isButtonActive: authController.notification,
                  onTap: () {
                    showCustomBottomSheet(
                        child: const NotificationStatusChangeBottomSheet());
                  },
                );
              }),
              SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Divider(),
              ProfileButtonWidget(
                svgPath: ManagerAssets.notification2Icon,
                title: 'background_notification'.tr,
                isButtonActive: profileController.backgroundNotification,
                onTap: () {
                  showBgNotificationBottomSheet(
                      profileController.backgroundNotification);
                },
              ),
              SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Divider(),
              SizedBox(height: Dimensions.paddingSizeSmall),
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
                    Get.dialog(
                      ConfirmationDialogWidget(
                        icon: ManagerAssets.warning,
                        title: 'are_you_sure_to_delete_account'.tr,
                        description: 'it_will_remove_your_all_information'.tr,
                        isLogOut: true,
                        onYesPressed: () => profileController.deleteDriver(),
                      ),
                      useSafeArea: false,
                    );
                  },
                  child: Text(
                    'delete_your_account'.tr,
                    style: robotoMedium.copyWith(
                      color: Colors.red,
                      fontSize: Dimensions.fontSizeLarge,
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
            decoration: BoxDecoration(
              color: Theme.of(context as BuildContext).cardColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge)),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    color: Theme.of(context as BuildContext).disabledColor,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text(
                  '${!allow ? 'allow'.tr : 'disable'.tr} ${AppConstants.appName} ${!allow ? 'to_run_notification_in_background'.tr : 'from_running_notification_in_background'.tr}',
                  textAlign: TextAlign.center,
                  style:
                      robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                allow
                    ? Text(
                        '(${AppConstants.appName} -> Battery -> Select Optimized)',
                        textAlign: TextAlign.center,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color:
                                Theme.of(context as BuildContext).primaryColor),
                      )
                    : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeLarge),
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
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context as BuildContext),
                      child: Text("cancel".tr, style: robotoMedium),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    ElevatedButton(
                      onPressed: () async {
                        if (await Permission
                            .ignoreBatteryOptimizations.status.isGranted) {
                          openAppSettings();
                        } else {
                          await Permission.ignoreBatteryOptimizations.request();
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context as BuildContext).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        "okay".tr,
                        style: robotoMedium.copyWith(
                            color: Theme.of(context as BuildContext).cardColor),
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
    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
    decoration: BoxDecoration(
      color: Theme.of(context as BuildContext)
          .disabledColor
          .withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(
      text,
      style: robotoRegular,
    ),
  );
}
