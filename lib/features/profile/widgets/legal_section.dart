import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/confirmation_bottom_sheet.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

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
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        SizedBox(height: Dimensions.paddingSizeDefault),
        CustomCard(
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          isBorder: false,
          child: Column(
            children: [
              ProfileButtonWidget(
                  svgPath: ManagerAssets.termsConditionsIcon,
                  title: 'terms_condition'.tr,
                  onTap: () {
                    Get.toNamed(RouteHelper.getTermsRoute());
                  }),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              ProfileButtonWidget(
                  svgPath: ManagerAssets.privacyPolicyIcon,
                  title: 'privacy_policy'.tr,
                  onTap: () {
                    Get.toNamed(RouteHelper.getPrivacyRoute());
                  }),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        CustomCard(
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
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
                  Get.bottomSheet(
                    ConfirmationBottomSheet(
                      title: 'logout_confirmation'.tr,
                      acceptText: 'yes_logout'.tr,
                      acceptColor: Theme.of(context).colorScheme.error,
                      cancelText: 'no_stay'.tr,
                      onAccept: () {
                        Get.find<AuthController>().clearSharedData();
                        Get.find<ProfileController>().stopLocationRecord();
                        Get.offAllNamed(RouteHelper.getSignInRoute());
                      },
                      onCancel: () => Get.back(),
                    ),
                    isScrollControlled: true,
                    backgroundColor:
                        Colors.transparent, // للتأكد أن الدائرة × تظهر بشكل جيد
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
