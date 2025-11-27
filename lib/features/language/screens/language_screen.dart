import 'package:wefrh_rider/features/auth/controllers/auth_controller.dart';
import 'package:wefrh_rider/features/language/widgets/language_card_widget.dart';
import 'package:wefrh_rider/features/profile/controllers/profile_controller.dart';
import 'package:wefrh_rider/helper/route_helper.dart';
import 'package:wefrh_rider/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:wefrh_rider/features/language/controllers/language_controller.dart';
import 'package:wefrh_rider/util/app_constants.dart';
import 'package:wefrh_rider/util/dimensions.dart';
import 'package:wefrh_rider/util/manager_assets.dart';
import 'package:wefrh_rider/common/widgets/custom_button_widget.dart';
import 'package:wefrh_rider/common/widgets/custom_snackbar_widget.dart';
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
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.p20),
            child: Text('choose_your_language'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fs16)),
          ),
          const SizedBox(height: Dimensions.p4),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.p20),
            child: Text('choose_your_language_to_proceed'.tr,
                style:
                    robotoRegular.copyWith(fontSize: Dimensions.fs12)),
          ),
          const SizedBox(height: Dimensions.p25),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.p20),
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
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.p16,
                horizontal: Dimensions.p25),
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
