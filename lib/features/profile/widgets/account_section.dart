import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_card.dart';
import 'package:sixam_mart_delivery/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_delivery/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/manager_assets.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class AccountSection extends StatelessWidget {
  final ProfileController profileController;
  const AccountSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'account'.tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        SizedBox(height: Dimensions.paddingSizeDefault),
        CustomCard(
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          isBorder: false,
          child: Column(
            children: [
              if (profileController.profileModel != null &&
                  profileController.profileModel!.earnings == 1)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault),
                  child: ProfileButtonWidget(
                    svgPath: ManagerAssets.walletIcon,
                    title: 'balance'.tr,
                    onTap: () {
                      Get.toNamed(RouteHelper.getCashInHandRoute());
                    },
                  ),
                ),
              ProfileButtonWidget(
                svgPath: ManagerAssets.settingIcon,
                title: 'Account Setting'.tr,
                onTap: () {
                  Get.toNamed(RouteHelper.getSettingRoute());
                },
              ),
              SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              ProfileButtonWidget(
                svgPath: ManagerAssets.languageIcon,
                title: 'language'.tr,
                onTap: () {
                  _manageLanguageFunctionality();
                },
                trailingWidget: GetBuilder<LocalizationController>(
                  builder: (controller) {
                    final selectedLang =
                        controller.languages[controller.selectedLanguageIndex];
                    return Image.asset(
                      selectedLang.imageUrl!,
                      width: 22,
                      height: 22,
                    );
                  },
                ),
              ),
              SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              ProfileButtonWidget(
                svgPath: ManagerAssets.conversationIcon,
                title: 'conversation'.tr,
                onTap: () {
                  Get.toNamed(RouteHelper.getConversationListRoute());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

_manageLanguageFunctionality() {
  final localizationController = Get.find<LocalizationController>();

  localizationController.searchSelectedLanguage();

  showModalBottomSheet(
    isScrollControlled: true,
    useRootNavigator: true,
    context: Get.context!,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: LanguageBottomSheetWidget(),
      );
    },
  ).then((value) {
    final cachedLocale = localizationController.getCacheLocaleFromSharedPref();
    // ignore: unnecessary_null_comparison
    if (cachedLocale != null) {
      localizationController.setLanguage(cachedLocale);
    }
  });
}

