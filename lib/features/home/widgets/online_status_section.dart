import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
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
    final ThemeData theme = Theme.of(context);
    final Color block = theme.colorScheme.outline.withValues(alpha: 0.5);

    Widget shimmerBlock({
      required double width,
      required double height,
      required double radius,
    }) {
      return Shimmer(
        duration: const Duration(seconds: 2),
        color: theme.cardColor,
        colorOpacity: 0.3,
        enabled: true,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: block,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
    }

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
            shimmerBlock(width: 10, height: 10, radius: 5), // نقطة الحالة
            SizedBox(width: Dimensions.w10),
            shimmerBlock(width: 90, height: 18, radius: 8), // النص
            const Spacer(),
            shimmerBlock(width: 52, height: 32, radius: 16), // السويتش
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
                      Theme.of(Get.context!).disabledColor.withOpacity(0.1),
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

    // نقطة الحالة: أخضر عند الاتصال (دلالة "شغّال")، رمادي عند الانقطاع
    final Color dotColor = isActive
        ? (isDark ? ManagerColors.greenDarkMode : ManagerColors.greenLightMode)
        : cs.onSurfaceVariant;

    // السويتش: فاتح = أسفلت + إبهام أصفر | داكن = أصفر + إبهام أسفلت
    final Color onTrack = isDark ? cs.primary : cs.onSurface;
    final Color onThumb = isDark ? cs.onPrimary : cs.primary;

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
          Switch(
            value: isActive,
            onChanged: (bool v) {
              HapticFeedback.selectionClick();
              _onToggle(v, profileController, orderController);
            },
            thumbColor: WidgetStateProperty.resolveWith<Color>(
              (states) => states.contains(WidgetState.selected)
                  ? onThumb
                  : theme.cardColor,
            ),
            trackColor: WidgetStateProperty.resolveWith<Color>(
              (states) =>
                  states.contains(WidgetState.selected) ? onTrack : cs.outline,
            ),
            trackOutlineColor:
                const WidgetStatePropertyAll<Color>(Colors.transparent),
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
