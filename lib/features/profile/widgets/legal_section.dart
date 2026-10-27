import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/widgets/profile_button_widget.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

class LegalSection extends StatelessWidget {
  final ProfileController profileController;
  const LegalSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'legal'.tr,
          style: textMedium().copyWith(fontSize: Dimensions.fs16),
        ),
        SizedBox(height: Dimensions.h16),
        CustomCard(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16,
            vertical: Dimensions.h16,
          ),
          isBorder: false,
          child: Column(
            children: [
              ProfileButtonWidget(
                  svgPath: ManagerAssets.termsConditionsIcon,
                  title: 'terms_condition'.tr,
                  onTap: () {
                    Get.toNamed(RouteHelper.getTermsRoute());
                  }),
              SizedBox(height: Dimensions.h16),
              ProfileButtonWidget(
                  svgPath: ManagerAssets.privacyPolicyIcon,
                  title: 'privacy_policy'.tr,
                  onTap: () {
                    Get.toNamed(RouteHelper.getPrivacyRoute());
                  }),
            ],
          ),
        ),
        SizedBox(height: Dimensions.h16),
        CustomCard(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.w16,
            vertical: Dimensions.h16,
          ),
          isBorder: false,
          child: Column(
            children: [
              ProfileButtonWidget(
                svgPath: ManagerAssets.logoutIcon,
                title: 'logout'.tr,
                titleColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  Get.back();
                  showCustomBottomSheet(
                    child: ConfirmationBottomSheet(
                      title: 'logout_confirmation'.tr,
                      acceptText: 'yes_logout'.tr,
                      acceptColor: Theme.of(context).colorScheme.error,
                      cancelText: 'no_stay'.tr,
                      onAccept: () {
                        ApiChecker.isLoggingOut = true;
                        Get.find<ProfileController>().stopLocationRecord();
                        Get.find<AuthController>().clearSharedData();
                        Get.offAllNamed(RouteHelper.getSignInRoute());
                      },
                      onCancel: () =>
                          Get.back(), // اختياري، لأنه افتراضي بيرجع للخلف
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
