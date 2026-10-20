import 'package:doghree_rider/features/auth/controllers/auth_controller.dart';
import 'package:doghree_rider/features/language/widgets/language_card_widget.dart';
import 'package:doghree_rider/features/profile/controllers/profile_controller.dart';
import 'package:doghree_rider/helper/route_helper.dart';
import 'package:doghree_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:doghree_rider/features/language/controllers/language_controller.dart';
import 'package:doghree_rider/util/app_constants.dart';
import 'package:doghree_rider/util/dimensions.dart';
import 'package:doghree_rider/util/manager_assets.dart';
import 'package:doghree_rider/common/widgets/custom_button_widget.dart';
import 'package:doghree_rider/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatelessWidget {
  const ChooseLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body:
          GetBuilder<LocalizationController>(builder: (localizationController) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              ManagerAssets.languageBackground,
              height: 210,
              width: 210,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w20),
            child: Text('choose_your_language'.tr,
                style: textBold().copyWith(fontSize: Dimensions.fs16)),
          ),
          SizedBox(height: Dimensions.h4),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.w20),
            child: Text('choose_your_language_to_proceed'.tr,
                style:
                    textRegular().copyWith(fontSize: Dimensions.fs12)),
          ),
          SizedBox(height: Dimensions.h25),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.w20),
                itemBuilder: (context, index) {
                  return LanguageCardWidget(
                    languageModel: localizationController.languages[index],
                    localizationController: localizationController,
                    index: index,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: Dimensions.h16,
                horizontal: Dimensions.w25),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 0)
              ],
            ),
            child: CustomButtonWidget(
                buttonText: 'next'.tr,
                onPressed: () async {
                  if (localizationController.languages.isNotEmpty &&
                      localizationController.selectedLanguageIndex != -1) {
                    localizationController.setLanguage(Locale(
                      AppConstants
                          .languages[
                              localizationController.selectedLanguageIndex]
                          .languageCode!,
                      AppConstants
                          .languages[
                              localizationController.selectedLanguageIndex]
                          .countryCode,
                    ));

                    // توجيه حسب حالة تسجيل الدخول
                    if (Get.find<AuthController>().isLoggedIn()) {
                      Get.find<AuthController>().updateToken();
                      await Get.find<ProfileController>().getProfile();
                      Get.offNamed(RouteHelper.getInitialRoute());
                    } else {
                      Get.offNamed(RouteHelper.getSignInRoute());
                    }
                  } else {
                    showCustomSnackBar('select_a_language'.tr);
                  }
                }),
          ),
        ]);
      }),
    );
  }
}
