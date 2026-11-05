import 'package:doghree_rider/common/widgets/app_shimmer.dart';
import 'package:doghree_rider/common/widgets/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_confirmation_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/features/order/controllers/order_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/location_permission_manager.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/manager_colors.dart';
import 'package:doghree_rider/util/styles.dart';

class StatusSwitchSection extends StatelessWidget {
  const StatusSwitchSection({super.key});

  BoxDecoration _cardDecoration(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(Dimensions.r20),
      border: Border.all(color: theme.colorScheme.outline),
    );
  }
Widget _buildShimmer(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Dimensions.w16,
      vertical: Dimensions.h6,
    ),
    decoration: _cardDecoration(context),
    child: SizedBox(
      height: kMinInteractiveDimension, // نفس ارتفاع الصف الحقيقي
      child: Row(
        children: [
          const AppShimmerBlock(width: 10, height: 10, circle: true), // نقطة الحالة
          SizedBox(width: Dimensions.w10),
          AppShimmerBlock(width: 90, height: 18, radius: Dimensions.r8), // النص
          const Spacer(),
          AppShimmerBlock(width: 52, height: 32, radius: Dimensions.r16), // السويتش
        ],
      ),
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
            width: Dimensions.w150,
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
                  backgroundColor:
                      Theme.of(Get.context!).disabledColor.withValues(alpha: 0.1),
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

  Future<void> _onToggle(
    bool toggle,
    ProfileController profileController,
    OrderController orderController,
  ) async {
    // حالة 1: محاولة الذهاب offline وعنده طلبات
    if (!toggle && orderController.currentOrderList!.isNotEmpty) {
      _showCannotGoOfflineDialog();
      return;
    }

    // حالة 2: الذهاب offline
    if (!toggle) {
      _showGoOfflineConfirmation(profileController);
      return;
    }

    // حالة 3: الذهاب online - طلب صلاحية الموقع
    await LocationPermissionManager.to.requestLocationPermission(
      onGranted: () async {
        await profileController.updateActiveStatus();
      },
      showDialogIfDenied: true,
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool isActive,
    ProfileController profileController,
    OrderController orderController,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color dotColor = isActive
        ? (isDark ? ManagerColors.greenDarkMode : ManagerColors.greenLightMode)
        : cs.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.w16,
        vertical: Dimensions.h6,
      ),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          SizedBox(width: Dimensions.w10),
          Expanded(
            child: Text(
              isActive ? 'online'.tr : 'offline'.tr,
              style: textBold().copyWith(
                fontSize: Dimensions.fs16,
                color: cs.onSurface,
              ),
            ),
          ),
          CustomSwitch(
            value: isActive,
            onChanged: (bool v) {
              HapticFeedback.selectionClick();
              _onToggle(v, profileController, orderController);
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
