import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:wefrh_rider/common/widgets/custom_card.dart';
import 'package:wefrh_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/features/order/controllers/order_controller.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/helper/location_permission_manager.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/util/manager_colors.dart';
import 'package:wefrh_rider/util/styles.dart';

class StatusSwitchSection extends StatelessWidget {
  const StatusSwitchSection({super.key});

  Widget _buildShimmer(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Shimmer(
            duration: const Duration(seconds: 2),
            color: Theme.of(context).cardColor,
            colorOpacity: 0.3,
            enabled: true,
            child: Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: ManagerColors.shimmer,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Shimmer(
            duration: const Duration(seconds: 2),
            color: Theme.of(context).cardColor,
            colorOpacity: 0.3,
            enabled: true,
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: ManagerColors.shimmer,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض dialog عندما لا يستطيع السائق الذهاب offline
  void _showCannotGoOfflineDialog() {
    showCustomBottomSheet(
      child: CustomConfirmationBottomSheet(
        title: 'you_cant_go_offline'.tr,
        description: 'you_can_not_go_offline_now'.tr,
        buttonWidget: Padding(
          padding: EdgeInsets.only(bottom: 20, top: 10),
          child: CustomButtonWidget(
            width: 150,
            onPressed: () => Get.back(),
            buttonText: 'okay'.tr,
          ),
        ),
      ),
    );
  }

  /// عرض dialog تأكيد الذهاب offline
  void _showGoOfflineConfirmation(ProfileController profileController) {
    showCustomBottomSheet(
      child: CustomConfirmationBottomSheet(
        title: 'go_offline'.tr,
        description: 'are_you_sure_to_offline'.tr,
        image: ManagerAssets.dmOfflineIcon,
        buttonWidget: Padding(
          padding: EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 10),
          child: Row(
            children: [
              Expanded(
                child: CustomButtonWidget(
                  onPressed: () {
                    Get.back();
                    profileController.updateActiveStatus();
                  },
                  buttonText: 'yes_proceed'.tr,
                ),
              ),
              SizedBox(width: Dimensions.w16),
              Expanded(
                child: CustomButtonWidget(
                  onPressed: () => Get.back(),
                  buttonText: 'cancel'.tr,
                  backgroundColor: Theme.of(Get.context!)
                      .disabledColor
                      .withOpacity(0.1),
                  fontColor: Theme.of(Get.context!).disabledColor,
                  isBorder: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool isActive,
    ProfileController profileController,
    OrderController orderController,
  ) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isActive ? 'online'.tr : 'offline'.tr,
            style: textSemiBold().copyWith(fontSize: Dimensions.fs16),
          ),
          FlutterSwitch(
            width: 60,
            height: 30,
            valueFontSize: Dimensions.fs10,
            activeColor: ManagerColors.darkGreen,
            value: isActive,
            onToggle: (bool toggle) async {
              // ✅ حالة 1: محاولة الذهاب offline وعنده طلبات
              if (!toggle && orderController.currentOrderList!.isNotEmpty) {
                _showCannotGoOfflineDialog();
                return;
              }

              // ✅ حالة 2: الذهاب offline
              if (!toggle) {
                _showGoOfflineConfirmation(profileController);
                return;
              }

              // ✅ حالة 3: الذهاب online - طلب صلاحية الموقع
              await LocationPermissionManager.to.requestLocationPermission(
                onGranted: () async {
                  await profileController.updateActiveStatus();
                },
                showDialogIfDenied: true,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (profileController) {
        return GetBuilder<OrderController>(
          builder: (orderController) {
            if (profileController.profileModel == null ||
                orderController.currentOrderList == null) {
              return _buildShimmer(context);
            }
            final isActive = profileController.profileModel!.active == 1;
            return _buildStatusCard(
              context,
              isActive,
              profileController,
              orderController,
            );
          },
        );
      },
    );
  }
}