import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/common/widgets/custom_card.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/widgets/profile_button_widget.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/util/styles.dart';

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
          style: textMedium().copyWith(fontSize: Dimensions.fs16),
        ),
        SizedBox(height: Dimensions.h16),
        CustomCard(
          padding: EdgeInsets.symmetric(horizontal:Dimensions.w16 ,vertical: Dimensions.h16,),
          isBorder: false,
          child: Column(
            children: [
              if (profileController.profileModel != null &&
                  profileController.profileModel!.earnings == 1)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: Dimensions.h16),
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
                title: 'account_setting'.tr,
                onTap: () {
                  Get.toNamed(RouteHelper.getSettingRoute());
                },
              ),
              SizedBox(
                height: Dimensions.h16,
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
                height: Dimensions.h16,
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
    shape:  RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.r20),
          topRight: Radius.circular(Dimensions.r20)),
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

