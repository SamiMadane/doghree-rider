import 'package:doghree_rider/features/profile/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/features/profile/widgets/profile_button_widget.dart';
import 'package:doghree_rider/features/profile/widgets/section_title.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';

class AccountSection extends StatelessWidget {
  final ProfileController profileController;

  const AccountSection({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final bool showBalance = profileController.profileModel?.earnings == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('account'.tr),
        ProfileCard(
          child: Column(
            children: [
              if (showBalance) ...[
                ProfileButtonWidget(
                  svgPath: ManagerAssets.walletIcon,
                  title: 'balance'.tr,
                  onTap: () => Get.toNamed(RouteHelper.getWalletRoute()),
                ),
                SizedBox(height: Dimensions.h16),
              ],
              ProfileButtonWidget(
                svgPath: ManagerAssets.settingIcon,
                title: 'account_setting'.tr,
                onTap: () => Get.toNamed(RouteHelper.getSettingRoute()),
              ),
              SizedBox(height: Dimensions.h16),
              ProfileButtonWidget(
                svgPath: ManagerAssets.languageIcon,
                title: 'language'.tr,
                onTap: _showLanguageSheet,
                trailingWidget: GetBuilder<LocalizationController>(
                  builder: (controller) {
                    final selectedLang =
                        controller.languages[controller.selectedLanguageIndex];
                    return Image.asset(
                      selectedLang.imageUrl!,
                      width: Dimensions.w22,
                      height: Dimensions.w22,
                    );
                  },
                ),
              ),
              SizedBox(height: Dimensions.h16),
              ProfileButtonWidget(
                svgPath: ManagerAssets.conversationIcon,
                title: 'conversation'.tr,
                onTap: () =>
                    Get.toNamed(RouteHelper.getConversationListRoute()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showLanguageSheet() {
  final LocalizationController localization =
      Get.find<LocalizationController>();
  localization.searchSelectedLanguage();

  final BuildContext context = Get.context!;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Dimensions.r20),
      ),
    ),
    builder: (BuildContext sheetContext) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
      ),
      child: LanguageBottomSheetWidget(),
    ),
  ).then((_) {
    final cachedLocale = localization.getCacheLocaleFromSharedPref();
    // ignore: unnecessary_null_comparison
    if (cachedLocale != null) {
      localization.setLanguage(cachedLocale);
    }
  });
}
