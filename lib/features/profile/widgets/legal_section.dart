import 'package:doghree_rider/features/profile/widgets/profile_card_widget.dart';
import 'package:doghree_rider/features/profile/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/api/api_checker.dart';
import 'package:doghree_rider/common/widgets/confirmation_bottom_sheet.dart';
import 'package:doghree_rider/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/widgets/profile_button_widget.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class LegalSection extends StatelessWidget {
  final ProfileController profileController;
  const LegalSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final Color error = Theme.of(context).colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('legal'.tr),
        ProfileCard(
          child: Column(
            children: [
              ProfileButtonWidget(
                svgPath: ManagerAssets.termsConditionsIcon,
                title: 'terms_condition'.tr,
                onTap: () => Get.toNamed(RouteHelper.getTermsRoute()),
              ),
              SizedBox(height: Dimensions.h16),
              ProfileButtonWidget(
                svgPath: ManagerAssets.privacyPolicyIcon,
                title: 'privacy_policy'.tr,
                onTap: () => Get.toNamed(RouteHelper.getPrivacyRoute()),
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.h16),
        ProfileCard(
          child: ProfileButtonWidget(
            svgPath: ManagerAssets.logoutIcon,
            title: 'logout'.tr,
            titleColor: error,
            iconColor: error,
            showTrailing: false,
            onTap: () {
              Get.back();
              showCustomBottomSheet(
                child: ConfirmationBottomSheet(
                  title: 'logout_confirmation'.tr,
                  icon: ManagerAssets.warningDeleteAccount,
                  iconSize: Dimensions.w140,
                  acceptText: 'yes_logout'.tr,
                  cancelText: 'no_stay'.tr,
                  onAccept: () {
                    ApiChecker.isLoggingOut = true;
                    Get.find<ProfileController>().stopLocationRecord();
                    Get.find<AuthController>().clearSharedData();
                    Get.offAllNamed(RouteHelper.getSignInRoute());
                  },
                  onCancel: Get.back,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
